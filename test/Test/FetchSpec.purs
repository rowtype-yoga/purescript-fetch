module Test.FetchSpec where

import Prelude

import Data.ArrayBuffer.Types (Uint8Array)
import Data.Maybe (Maybe(..))
import Fetch (Method(..), Referrer(..), RequestMode(..), fetch, fetchBody)
import Fetch as Fetch
import Foreign (unsafeFromForeign)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Web.Streams.ReadableStream (ReadableStream)

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

        { status, json } <- fetchBody "https://httpbin.org/post"
          { method: POST
          , mode: Cors
          , body: helloWorldStream
          , headers: { "Content-Type": "application/json" }
          , referrer: (ReferrerUrl "https://httpbin.org")
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
