{ name = "fetch"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "arraybuffer-types"
  , "bifunctors"
  , "effect"
  , "fetch-core"
  , "foreign"
  , "http-methods"
  , "maybe"
  , "newtype"
  , "ordered-collections"
  , "prelude"
  , "record"
  , "typelevel-prelude"
  , "unsafe-coerce"
  , "web-file"
  , "web-promise"
  , "web-streams"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
, license = "MIT"
, repository = "https://github.com/rowtype-yoga/purescript-fetch.git"
}
