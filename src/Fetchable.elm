module Fetchable exposing (Fetchable(..), fromResult)

import Http


type Fetchable value
    = Loading
    | Success value
    | Failure String


fromResult : Result Http.Error value -> Fetchable value
fromResult result =
    case result of
        Err httpError ->
            Failure (toUserFriendlyMessage httpError)

        Ok pokemonList ->
            Success pokemonList



-- INTERNALS


toUserFriendlyMessage : Http.Error -> String
toUserFriendlyMessage httpError =
    case httpError of
        Http.BadUrl _ ->
            "Something is wrong with the request"

        Http.Timeout ->
            "Server took too long to respond"

        Http.NetworkError ->
            "Could not connect to server"

        Http.BadStatus status ->
            "Server returned a " ++ String.fromInt status ++ " code"

        Http.BadBody reason ->
            let
                _ =
                    Debug.log "JSON failed to decode" reason
            in
            "Server returned unexpected response"
