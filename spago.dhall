{ name = "fetch"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "arraybuffer-types"
  , "effect"
  , "fetch-core"
  , "foreign"
  , "http-methods"
  , "newtype"
  , "prelude"
  , "record"
  , "typelevel-prelude"
  , "unsafe-coerce"
  , "web-file"
  , "web-streams"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
, license = "MIT"
, repository = "https://github.com/rowtype-yoga/purescript-fetch.git"
}
