module Impress.Config where

import Html exposing (Html, Attribute, div, text, p, a, b)
import Html.Attributes exposing (style, class, tabindex)
import Time exposing (Time)
import Set exposing (Set)


type alias Config =
    { width: Float
    , height: Float
    , maxScale : Float
    , minScale : Float
    , perspective: Float
    , duration : Time
    }


type alias Step =
    { tag : List Attribute -> List Html -> Html
    , id: String
    , classes : String
    , attrs : List Attribute
    , html : List Html
    , transitionParams : TransitionParams
    , ix : Int
    }


type alias DeckState =
    { currentStep : Step
    , scale : Float
    , n : Int
    , lastScaleParam : Float
    , visitedIxs : Set Int
    , transitioning : Bool
    }


type alias TransitionTime =
  Maybe { for : Time, lastTickTime : Time }


type alias CssTransformVector =
    { x : Float
    , y : Float
    , z : Float
    }


type alias TransitionParams =
    { rotate : CssTransformVector
    , translate : CssTransformVector
    , scale : Float
    }


type Action
    = NoOp
    | KeyDown (Set Int)
    | NewScale (Int, Int)
    | EnterStep Int MoveSource
    | GoTo Int
    | GoToId String


type MoveSource
    = Kb
    | Hash
    | Click


type alias Context =
    { impressSupported : Bool
    , staticSteps : List Step
    , fallback : Html
    , maybeHtml : (Maybe Html, Maybe Html)
    }


config : Config
config =
  { width = 1024
  , height = 768
  , maxScale = 1
  , minScale = 0
  , perspective = 1000
  , duration = 1000
  }


step : Step
step =
  { tag = div
  , id = ""
  , classes = ""
  , attrs = [ ]
  , html = [ ]
  , ix = -1
  , transitionParams = neutral
  }


neutral : TransitionParams
neutral =
  { rotate = zeroedVector
  , translate = zeroedVector
  , scale = 1
  }


zeroedVector : CssTransformVector
zeroedVector =
  { x = 0
  , y = 0
  , z = 0
  }


translateX : Float -> Step -> Step
translateX x step =
  let
    params =
      step.transitionParams

    translateParams =
      step.transitionParams.translate
  in
    { step | transitionParams <- { params | translate <- { translateParams | x <- x }}}


translateY : Float -> Step -> Step
translateY y step =
  let
    params =
      step.transitionParams

    translateParams =
      step.transitionParams.translate
  in
    { step | transitionParams <- { params | translate <- { translateParams | y <- y }}}


translateZ : Float -> Step -> Step
translateZ z step =
  let
    params =
      step.transitionParams

    translateParams =
      step.transitionParams.translate
  in
    { step | transitionParams <- { params | translate <- { translateParams | z <- z }}}


translate : Float -> Float -> Float -> Step -> Step
translate x y z step =
  let
    params =
      step.transitionParams
  in
    { step | transitionParams <- { params | translate <- { x = x, y = y, z = z }}}


rotateX : Float -> Step -> Step
rotateX x step =
  let
    params =
      step.transitionParams

    rotateParams =
      step.transitionParams.rotate
  in
    { step | transitionParams <- { params | rotate <- { rotateParams | x <- x }}}


rotateY : Float -> Step -> Step
rotateY y step =
  let
    params =
      step.transitionParams

    rotateParams =
      step.transitionParams.rotate
  in
    { step | transitionParams <- { params | rotate <- { rotateParams | y <- y }}}


rotateZ : Float -> Step -> Step
rotateZ z step =
  let
    params =
      step.transitionParams

    rotateParams =
      step.transitionParams.rotate
  in
    { step | transitionParams <- { params | rotate <- { rotateParams | z <- z }}}


rotate : Float -> Float -> Float -> Step -> Step
rotate x y z step =
  let
    params =
      step.transitionParams
  in
    { step | transitionParams <- { params | rotate <- { x = x, y = y, z = z }}}


scale : Float -> Step -> Step
scale s step =
  let
    params =
      step.transitionParams
  in
    { step | transitionParams <- { params | scale <- s }}


revert : TransitionParams -> TransitionParams
revert params =
  { rotate =
      { x = -params.rotate.x
      , y = -params.rotate.y
      , z = -params.rotate.z
      }
  , translate =
      { x = -params.translate.x
      , y = -params.translate.y
      , z = -params.translate.z
      }
  , scale = 1 / params.scale
  }


fallback : Html
fallback =
  div
    [ class "fallback-message" ]
    [ p
        [ ]
        [ text "Your browswer "
        , b [ ] [ text "doesn't support the features required"]
        , text
            """
            by elm-impress, so you are presented with a simplified version
            of this presentation.
            """
        ]
    , p
        [ ]
        [ text "For the best experience please use the latest "
        , b [ ] [ text "Chrome" ]
        , text ", "
        , b [ ] [ text "Safari" ]
        , text " or "
        , b [ ] [ text "Firefox" ]
        , text " browser."
        ]
    ]


hint : Html
hint =
  div
    [ class "hint" ]
    [ p [ ] [ text "Use a spacebar or arrow keys to navigate" ] ]


makeUp : Maybe Html -> Html
makeUp maybeHtml =
  case maybeHtml of
    Nothing ->
      div [ style [("display", "none")] ] [ ]

    Just html ->
      html
