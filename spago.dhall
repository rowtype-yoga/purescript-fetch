{ name = "fetch"
, dependencies =
  [ "aff"
  , "arraybuffer-types"
  , "bifunctors"
  , "effect"
  , "either"
  , "foreign"
  , "http-methods"
  , "js-fetch"
  , "js-promise"
  , "js-promise-aff"
  , "maybe"
  , "newtype"
  , "ordered-collections"
  , "prelude"
  , "record"
  , "strings"
  , "typelevel-prelude"
  , "web-file"
  , "web-streams"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
, license = "MIT"
, repository = "https://github.com/rowtype-yoga/purescript-fetch.git"
}
