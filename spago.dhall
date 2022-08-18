{ name = "fetch"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "arraybuffer-types"
  , "console"
  , "effect"
  , "fetch-core"
  , "foreign"
  , "newtype"
  , "prelude"
  , "record"
  , "unsafe-coerce"
  , "web-file"
  , "web-streams"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
, license = "MIT"
, repository = "https://github.com/rowtype-yoga/purescript-fetch.git"
}
