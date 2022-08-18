module Test.Fetch.FetchSpec where

import Prelude

import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec =
  describe "Fetch.Fetch" do
    describe "fetch" do
      it "should send a Post request" do

        true `shouldEqual` (true)
