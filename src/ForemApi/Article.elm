module ForemApi.Article exposing
    ( Article
    , fetch, fetchBySlug
    , articleDecoder
    )

{-| This module allows you to make API calls to fetch an article and decode it into an Elm records.


# Definition

@docs Article


# API calls

@docs fetch, fetchBySlug


# Decoders

@docs articleDecoder

-}

import ForemApi
import ForemApi.User
import Http
import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Time
import Url.Builder


{-| Representation of an Article record from Forem API. All functions in this module should return an Article record.
-}
type alias Article =
    { typeOf : String
    , id : Int
    , title : String
    , slug : String
    , socialImage : String
    , description : String
    , readingTimeMinutes : Int
    , publishedAt : Time.Posix
    , user : ForemApi.User.User
    , bodyMarkdown : Maybe String
    , bodyHtml : Maybe String
    , tags : List String
    , url : String
    , canonicalUrl : String
    }


{-| Fetch an article by article's ID.

    foremApiConfig : ForemApi.Config
    foremApiConfig =
        ForemApi.Config
            "https://dev.to"
            [ Http.header "accept" "application/vnd.forem.api-v1+json" ]

    cmd : Cmd msg
    cmd =
        ForemApi.Article.fetch foremApiConfig 1208487 msg

-}
fetch : ForemApi.Config -> Int -> (Result Http.Error Article -> msg) -> Cmd msg
fetch apiConfig articleId msg =
    Http.request
        { method = "GET"
        , headers = apiConfig.headers
        , body = Http.emptyBody
        , url =
            Url.Builder.crossOrigin
                apiConfig.baseUrl
                [ "api", "articles", String.fromInt articleId ]
                []
        , expect = Http.expectJson msg articleDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


{-| Fetch an article using author's username and article's unique slug.

    foremApiConfig : ForemApi.Config
    foremApiConfig =
        ForemApi.Config
            "https://dev.to"
            [ Http.header "accept" "application/vnd.forem.api-v1+json" ]

    cmd : Cmd msg
    cmd =
        ForemApi.Article.fetchBySlug foremApiConfig "no_81" "1st-post-2a1" msg

-}
fetchBySlug : ForemApi.Config -> String -> String -> (Result Http.Error Article -> msg) -> Cmd msg
fetchBySlug apiConfig username articleSlug msg =
    Http.request
        { method = "GET"
        , headers = apiConfig.headers
        , body = Http.emptyBody
        , url =
            Url.Builder.crossOrigin
                apiConfig.baseUrl
                [ "api", "articles", username, articleSlug ]
                []
        , expect = Http.expectJson msg articleDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


{-| Decoder to decode article data from Forem Api into an Article record.
-}
articleDecoder : Decoder Article
articleDecoder =
    Decode.succeed Article
        |> required "type_of" Decode.string
        |> required "id" Decode.int
        |> required "title" Decode.string
        |> required "slug" Decode.string
        |> required "social_image" Decode.string
        |> required "description" Decode.string
        |> required "reading_time_minutes" Decode.int
        |> required "published_at" Iso8601.decoder
        |> required "user" ForemApi.User.userDecoder
        |> optional "body_markdown" (Decode.nullable Decode.string) Nothing
        |> optional "body_html" (Decode.nullable Decode.string) Nothing
        |> required "tags" tagsDecoder
        |> required "url" Decode.string
        |> required "canonical_url" Decode.string


{-| Decoder to decode tags data from Forem Api into a List of string.
-}
tagsDecoder : Decoder (List String)
tagsDecoder =
    Decode.oneOf
        [ Decode.list Decode.string
        , Decode.map (\str -> String.split "," str) Decode.string
        ]
