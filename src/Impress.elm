module Impress where

import Html exposing (Html, div)
import Html.Attributes exposing (style, id, classList)
import Html.Events exposing (onWithOptions, defaultOptions)
import Signal exposing (Mailbox, mailbox, foldp)
import Json.Decode as Json
import Window
import Keyboard exposing (keysDown, KeyCode)
import Time exposing (Time)
import Effects exposing (Effects, Never)
import Task exposing (succeed, sleep, andThen)
import Set exposing (..)
import History exposing (setPath, replacePath)
import String
import StartApp
import Impress.Config exposing (..)

import Debug exposing (log)


update : String -> List Step -> Action -> DeckState -> (DeckState, Effects Action)
update pathName staticSteps action deck =
  let
    noop =
      (deck, Effects.none)

    currentIx =
      deck.currentStep.ix

    setMove actionSource targetIx =
      if deck.transitioning
        then
          case actionSource of
            Hash ->
              moveTo targetIx actionSource

            _ ->  -- Kb or Click
              (deck, Effects.none)
        else
          moveTo targetIx actionSource

    moveTo targetIx actionSource =
      let
        targetStep =
          getStep targetIx staticSteps

        transitionTime =
          config.duration + computeDelay deck.currentStep targetStep

        newDeck =
          { deck
          | currentStep <- getStep targetIx staticSteps
          , lastScaleParam <-
              if targetIx /= currentIx
                then deck.currentStep.transitionParams.scale
                else deck.lastScaleParam
          , visitedIxs <- Set.insert currentIx deck.visitedIxs
          , transitioning <- True
          }
      in
        ( newDeck
        , Effects.task
            (sleep transitionTime
              `andThen` \_ -> succeed (EnterStep targetIx actionSource))
        )
  in
    case action of
      NoOp ->
        noop

      KeyDown keycodes ->
        let
          fwd =
            fromList [ 9, 32, 33, 38, 39 ]

          rwd =
            fromList [ 34, 37, 40 ]

          setTargetIx nextIx =
            if | nextIx > deck.n -> 1
               | nextIx < 1 -> deck.n
               | otherwise -> nextIx

          next =
            setMove Kb << setTargetIx
        in
          if isEmpty <| intersect keycodes rwd
            then
              if isEmpty <| intersect keycodes fwd
                then noop
                else next <| currentIx + 1
            else
              next <| currentIx - 1

      EnterStep ix actionSource ->
        let
          actualDeck =
            if currentIx /= ix
              then deck
              else { deck | transitioning <- False }

          effects =
            case actionSource of
              Hash ->
                Effects.none

              _ -> -- Kb or Click
                Effects.task
                  (setPath (pathName ++ "/#/" ++ actualDeck.currentStep.id)
                    `andThen` always (succeed NoOp))
        in
          (actualDeck, effects)

      GoTo ix ->
        if ix /= currentIx then setMove Click ix else noop

      GoToId hash ->
        case getFromId (String.dropLeft 2 (log "hash" hash)) staticSteps of
          Just step ->
            if step.ix /= currentIx
              then setMove Hash step.ix
              else noop

          Nothing ->
            noop

      NewScale winDim ->
        ({ deck | scale <- windowScale winDim }, Effects.none)


normalDelay : Time
normalDelay =
  config.duration / 2


computeDelay : Step -> Step -> Time
computeDelay currentStep targetStep =
  let
    currentParams =
      currentStep.transitionParams

    targetParams =
      targetStep.transitionParams
  in
    if currentParams.scale == targetParams.scale ||
       { currentParams - scale } == { targetParams - scale }
        then 0
        else normalDelay


init : String -> String -> List Step -> (DeckState, Effects Action)
init pathName hashFromAddressBar staticSteps =
  let
    firstStep =
      getStep 1 staticSteps

    initialStep =
      case getFromId (String.dropLeft 2 hashFromAddressBar) staticSteps of
        Nothing ->
          firstStep

        Just step ->
          step
  in
    ( { currentStep = initialStep
      , scale = 1
      , n = List.length staticSteps
      , lastScaleParam = 1
      , visitedIxs = Set.empty
      , transitioning = False
      }
    , Effects.task
        (replacePath ((log "initial pathname" pathName) ++ "/#/" ++ initialStep.id)
          `andThen` always (succeed NoOp))
    )


getFromId : String -> List Step -> Maybe Step
getFromId id staticSteps =
  case staticSteps of
    [ ] ->
      Nothing

    step::others ->
      if id == step.id
        then Just step
        else getFromId id others


asStatic : List Step -> List Step
asStatic steps =
  let
    rollout ix step =
      let
        pos =
          ix + 1

        id_ =
          if step.id == "" then "step-" ++ toString pos else step.id

        classList =
          "step " ++ step.classes
      in
        { step
        | id <- id_
        , classes <- classList
        , attrs <- [ Html.Attributes.id id_ ] ++ step.attrs
        , ix <- pos
        }
  in
    List.indexedMap rollout steps


getStep : Int -> List Step -> Step
getStep ix staticSteps =
  let
    (Just step) =
      List.head <| List.drop (ix - 1) staticSteps
  in
    step


asDynamic : List Step -> Signal.Address Action -> DeckState -> List Html
asDynamic staticSteps address deck =
  let
    toHtml { tag, classes, attrs, html, ix, transitionParams } =
      let
        isActive =
          ix == deck.currentStep.ix

        classList =
          classes
            ++ ( if | isActive ->
                        " active" ++ if deck.transitioning then "" else " present"
                    | Set.member ix deck.visitedIxs -> " past"
                    | otherwise -> " future" )
      in
        tag
          ( [ Html.Attributes.class classList
            , style <| stepCss transitionParams
            , onWithOptions
                "click"
                { defaultOptions| preventDefault <- not isActive }
                Json.value
                (\_ -> Signal.message address (GoTo ix))
            ] ++ attrs )
          html
  in
    List.map toHtml staticSteps


view : Context -> Signal.Address Action -> DeckState -> Html
view context address deck =
  div
    [ classList
      [ ("impress-supported impress-enabled impress-on-" ++ deck.currentStep.id)
          => context.impressSupported
      , "impress-not-supported" => not context.impressSupported ]
    ]
    [ fallback
    , makeUp <| fst context.maybeHtml
    , if context.impressSupported
        then rootAndCanvas context.staticSteps address deck
        else div
              [ id "impress" ]
              ( List.map
                  ( \{ tag, classes, attrs, html } ->
                      tag (Html.Attributes.class classes :: attrs) html )
                  context.staticSteps )
    , makeUp <| snd context.maybeHtml
    ]


rootAndCanvas : List Step -> Signal.Address Action -> DeckState -> Html
rootAndCanvas staticSteps address deck =
  let
    params =
      revert deck.currentStep.transitionParams

    zoomingIn =
      deck.currentStep.transitionParams.scale <= deck.lastScaleParam
  in
    div
      [ id "impress"
      , style
          <| rootCss deck.scale
              ++ wrapperCss
              ++ rootTransitionCss (deck.scale * params.scale) zoomingIn
      ]
      [ div
          [ style (wrapperCss ++ canvasTransitionCss params zoomingIn) ]
          ( asDynamic staticSteps address deck )
      ]


(=>) = (,)


wrapperCss : List (String, String)
wrapperCss =
  [ "position" => "absolute"
  , "transformOrigin" => "top left"
  , "transition" => "all 0s ease-in-out"
  , "transformStyle" => "preserve-3d"
  ]


rootCss : Float -> List (String, String)
rootCss scale =
  [ "top" => "50%"
  , "left" => "50%"
  , "transform" => ("perspective(" ++ toString (config.perspective / scale)
                    ++ "px) scale(" ++ toString scale ++ ")")
  ]


durationString : String
durationString =
  toString config.duration ++ "ms"


rootTransitionCss : Float -> Bool -> List (String, String)
rootTransitionCss targetScale zoomingIn =
  [ "transform" => ("perspective(" ++ toString (config.perspective / targetScale)
                    ++ "px) scale(" ++ toString targetScale ++ ")")
  , "transitionDuration" => durationString
  , "transitionDelay" => ((toString <| if zoomingIn then normalDelay else 0) ++ "ms")
  ]


canvasTransitionCss : TransitionParams -> Bool -> List (String, String)
canvasTransitionCss params zoomingIn =
  [ "transform" => (rotate params.rotate True ++ translate params.translate)
  , "transitionDuration" => durationString
  , "transitionDelay" => ((toString <| if zoomingIn then 0 else normalDelay) ++ "ms")
  ]


stepCss : TransitionParams -> List (String, String)
stepCss params =
  [ "position" => "absolute"
  , "transform" => ("translate(-50%, -50%)"
                      ++ translate params.translate
                      ++ rotate params.rotate False
                      ++ " scale(" ++ toString params.scale ++ ")")
  , "transformStyle" => "preserve-3d"
  , "cursor" => "pointer"
  ]


translate : CssTransformVector -> String
translate vector =
  " translate3d(" ++ toString vector.x ++ "px,"
    ++ toString vector.y ++ "px,"
    ++ toString vector.z ++ "px)"


rotate : CssTransformVector -> Bool -> String
rotate vector revert =
  let
    rx =
      " rotateX(" ++ toString vector.x ++ "deg)"

    ry =
      " rotateY(" ++ toString vector.y ++ "deg)"

    rz =
      " rotateZ(" ++ toString vector.z ++ "deg)"
  in
    if revert
      then rz ++ ry ++ rx
      else rx ++ ry ++ rz


windowScale : (Int, Int) -> Float
windowScale (winWidth, winHeight) =
  let
    hScale =
      toFloat winHeight / config.height

    wScale =
      toFloat winWidth / config.width
  in
    clamp config.minScale config.maxScale <| min hScale wScale


-- INPUT SIGNALS

winScaleSig : Signal Action
winScaleSig =
  Signal.map NewScale Window.dimensions


kbSig : Signal Action
kbSig =
  Signal.map KeyDown keysDown


hashSig : Signal Action
hashSig =
  Signal.map GoToId History.hash


signals : List (Signal Action)
signals =
  [ kbSig, hashSig, winScaleSig ]
