module Fetch.Internal.Headers
  ( contains
  , lookup
  , toHeaders
  ) where

import Prelude

import Data.Bifunctor (lmap)
import Data.Map as Map
import Data.Maybe (Maybe)
import Data.String.CaseInsensitive (CaseInsensitiveString(..))
import JS.Fetch.Headers as CoreHeaders

toHeaders :: CoreHeaders.Headers -> Map.Map CaseInsensitiveString String
toHeaders = CoreHeaders.toArray >>> map (lmap CaseInsensitiveString) >>> Map.fromFoldable

lookup :: String -> Map.Map CaseInsensitiveString String -> Maybe String
lookup key headers = Map.lookup (CaseInsensitiveString key) headers

contains ∷ String → Map.Map CaseInsensitiveString String → Boolean
contains key headers = Map.member (CaseInsensitiveString key) headers
