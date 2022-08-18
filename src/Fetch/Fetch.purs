module Fetch.Fetch
  ( Request
  , fetch
  , fetchJson
  , fetchRaw
  ) where

import Prelude

import Control.Promise as Promise
import Effect.Aff (Aff)
import Fetch.Core as Core
import Fetch.Core.Request as CoreRequest
import Fetch.Core.Response as CoreResponse
import Fetch.Internal.Response (BaseResponseR, JsonDriver, JsonResponse, RawResponse(..), Response)
import Fetch.Internal.Response as Response
import Record (merge)
import Unsafe.Coerce (unsafeCoerce)

type Request = CoreRequest.Request

convert :: CoreResponse.Response -> { | BaseResponseR () }
convert = unsafeCoerce

fetch :: Request -> Aff Response
fetch request = do
  cResponse <- Promise.toAffE $ unsafeCoerce $ Core.fetch request
  text <- Promise.toAffE $ unsafeCoerce $ CoreResponse.text cResponse
  let response = convert cResponse
  pure $ merge response { text }

fetchRaw :: Request -> Aff RawResponse
fetchRaw = Core.fetch >>> unsafeCoerce >>> Promise.toAffE >>> map RawResponse

fetchJson
  :: forall json
   . JsonDriver json
  -> Request
  -> Aff (JsonResponse json)
fetchJson driver request = do
  rawResponse@(RawResponse cResponse) <- fetchRaw request
  json <- Response.json driver rawResponse
  let response = convert cResponse
  pure $ merge response { json }
