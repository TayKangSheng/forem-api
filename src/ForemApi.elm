module ForemApi exposing (Config)

{-| This module contains shared functions to call Forem Api


# Definition

@docs Config

-}

import Http


{-| Shared config for all API calls

    Config
        "https://dev.to"
        [ Http.header "accept" "application/vnd.forem.api-v1+json" ]

-}
type alias Config =
    { baseUrl : String
    , headers : List Http.Header
    }
