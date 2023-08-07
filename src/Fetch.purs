module Fetch
  ( fetch
  , fetchBody
  , module Data.HTTP.Method
  , module Fetch.Core.RequestCache
  , module Fetch.Core.RequestCredentials
  , module Fetch.Core.RequestMode
  , module Fetch.Core.Referrer
  , module Fetch.Core.Integrity
  , module Fetch.Internal.Request
  , module Fetch.Internal.RequestBody
  , module Fetch.Internal.Response
  , module Fetch.Internal.Headers
  ) where

import Prelude

import Data.HTTP.Method (Method(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Fetch.Core as Core
import Fetch.Core.Integrity (Integrity(..))
import Fetch.Core.Referrer (Referrer(..))
import Fetch.Core.Request as CoreRequest
import Fetch.Core.RequestCache (RequestCache(..))
import Fetch.Core.RequestCredentials (RequestCredentials(Omit, Include))
import Fetch.Core.RequestMode (RequestMode(Cors, NoCors, Navigate))
import Fetch.Internal.Headers (lookup, toHeaders, contains)
import Fetch.Internal.Request (class ToCoreRequestOptions, class ToCoreRequestOptionsConverter, class ToCoreRequestOptionsHelper, HighlevelRequestOptions, convertHelper, convertImpl, new)
import Fetch.Internal.Request as Request
import Fetch.Internal.RequestBody (class ToRequestBody, toRequestBody)
import Fetch.Internal.Response (Response, ResponseR, arrayBuffer, blob, body, json, text)
import Fetch.Internal.Response as Response
import Prim.Row (class Union)
import Promise.Aff as Promise.Aff

-- | Implementation of `fetch`, see https://developer.mozilla.org/en-US/docs/Web/API/fetch
-- | For usage with `String` bodies. For other body types, see `fetchBody`
-- |
-- | Usage:
-- | ```purescript
-- | do
-- |   let requestUrl = "https://httpbin.org/get"
-- |   { status, text } <- fetch requestUrl { headers: { "Accept": "application/json" }}
-- |   responseBody <- text
-- | ```
-- | A more complex example doing a Post request:
-- | ```purescript
-- | do
-- |   { status, json } <- fetch "https://httpbin.org/post"
-- |        { method: POST
-- |        , mode: RequestMode.Cors
-- |        , body: """{"hello":"world"}"""
-- |        , headers: { "Content-Type": "application/json" }
-- |        , referrer: ReferrerUrl "https://httpbin.org"
-- |        }
-- |   foreignJsonValue <- json
-- | ```
fetch
  :: forall input output thruIn thruOut headers
   . Union input thruIn (HighlevelRequestOptions headers String)
  => Union output thruOut CoreRequest.UnsafeRequestOptions
  => ToCoreRequestOptions input output
  => String
  -> { | input }
  -> Aff Response
fetch url r = do
  request <- liftEffect $ new url $ Request.convert r
  cResponse <- Promise.Aff.toAffE $ Core.fetch request
  pure $ Response.convert cResponse

-- | Like `fetch`, but can accept arbitrary `RequestBody`s.
fetchBody
  :: forall input output thruIn thruOut headers body
   . ToRequestBody body
  => Union input thruIn (HighlevelRequestOptions headers body)
  => Union output thruOut CoreRequest.UnsafeRequestOptions
  => ToCoreRequestOptions input output
  => String
  -> { | input }
  -> Aff Response
fetchBody url r = do
  request <- liftEffect $ new url $ Request.convert r
  cResponse <- Promise.Aff.toAffE $ Core.fetch request
  pure $ Response.convert cResponse
