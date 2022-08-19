module Fetch.Fetch
  ( fetch
  ) where

import Prelude

import Control.Promise as Promise
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Fetch.Core as Core
import Fetch.Core.Request as CoreRequest
import Fetch.Internal.Request (class ToCoreRequestOptions, HighlevelRequestOptions, new)
import Fetch.Internal.Request as Request
import Fetch.Internal.RequestBody (class ToRequestBody)
import Fetch.Internal.Response (Response)
import Fetch.Internal.Response as Response
import Prim.Row (class Union)
import Type.Row.Homogeneous (class Homogeneous)
import Unsafe.Coerce (unsafeCoerce)

-- | Fetch
-- | 
fetch
  :: forall input output thruIn thruOut headers body
   . Homogeneous headers String
  => ToRequestBody body
  => Union input thruIn (HighlevelRequestOptions headers body)
  => Union output thruOut CoreRequest.UnsafeRequestOptions
  => ToCoreRequestOptions input output
  => String
  -> { | input }
  -> Aff Response
fetch url r = do
  request <- liftEffect $ new url $ Request.convert r
  cResponse <- Promise.toAffE $ unsafeCoerce $ Core.fetch request
  pure $ Response.convert cResponse

