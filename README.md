# Forem Api

A set of abstractions to interface with Forem Api using Elm. This package does not assume what you are trying to build and only seek to save you the time writing all the boiler plate code to interface with the API.

## Basic Usage

```elm
module Main exposing (..)

import Browser
import ForemApi
import ForemApi.Article
import ForemApi.Articles
import Html exposing (Html)
import Http exposing (Error)


type Msg
    = GotArticleResponse (Result Http.Error ForemApi.Article.Article)
    | GotArticlesResponse (Result Http.Error (List ForemApi.Article.Article))


type alias Model =
    { article : Maybe ForemApi.Article.Article
    , articles : Maybe (List ForemApi.Article.Article)
    , error : Maybe Error
    }


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : flags -> ( Model, Cmd Msg )
init _ =
    let
        foremApiConfig : ForemApi.Config
        foremApiConfig =
            ForemApi.Config
                "https://dev.to"
                [ Http.header "accept" "application/vnd.forem.api-v1+json" ]

        articlesQueryParameters : ForemApi.Articles.QueryParameters
        articlesQueryParameters =
            ForemApi.Articles.blankQueryParameters
    in
    ( Model Nothing Nothing Nothing
    , Cmd.batch
        [ ForemApi.Articles.fetch
            foremApiConfig
            { articlesQueryParameters | tag = Just "newyearresolutions" }
            GotArticlesResponse
        , ForemApi.Article.fetch
            foremApiConfig
            1198406
            GotArticleResponse
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotArticleResponse result ->
            case result of
                Ok article ->
                    ( { model | article = Just article }, Cmd.none )

                Err error ->
                    ( { model | error = Just error }, Cmd.none )

        GotArticlesResponse result ->
            case result of
                Ok articles ->
                    ( { model | articles = Just articles }, Cmd.none )

                Err error ->
                    ( { model | error = Just error }, Cmd.none )


view : Model -> Html Msg
view _ =
    Debug.todo "view"


subscriptions : model -> Sub msg
subscriptions _ =
    Debug.todo "subscriptions"
```
