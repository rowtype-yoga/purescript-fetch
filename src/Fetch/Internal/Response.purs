module Fetch.Internal.Response where

import Prelude

import Control.Promise as Control
import Control.Promise as Promise
import Data.ArrayBuffer.Types (ArrayBuffer, Uint8Array)
import Data.Newtype (class Newtype)
import Effect (Effect)
import Effect.Aff (Aff)
import Fetch.Core.Headers (Headers)
import Fetch.Core.Response as CoreResponse
import Foreign (Foreign)
import Unsafe.Coerce (unsafeCoerce)
import Web.File.Blob (Blob)
import Web.Promise as Web
import Web.Streams.ReadableStream (ReadableStream)

type ResponseR =
  ( headers :: Headers
  , ok :: Boolean
  , redirected :: Boolean
  , status :: Int
  , statusText :: String
  , url :: String
  , text :: Aff String
  , json :: Aff Foreign
  , body :: Effect (ReadableStream Uint8Array)
  , arrayBuffer :: Aff ArrayBuffer
  , blob :: Aff Blob
  )

type Response =
  { | ResponseR
  }

data BlobDriver :: forall k. k -> Type
data BlobDriver blob = BlobDriver

data StreamDriver :: forall k. k -> Type
data StreamDriver stream = StreamDriver

newtype JsonDriver :: Type -> Type
newtype JsonDriver json = JsonDriver (Foreign -> Aff json)

derive instance Newtype (JsonDriver json) _

text :: CoreResponse.Response -> Aff String
text response = CoreResponse.text response <#> promiseToPromise # Promise.toAffE

body :: CoreResponse.Response -> Effect (ReadableStream Uint8Array)
body = CoreResponse.body

json :: CoreResponse.Response -> Aff Foreign
json response = CoreResponse.json response <#> promiseToPromise # Promise.toAffE

arrayBuffer :: CoreResponse.Response -> Aff ArrayBuffer
arrayBuffer response = CoreResponse.arrayBuffer response <#> promiseToPromise # Promise.toAffE

blob :: CoreResponse.Response -> Aff Blob
blob response = CoreResponse.blob response <#> promiseToPromise # Promise.toAffE

promiseToPromise :: Web.Promise ~> Control.Promise
promiseToPromise = unsafeCoerce

convert :: CoreResponse.Response -> Response
convert response =
  { headers: CoreResponse.headers response
  , ok: CoreResponse.ok response
  , redirected: CoreResponse.redirected response
  , status: CoreResponse.status response
  , statusText: CoreResponse.statusText response
  , url: CoreResponse.url response
  , text: text response
  , json: json response
  , body: CoreResponse.body response
  , arrayBuffer: arrayBuffer response
  , blob: blob response
  }
