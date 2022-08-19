
let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.4-20220816/packages.dhall
        sha256:8b4467b4b5041914f9b765779c8936d6d4c230b1f60eb64f6269c71812fd7e98

in  upstream
  with fetch-core = {
    dependencies = [
      "arraybuffer-types"
    , "arrays"
    , "console"
    , "effect"
    , "foldable-traversable"
    , "foreign"
    , "foreign-object"
    , "functions"
    , "http-methods"
    , "maybe"
    , "newtype"
    , "nullable"
    , "prelude"
    , "record"
    , "tuples"
    , "typelevel-prelude"
    , "unfoldable"
    , "unsafe-coerce"
    , "web-file"
    , "web-promise"
    , "web-streams"
    ],
    version = "main",
    repo = "https://github.com/rowtype-yoga/purescript-fetch-core.git"
  } 
