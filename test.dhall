let conf = ./spago.dhall

in      conf
    //  { sources = conf.sources # [ "test/**/*.purs" ]
        , dependencies =
              conf.dependencies
            # [ "aff"
              , "datetime"
              , "effect"
              , "either"
              , "exceptions"
              , "spec"
              , "strings"
              , "node-buffer"
              , "node-event-emitter"
              , "node-http"
              , "node-net"
              , "node-streams"
              , "partial"
              , "refs"
              ]
        }
