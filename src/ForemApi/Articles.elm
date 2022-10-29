module ForemApi.Articles exposing
    ( QueryParameters
    , blankQueryParameters
    , fetch
    )

{-| This module allows you to make API calls to fetch a list of articles and decode it into an Elm records.


# Definition

@docs QueryParameters


# Helper functions

@docs blankQueryParameters


# API calls

@docs fetch

-}

import ForemApi
import ForemApi.Article exposing (Article)
import Http
import Json.Decode as D exposing (Decoder)
import Url.Builder


{-| A set of predefined query parameters used to fetch a list of articles.
-}
type alias QueryParameters =
    { username : Maybe String
    , page : Maybe Int
    , perPage : Maybe Int
    , tag : Maybe String
    , tags : Maybe (List String)
    , tagsExclude : Maybe (List String)
    }


{-| Helper method to generate a blank set of QueryParameters
-}
blankQueryParameters : QueryParameters
blankQueryParameters =
    QueryParameters Nothing Nothing Nothing Nothing Nothing Nothing


{-| Fetch a list of articles using a set of predefined filters represented by query parameters.

    foremApiConfig : ForemApi.Config
    foremApiConfig =
        ForemApi.Config
            "https://dev.to"
            [ Http.header "accept" "application/vnd.forem.api-v1+json" ]

    queryParameters : QueryParamters
    queryParameters =
        blankQueryParamters

    cmd : Cmd msg
    cmd =
        ForemApi.Articles.fetch
            foremApiConfig
            { queryParameters | tag = "elm" }
            msg

-}
fetch : ForemApi.Config -> QueryParameters -> (Result Http.Error (List Article) -> msg) -> Cmd msg
fetch apiConfig queryParameters msg =
    let
        queryParams : List Url.Builder.QueryParameter
        queryParams =
            []
                |> List.append (Maybe.withDefault [] (Maybe.map (\u -> [ Url.Builder.string "username" u ]) queryParameters.username))
                |> List.append (Maybe.withDefault [] (Maybe.map (\u -> [ Url.Builder.int "page" u ]) queryParameters.page))
                |> List.append (Maybe.withDefault [] (Maybe.map (\u -> [ Url.Builder.int "per_page" u ]) queryParameters.perPage))
                |> List.append (Maybe.withDefault [] (Maybe.map (\tag -> [ Url.Builder.string "tag" tag ]) queryParameters.tag))
                |> List.append (Maybe.withDefault [] (Maybe.map (\tags -> [ Url.Builder.string "tags" (String.join "," tags) ]) queryParameters.tags))
                |> List.append (Maybe.withDefault [] (Maybe.map (\tags -> [ Url.Builder.string "tags_exclude" (String.join "," tags) ]) queryParameters.tagsExclude))
    in
    Http.request
        { method = "GET"
        , headers = apiConfig.headers
        , body = Http.emptyBody
        , url =
            Url.Builder.crossOrigin
                apiConfig.baseUrl
                [ "api", "articles" ]
                queryParams
        , expect = Http.expectJson msg articlesDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


{-| Decoder to decode articles data from Forem Api into a list of Article record.
-}
articlesDecoder : Decoder (List Article)
articlesDecoder =
    D.list ForemApi.Article.articleDecoder
