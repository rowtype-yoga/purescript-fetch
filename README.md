# purescript-fetch

High-level library for the [WHATWG Fetch Living Standard](https://fetch.spec.whatwg.org/).

**Note:** This library requires Node.js version `>17.5`, see [# Usage](#usage).

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
        , mode: Cors
        , body: """{"hello":"world"}"""
        , headers: { "Content-Type": "application/json" }
        , referrer: (ReferrerUrl "https://httpbin.org")
        }
    responseText <- text
```

### Json parsing

`fetch` works well with `yoga-json` and `argonaut`, use our little helper libraries.

### yoga-json
You can use `fetch-yoga-json` helper library to simplify json handling

```purescript
do
    { json } <- fetch "https://httpbin.org/post"
        { method: POST
        , body: writeJSON { hello: "world" }
        , headers: { "Content-Type": "application/json" }
        }
    { "data": d, url, origin } <- fromJson json
```
