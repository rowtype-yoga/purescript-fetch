let conf = ./spago.dhall

in      conf
    //  { sources = conf.sources # [ "test/**/*.purs" ]
        , dependencies =
              conf.dependencies
            # [ "aff"
              , "aff-promise"
              , "console"
              , "effect"
              , "either"
              , "exceptions"
              , "lists"
              , "spec"
              , "spec-discovery"
              , "strings"
              , "transformers"
              , "debug"
              , "media-types"
              ]
        }
