module Fetch.Internal.RequestBody
  (
  )
  where

import Prelude

import Data.ArrayBuffer.Types (ArrayBuffer, ArrayView, Uint8Array)
import Fetch.Core.RequestBody as CoreRequestBody
import Web.Streams.ReadableStream (ReadableStream)

class ToRequestBody body where
  toRequestBody :: body -> CoreRequestBody.RequestBody

instance ToRequestBody ArrayBuffer where
  toRequestBody = CoreRequestBody.fromArrayBuffer

instance ToRequestBody (ArrayView a) where
  toRequestBody = CoreRequestBody.fromArrayView

instance ToRequestBody String where
  toRequestBody = CoreRequestBody.fromString

instance ToRequestBody (ReadableStream Uint8Array) where
  toRequestBody = CoreRequestBody.fromReadableStream

