module Fetch.Internal.Response where

import Prelude

import Control.Promise as Promise
import Data.ArrayBuffer.Types (ArrayBuffer, Uint8Array)
import Data.Newtype (class Newtype, un)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Fetch.Core.Headers (Headers)
import Fetch.Core.Response as CoreResponse
import Foreign (Foreign)
import Unsafe.Coerce (unsafeCoerce)
import Web.File.Blob (Blob)
import Web.Streams.ReadableStream (ReadableStream)

newtype RawResponse = RawResponse CoreResponse.Response

instance Newtype RawResponse CoreResponse.Response
type BaseResponseR r =
  ( headers :: Headers
  , ok :: Boolean
  , redirected :: Boolean
  , status :: Int
  , statusText :: String
  , url :: String
  | r
  )

type Response =
  { text :: String
  | BaseResponseR ()
  }

type JsonResponse json =
  { json :: json
  | BaseResponseR ()
  }

data BlobDriver :: forall k. k -> Type
data BlobDriver blob = BlobDriver

data StreamDriver :: forall k. k -> Type
data StreamDriver stream = StreamDriver

newtype JsonDriver :: Type -> Type
newtype JsonDriver json = JsonDriver (Foreign -> Aff json)

derive instance Newtype (JsonDriver json) _

body :: RawResponse -> Effect (ReadableStream Uint8Array)
body = un RawResponse >>> CoreResponse.body >>> liftEffect

blob :: RawResponse -> Aff Blob
blob = un RawResponse >>> CoreResponse.blob >>> unsafeCoerce >>> Promise.toAffE >>> liftAff

json :: forall json. JsonDriver json -> RawResponse -> Aff json
json (JsonDriver fromJson) = un RawResponse >>> CoreResponse.json >>> unsafeCoerce >>> Promise.toAffE >=> fromJson
