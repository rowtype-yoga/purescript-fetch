# purescript-fetch

High-level library for the [WHATWG Fetch Living Standard](https://fetch.spec.whatwg.org/).

`purescript-fetch` works on browser and Node.js. 
Running on Node.js requires version `>17.5`, see [# Usage](#usage).

## Installation

```bash
spago install fetch
```

## Usage

**Note:** 
Node.js `<17.5` is not supported.
Node.js `>=17.5` and `<18.0` requires the `--experimental-fetch` node options:
```bash
NODE_OPTIONS=--experimental-fetch spago run
```
Node.js `>18.0` you don't need to set the `--experimental-fetch` node option.

Perform a simple `GET` request:
```purescript
fetch "https://httpbin.org/get" {} >>= _.text
```

Perform a `POST` request:
```purescript
do
    { status, text } <- fetch "https://httpbin.org/post"
        { method: POST
        , body: """{"hello":"world"}"""
        , headers: { "Content-Type": "application/json" }
        }
    responseText <- text
```

### Json parsing

`fetch` works well with `yoga-json` and `argonaut`, use our little helper libraries.


### yoga-json

```bash
spago install fetch-yoga-json
```

```purescript
type HttpBinResponse = { json :: { hello :: String } }

main :: Effect Unit
main = launchAff_ do
  { json } <- fetch "https://httpbin.org/post"
    { method: POST
    , body: writeJSON { hello: "world" }
    , headers: { "Content-Type": "application/json" }
    }
  { json: { hello: world } } :: HttpBinResponse <- fromJSON json
  log world
```

### argonaut

```bash
spago install fetch-argonaut
```

```purescript
type HttpBinResponse = { json :: { hello :: String } }

do
  { json } <- fetch "https://httpbin.org/post"
    { method: POST
    , body: toJsonString { hello: "world" }
    , headers: { "Content-Type": "application/json" }
    }
  { json: { hello: world } } :: HttpBinResponse <- fromJson json
  log world
```
