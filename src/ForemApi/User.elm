module ForemApi.User exposing
    ( User
    , userDecoder
    )

{-| This module allows you decode user data into an Elm records.


# Definition

@docs User


# Decoders

@docs userDecoder

-}

import Json.Decode as D exposing (Decoder)


{-| Representation of an User record from Forem API.
-}
type alias User =
    { userId : Int
    , username : String
    , name : String
    , twitterUsername : Maybe String
    , githubUsername : Maybe String
    , websiteUrl : Maybe String
    , profileImage : Maybe String
    , profileImage90 : Maybe String
    }


{-| Decoder to decode user data from Forem Api into a User record.
-}
userDecoder : Decoder User
userDecoder =
    D.map8 User
        (D.field "user_id" D.int)
        (D.field "username" D.string)
        (D.field "name" D.string)
        (D.maybe (D.field "twitter_username" D.string))
        (D.maybe (D.field "github_username" D.string))
        (D.maybe (D.field "website_url" D.string))
        (D.maybe (D.field "profile_image" D.string))
        (D.maybe (D.field "profile_image_90" D.string))
