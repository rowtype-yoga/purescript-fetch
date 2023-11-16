let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.12-20231116/packages.dhall
        sha256:cf42bf64e7ee34092175dfd2f2fd8b02a9ab799fdf140e6a5d5a50d580f012f5

in  upstream
  with fetch-core.version = "v5.1.0"
