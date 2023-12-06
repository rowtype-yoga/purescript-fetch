module Test.FetchSpec where

import Prelude

import Data.ArrayBuffer.Types (Uint8Array)
import Data.Maybe (Maybe(..), isNothing)
import Fetch (Method(..), Referrer(..), RequestMode(..), fetch)
import Fetch as Fetch
import JS.Fetch.Duplex (Duplex(..))
import Foreign (unsafeFromForeign)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual, shouldSatisfy)
import Web.Streams.ReadableStream (ReadableStream)
import Effect.Aff (attempt, forkAff, launchAff_)
import Data.Either (blush)
import Effect.Aff (delay, joinFiber, killFiber) as Aff
import Data.Time.Duration (Milliseconds(Milliseconds))
import Effect.Exception (Error, error)
import Effect.Exception (message) as Exception
import Effect.Ref (new, read, write) as Ref
import Effect.Class (liftEffect)
import Node.HTTP as HTTP
import Node.EventEmitter (once_)
import Node.HTTP.Server as Server
import Node.Net.Server (listenTcp)
import Node.HTTP.OutgoingMessage as OM
import Node.Net.Server as NetServer
import Node.HTTP.IncomingMessage as IM
import Node.HTTP.ServerResponse as ServerResponse
import Partial.Unsafe (unsafeCrashWith)
import Node.Encoding (Encoding(UTF8))
import Node.Stream as Stream
import Node.HTTP.Types (HttpServer', IMServer, IncomingMessage, ServerResponse)
import Effect (Effect)
import Node.HTTP.Server (closeAllConnections)
import Effect.Ref (Ref)


-- | Returns a new ReadableStream that allows the content of the Blob to be read.
foreign import helloWorldStream :: ReadableStream Uint8Array

spec :: Spec Unit
spec =
  describe "Fetch" do
    describe "fetch" do
      it "should send a Get request" do
        let requestUrl = "https://httpbin.org/get"
        { status, json } <- fetch requestUrl
          { headers: { "Content-Type": "application/json" }
          }
        { url } <- json <#> unsafeFromForeign
        url `shouldEqual` requestUrl
        status `shouldEqual` 200

      it "should send a Post request" do
        { status, json } <- fetch "https://httpbin.org/post"
          { method: POST
          , mode: Cors
          , body: """{"hello":"world"}"""
          , headers: { "Content-Type": "application/json" }
          , referrer: (ReferrerUrl "https://httpbin.org")
          }
        { json: j } <- json <#> unsafeFromForeign
        j `shouldEqual` { hello: "world" }
        status `shouldEqual` 200

      it "should send a Post request with stream body" do

        { status, json } <- fetch "https://httpbin.org/post"
          { method: POST
          , mode: Cors
          , body: helloWorldStream
          , headers: { "Content-Type": "application/json" }
          , referrer: (ReferrerUrl "https://httpbin.org")
          , duplex: Half
          }
        { json: j } <- json <#> unsafeFromForeign
        j `shouldEqual` { hello: "world" }
        status `shouldEqual` 200

      it "should retrieve correct headers" do

        { status, headers } <- fetch "https://httpbin.org/post"
          { method: POST
          , body: """{"hello":"world"}"""
          , headers: { "Content-Type": "application/json" }
          }
        Fetch.lookup "Access-Control-Allow-Origin" headers `shouldEqual` Just "*"
        Fetch.lookup "Content-Type" headers `shouldEqual` Just "application/json"
        Fetch.contains "Content-Length" headers `shouldEqual` true
        status `shouldEqual` 200

      it "can be cancelled" do
        requestCancelledRef <- Ref.new Nothing # liftEffect
        -- Start a server that records our cancellation
        server requestCancelledRef # liftEffect
        requestFiber <- forkAff $ fetch "http://localhost:54045/" {}
        Aff.delay (40.0 # Milliseconds)
        requestCancelled <- Ref.read requestCancelledRef # liftEffect
        requestCancelled `shouldSatisfy` isNothing
        -- Cancel the request
        Aff.killFiber (error "Fetch Abort Test") requestFiber
        result <- attempt $ Aff.joinFiber requestFiber
        (Exception.message <$> blush result) `shouldEqual` (Just "Fetch Abort Test")
        Aff.delay (80.0 # Milliseconds)
        requestCancelled <- Ref.read requestCancelledRef # liftEffect
        (Exception.message <$> requestCancelled) `shouldEqual` (Just "aborted")
        where

        -- | A server that will respond to a request after 100ms
        -- | it records the first error on the request stream in the ref
        -- | Adapted from: [node-http](https://github.com/purescript-node/purescript-node-http/blob/master/test/Main.purs)
        server ref = do
          server <- HTTP.createServer
          server # once_ Server.requestH (respond ref (killServer server))
          let netServer = Server.toNetServer server
          listenTcp netServer { host: "localhost", port: 54045 }
          where

          respond :: Ref (Maybe Error) -> Effect Unit -> IncomingMessage IMServer -> ServerResponse -> Effect Unit
          respond ref closeServer req res = do
            ServerResponse.setStatusCode 200 res
            let
              im = IM.toReadable req
              om = ServerResponse.toOutgoingMessage res
              outputStream = OM.toWriteable om

            -- Handle errors on the input stream
            -- and save them to the ref
            im # once_ Stream.errorH  \err -> do
               whenM (Stream.destroyed im) do
                 Ref.write (Just err) ref # liftEffect

            case IM.method req of
              "GET" -> launchAff_ do
                -- Let's pretend this is answering slowly
                Aff.delay (100.0 # Milliseconds)
                void $ Stream.writeString outputStream UTF8 "ok" # liftEffect
                Stream.end outputStream # liftEffect
              _ ->
                unsafeCrashWith "Unexpected HTTP method"
            launchAff_ do
              Aff.delay (110.0 # Milliseconds)
              closeServer # liftEffect


          killServer :: forall transmissionType. HttpServer' transmissionType -> Effect Unit
          killServer s = do
            let ns = Server.toNetServer s
            closeAllConnections s
            NetServer.close ns
