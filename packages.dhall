let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.10-20230803/packages.dhall
        sha256:7da82e40277c398fd70f16af6450fb74287a88e2a3c8885c065dcdb9df893761

in  upstream
  with fetch-core =
    { dependencies =
        [ "arraybuffer-types"
        , "arrays"
        , "effect"
        , "foldable-traversable"
        , "foreign"
        , "foreign-object"
        , "functions"
        , "http-methods"
        , "js-promise"
        , "maybe"
        , "newtype"
        , "prelude"
        , "record"
        , "tuples"
        , "typelevel-prelude"
        , "unfoldable"
        , "web-file"
        , "web-streams"
        ]
    , version = "main"
    , repo = "https://github.com/thomashoneyman/purescript-fetch-core.git"
    }
