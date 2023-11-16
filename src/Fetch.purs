module Fetch
  ( fetch
  , module Data.HTTP.Method
  , module JS.Fetch.RequestCache
  , module JS.Fetch.RequestCredentials
  , module JS.Fetch.RequestMode
  , module JS.Fetch.Referrer
  , module JS.Fetch.Integrity
  , module Fetch.Internal.Request
  , module Fetch.Internal.RequestBody
  , module Fetch.Internal.Response
  , module Fetch.Internal.Headers
  ) where

import Prelude

import Data.HTTP.Method (Method(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import JS.Fetch as Core
import JS.Fetch.Integrity (Integrity(..))
import JS.Fetch.Referrer (Referrer(..))
import JS.Fetch.Request as CoreRequest
import JS.Fetch.RequestCache (RequestCache(..))
import JS.Fetch.RequestCredentials (RequestCredentials(Omit, Include))
import JS.Fetch.RequestMode (RequestMode(Cors, NoCors, Navigate))
import Fetch.Internal.Headers (lookup, toHeaders, contains)
import Fetch.Internal.Request (class ToCoreRequestOptions, class ToCoreRequestOptionsConverter, class ToCoreRequestOptionsHelper, HighlevelRequestOptions, convertHelper, convertImpl, new)
import Fetch.Internal.Request as Request
import Fetch.Internal.RequestBody (class ToRequestBody, toRequestBody)
import Fetch.Internal.Response (Response, ResponseR, arrayBuffer, blob, body, json, text)
import Fetch.Internal.Response as Response
import Prim.Row (class Union)
import Promise.Aff as Promise.Aff

-- | Implementation of `fetch`, see https://developer.mozilla.org/en-US/docs/Web/API/fetch
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
  :: forall input output @thruIn thruOut headers body
   . Union input thruIn (HighlevelRequestOptions headers body)
  => Union output thruOut CoreRequest.UnsafeRequestOptions
  => ToCoreRequestOptions input output
  => String
  -> { | input }
  -> Aff Response
fetch url r = do
  request <- liftEffect $ new url $ Request.convert r
  cResponse <- Promise.Aff.toAffE $ Core.fetch request
  pure $ Response.convert cResponse
