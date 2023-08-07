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
import Fetch.Core.Duplex (Duplex)
import Fetch.Core.Duplex as Core.Duplex
import Fetch.Core.Headers (Headers)
import Fetch.Core.Headers as Core.Headers
import Fetch.Core.Integrity (Integrity(..))
import Fetch.Core.Integrity as Core.Integrity
import Fetch.Core.Referrer (Referrer)
import Fetch.Core.Referrer as Core.Referrer
import Fetch.Core.ReferrerPolicy (ReferrerPolicy)
import Fetch.Core.ReferrerPolicy as Core.ReferrerPolicy
import Fetch.Core.Request (_unsafeNew)
import Fetch.Core.Request as Core.Request
import Fetch.Core.RequestBody (RequestBody)
import Fetch.Core.RequestCache (RequestCache)
import Fetch.Core.RequestCache as Core.RequestCache
import Fetch.Core.RequestCredentials (RequestCredentials)
import Fetch.Core.RequestCredentials as Core.RequestCredentials
import Fetch.Core.RequestMode (RequestMode)
import Fetch.Core.RequestMode as Core.RequestMode
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
  , credentials :: Core.RequestCredentials.RequestCredentials
  , cache :: Core.RequestCache.RequestCache
  , mode :: Core.RequestMode.RequestMode
  , referrer :: Core.Referrer.Referrer
  , referrerPolicy :: Core.ReferrerPolicy.ReferrerPolicy
  , integrity :: Core.Integrity.Integrity
  , duplex :: Core.Duplex.Duplex
  )

new
  :: forall input thru
   . Union input thru Core.Request.UnsafeRequestOptions
  => String
  -> { | input }
  -> Effect Core.Request.Request
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
  convertImpl _ = Core.Headers.fromRecord

instance (ToRequestBody body) => ToCoreRequestOptionsConverter "body" body RequestBody where
  convertImpl _ = toRequestBody

instance ToCoreRequestOptionsConverter "credentials" RequestCredentials String where
  convertImpl _ = Core.RequestCredentials.toString

instance ToCoreRequestOptionsConverter "cache" RequestCache String where
  convertImpl _ = Core.RequestCache.toString

instance ToCoreRequestOptionsConverter "mode" RequestMode String where
  convertImpl _ = Core.RequestMode.toString

instance ToCoreRequestOptionsConverter "referrer" Referrer String where
  convertImpl _ = Core.Referrer.toString

instance ToCoreRequestOptionsConverter "referrerPolicy" ReferrerPolicy String where
  convertImpl _ = Core.ReferrerPolicy.toString

instance ToCoreRequestOptionsConverter "integrity" Integrity String where
  convertImpl _ = un Integrity

instance ToCoreRequestOptionsConverter "duplex" Duplex String where
  convertImpl _ = Core.Duplex.toString
