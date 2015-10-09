module ImpressDemo where

import Html exposing (..)
import Html.Attributes exposing (..)
import Impress.Config exposing (..)


step =
  Impress.Config.step


fallback : Html
fallback =
  Impress.Config.fallback


htmlBefore : Maybe Html
htmlBefore =
  Nothing


htmlAfter : Maybe Html
htmlAfter =
  Just Impress.Config.hint


steps : List Step
steps =
  [ { step
    | id <- "bored"
    , classes <- "slide"
    , html <- [ q [ ]
                  [ text "Aren't you just "
                  , b [ ] [ text "bored" ]
                  , text " with all those slides-based presentations?"
                  ]
              ]
    } |> translate -1000 -1500 0

  , { step
    | classes <- "slide"
    , html <- [ q [ ]
                  [ text "Don't you think that presentations given "
                  , strong [ ] [ text "in modern browsers" ]
                  , text " shouldn't "
                  , strong [ ] [ text "copy the limits" ]
                  , text " of 'classic' slide decks?"
                  ]
              ]
    } |> translateY -1500

  , { step
    | classes <- "slide"
    , html <- [ q [ ]
                  [ text "Would you like to "
                  , strong [ ] [ text "impress your audience" ]
                  , text " with "
                  , strong [ ] [ text "a stunning visualization" ]
                  , text " of your talk?"
                  ]
              ]
    } |> translate 1000 -1500 0

  , { step
    | id <- "title"
    , html <- [ span [ class "try" ] [ text "then you should try"]
              , h1 [ ] [ text "impress.js", sup [ ] [ text "*" ] ]
              , span [ class "footnote" ] [ sup [ ] [ text "*" ], text " no rhyme intended" ]
              ]
    } |> scale 4

  , { step
    | id <- "its"
    , html <- [ p [ ]
                  [ text "It's a "
                  , strong [ ] [ text "presentation tool" ]
                  , br [ ] [ ]
                  , text "inspired by the idea behind "
                  , a [ href "http://prezi.com" ] [ text "prezi.com" ]
                  , br [ ] [ ]
                  , text "and based on the "
                  , strong [ ] [ text "power of CSS3 transforms and transitions" ]
                  , text " in modern browsers"
                  ]
              ]
    } |> translate 850 3000 0 |> rotateZ 90 |> scale 5

  , { step
    | id <- "big"
    , html <- [ p [ ]
                  [ text "visualize your "
                  , b [ ] [ text "big" ]
                  , span [ class "thoughts" ] [ text "thoughts"]
                  ]
              ]
    } |> translate 3500 2100 0 |> rotateZ 180 |> scale 6

  , { step
    | id <- "tiny"
    , html <- [ p [ ]
                  [ text "and "
                  , b [ ] [ text "tiny" ]
                  , text " ideas"
                  ]
              ]
    } |> translate 2825 2325 -3000 |> rotateZ 300

  , { step
    | id <- "ing"
    , html <- [ p [ ]
                  [ text "by "
                  , b [ class "positioning" ] [ text "positioning" ]
                  , text ", "
                  , b [ class "rotating" ] [ text "rotating" ]
                  , text " and "
                  , b [ class "scaling" ] [ text "scaling" ]
                  , text " them on an infinite canvas"
                  ]
              ]
    } |> translate 3500 -850 0 |> rotateZ 270 |> scale 6

  , { step
    | id <- "imagination"
    , html <- [ p [ ]
                  [ text "the only "
                  , b [ ] [ text "limit" ]
                  , text " is your "
                  , b [ class "imagination" ] [ text "imagination" ]
                  ]
              ]
    } |> translate 6700 -300 0 |> scale 6

  , { step
    | id <- "source"
    , html <- [ p [ ]
                  [ text "want to know more?" ]
              , q [ ]
                  [ a [ href "http://github.com/bartaz/impress.js" ] [ text "use the source" ]
                  , text ", Luke!"
                  ]
              ]
    } |> translate 6300 2000 0 |> rotateZ 20 |> scale 4

  , { step
    | id <- "one-more-thing"
    , html <- [ p [ ] [ text "one more thing..." ] ]
    } |> translate 6000 4000 0 |> scale 2

  , { step
    | id <- "its-in-3d"
    , html <- [ p [ ]
                  [ span [ class "have" ] [ text "have" ]
                  , text " "
                  , span [ class "you" ] [ text "you" ]
                  , text " "
                  , span [ class "noticed" ] [ text "noticed" ]
                  , text " "
                  , span [ class "its" ] [ text "it's" ]
                  , text " "
                  , span [ class "in" ] [ text "in" ]
                  , text " "
                  , b [ ] [ text "3D", sup [ ] [ text "*" ], text "?" ]
                  ]
              , span [ class "footnote" ] [ text "* beat that, prezi ;)" ]
              ]
    } |> translate 6200 4300 -100 |> rotate -40 10 0 |> scale 2

  , { step | id <- "overview" } |> translate 3000 1500 0 |> scale 10
  ]
