module Main where

import Html exposing (Html)
import Task exposing (Task)
import Effects exposing (Never)
import StartApp
import Impress exposing (init, update, view, signals, asStatic)
import Impress.Config exposing (DeckState, Step, Context)

import ImpressDemo as Deck exposing (steps, fallback, htmlBefore, htmlAfter)


main : Signal Html
main =
  app.html


app : StartApp.App DeckState
app =
  StartApp.start
    { init = init staticSteps hashFromAddressBar
    , update = update staticSteps
    , view = view context
    , inputs = signals
    }


staticSteps : List Step
staticSteps =
  asStatic steps


context : Context
context =
  { impressSupported = impressSupported
  , staticSteps = staticSteps
  , fallback = fallback
  , maybeHtml = (htmlBefore, htmlAfter)
  }


-- PORTS

port impressSupported : Bool

port hashFromAddressBar : String

port tasks : Signal (Task Never ())
port tasks =
  app.tasks
