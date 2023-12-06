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

import Data.Either (Either(Left, Right))
import Data.HTTP.Method (Method(..))
import Effect.Aff (Aff, effectCanceler, makeAff)
import Effect.Class (liftEffect)
import Fetch.Internal.Headers (contains, lookup, toHeaders)
import Fetch.Internal.Request (class ToCoreRequestOptions, class ToCoreRequestOptionsConverter, class ToCoreRequestOptionsHelper, HighlevelRequestOptions, convertHelper, convertImpl, new)
import Fetch.Internal.RequestBody (class ToRequestBody, toRequestBody)
import Fetch.Internal.Response (Response, ResponseR, arrayBuffer, blob, body, json, text)
import JS.Fetch.AbortController (AbortController)
import JS.Fetch.Integrity (Integrity(..))
import JS.Fetch.Referrer (Referrer(..))
import JS.Fetch.RequestCache (RequestCache(..))
import JS.Fetch.RequestCredentials (RequestCredentials(Include, Omit))
import JS.Fetch.RequestMode (RequestMode(Cors, Navigate, NoCors))
import Prim.Row (class Union)
import JS.Fetch.AbortController (abort, new, signal) as AbortController
import JS.Fetch as Core
import JS.Fetch.Request as CoreRequest
import Promise (Promise, resolve, thenOrCatch) as Promise
import Promise.Aff as Promise.Aff
import Fetch.Internal.Request as Request
import Fetch.Internal.Response as Response

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
  abortController <- AbortController.new # liftEffect
  let signal = AbortController.signal abortController
  cResponse <- toAbortableAff abortController =<< liftEffect (Core.fetchWithOptions request { signal })
  pure $ Response.convert cResponse

toAbortableAff :: forall a. AbortController -> Promise.Promise a -> Aff a
toAbortableAff abortController p = makeAff \cb -> do
   void $ Promise.thenOrCatch
      (\a -> Promise.resolve <$> cb (Right a))
      (\e -> Promise.resolve <$> cb (Left (Promise.Aff.coerce e)))
      p
   pure $ effectCanceler (AbortController.abort abortController)

