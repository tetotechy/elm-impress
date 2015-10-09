# elm-impress
A port of [impress.js](https://github.com/impress/impress.js) by [@bartaz](https://github.com/bartaz) to [Elm](elm-lang.org)

## Status
The software is usable.
It is as simple as creating a declarative list of *steps* in a separate Elm file, wiring it up in the `Main` module.
In Elm terms, each step is defined as a [record type](http://elm-lang.org/guide/core-language#records) with default values,
and ends up being turned into an [`Html`](https://github.com/evancz/elm-html) type by the `elm-impress` engine.

See the `Demo` folder for an example, taken from [the official impress.js demo](http://impress.github.io/impress.js).

To compare, try the [elm-impress demo](http://tetotechy.github.io/elm-impress).

## ToDo
- [ ] Provide more details on usage
- [ ] Describe differences vs. the original JavaScript version (very few indeed, and minor too)
