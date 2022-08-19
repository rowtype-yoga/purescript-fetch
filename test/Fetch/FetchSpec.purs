module Test.Fetch.FetchSpec where

import Prelude

import Data.HTTP.Method (Method(..))
import Fetch.Core.Referrer (Referrer(..))
import Fetch.Core.RequestMode as RequestMode
import Fetch.Fetch (fetch)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec =
  describe "Fetch.Fetch" do
    describe "fetch" do
      it "should send a Get request" do

        response@{ status, json, text } <- fetch "https://httpbin.org/get"
          { method: GET
          , headers:
              { "Content-Type": "application/json"
              }
          }
        status `shouldEqual` 200
      it "should send a Post request" do

        response@{ status, json, text } <- fetch "https://httpbin.org/post"
          { method: POST
          , mode: RequestMode.Cors
          , body: """{"hello":"world"}"""
          , headers:
              { "Content-Type": "application/json"
              }
          , referrer: (ReferrerUrl "https://httpbin.org")
          }
        status `shouldEqual` 200
