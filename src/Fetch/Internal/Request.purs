module Fetch.Internal.Request
  ( HighlevelRequestOptions
  , class ToCoreRequestOptions
  , class ToCoreRequestOptionsConverter
  , class ToCoreRequestOptionsHelper
  , new
  , convert
  , convertImpl
  , convertHelper
  ) where

import Prelude

import Data.HTTP.Method (Method)
import Data.Newtype (un)
import Data.Symbol (class IsSymbol)
import Effect (Effect)
import Effect.Uncurried (runEffectFn2)
import Fetch.Core.Headers (Headers)
import Fetch.Core.Headers as CoreHeaders
import Fetch.Core.Integrity (Integrity(..))
import Fetch.Core.Integrity as CoreIntegrity
import Fetch.Core.Referrer (Referrer)
import Fetch.Core.Referrer as CoreReferrer
import Fetch.Core.Referrer as Referrer
import Fetch.Core.ReferrerPolicy (ReferrerPolicy)
import Fetch.Core.ReferrerPolicy as CoreReferrerPolicy
import Fetch.Core.ReferrerPolicy as ReferrerPolicy
import Fetch.Core.Request (_unsafeNew)
import Fetch.Core.Request as CoreRequest
import Fetch.Core.RequestBody (RequestBody)
import Fetch.Core.RequestCache (RequestCache)
import Fetch.Core.RequestCache as CoreRequestCache
import Fetch.Core.RequestCache as RequestCache
import Fetch.Core.RequestCredentials (RequestCredentials)
import Fetch.Core.RequestCredentials as CoreRequestCredentials
import Fetch.Core.RequestCredentials as RequestCredentials
import Fetch.Core.RequestMode (RequestMode)
import Fetch.Core.RequestMode as CoreRequestMode
import Fetch.Core.RequestMode as RequestMode
import Fetch.Internal.RequestBody (class ToRequestBody, toRequestBody)
import Prim.Row (class Lacks, class Union)
import Prim.Row as R
import Prim.RowList as RL
import Record (delete, get, insert)
import Type.Proxy (Proxy(..))
import Type.Row.Homogeneous (class Homogeneous)

type HighlevelRequestOptions headers body =
  ( method :: Method
  , headers :: { | headers }
  , body :: body
  , credentials :: CoreRequestCredentials.RequestCredentials
  , cache :: CoreRequestCache.RequestCache
  , mode :: CoreRequestMode.RequestMode
  , referrer :: CoreReferrer.Referrer
  , referrerPolicy :: CoreReferrerPolicy.ReferrerPolicy
  , integrity :: CoreIntegrity.Integrity
  )

new
  :: forall input thru
   . Union input thru CoreRequest.UnsafeRequestOptions
  => String
  -> { | input }
  -> Effect CoreRequest.Request
new url options = runEffectFn2 _unsafeNew url options

class ToCoreRequestOptions input output | input -> output where
  convert :: Record input -> Record output

instance (Union rIn thru (HighlevelRequestOptions headers body), RL.RowToList rIn rInRL, ToCoreRequestOptionsHelper rIn rInRL rOut) => ToCoreRequestOptions (| rIn) (| rOut) where
  convert = convertHelper (Proxy :: Proxy rInRL)

class ToCoreRequestOptionsHelper :: forall k. Row Type -> k -> Row Type -> Constraint
class ToCoreRequestOptionsHelper input inputRL output | inputRL -> output where
  convertHelper :: Proxy inputRL -> Record input -> Record output

instance ToCoreRequestOptionsHelper r RL.Nil () where
  convertHelper _ _ = {}
else instance
  ( ToCoreRequestOptionsConverter sym tpeIn tpeOut
  , R.Cons sym tpeIn tailIn r
  , RL.RowToList tailIn tailInRL
  , Lacks sym tailIn
  , IsSymbol sym
  , ToCoreRequestOptionsHelper tailIn tailInRL tailOutput
  , R.Cons sym tpeOut tailOutput output
  , Lacks sym tailOutput
  ) =>
  ToCoreRequestOptionsHelper r (RL.Cons sym tpeIn tailInRL) output where
  convertHelper _ r = insert (Proxy :: Proxy sym) head tail
    where
    tail :: Record tailOutput
    tail = delete (Proxy :: Proxy sym) r # convertHelper (Proxy :: Proxy tailInRL)

    head :: tpeOut
    head = get (Proxy :: Proxy sym) r # convertImpl (Proxy :: Proxy sym)

class ToCoreRequestOptionsConverter :: forall k. k -> Type -> Type -> Constraint
class ToCoreRequestOptionsConverter sym input output | sym input -> output where
  convertImpl :: Proxy sym -> input -> output

instance ToCoreRequestOptionsConverter "method" Method String where
  convertImpl _ = show

instance (Homogeneous r String) => ToCoreRequestOptionsConverter "headers" { | r } Headers where
  convertImpl _ = CoreHeaders.fromRecord

instance (ToRequestBody body) => ToCoreRequestOptionsConverter "body" body RequestBody where
  convertImpl _ = toRequestBody

instance ToCoreRequestOptionsConverter "credentials" RequestCredentials String where
  convertImpl _ = RequestCredentials.toString

instance ToCoreRequestOptionsConverter "cache" RequestCache String where
  convertImpl _ = RequestCache.toString

instance ToCoreRequestOptionsConverter "mode" RequestMode String where
  convertImpl _ = RequestMode.toString

instance ToCoreRequestOptionsConverter "referrer" Referrer String where
  convertImpl _ = Referrer.toString

instance ToCoreRequestOptionsConverter "referrerPolicy" ReferrerPolicy String where
  convertImpl _ = ReferrerPolicy.toString

instance ToCoreRequestOptionsConverter "integrity" Integrity String where
  convertImpl _ = un Integrity

