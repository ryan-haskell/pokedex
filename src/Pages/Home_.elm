module Pages.Home_ exposing (Model, Msg, page)

import Components.Header
import ElmLand.Layout exposing (Layout)
import ElmLand.Page exposing (Page)
import Fetchable exposing (Fetchable)
import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Json.Decode
import View exposing (View)


layout : Layout
layout =
    ElmLand.Layout.Sidebar


page : Page Model Msg
page =
    ElmLand.Page.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { pokemon : Fetchable (List Pokemon)
    }


init : ( Model, Cmd Msg )
init =
    ( { pokemon = Fetchable.Loading
      }
    , Http.get
        { url = "http://localhost:5000/api/v2/pokemon?limit=151"
        , expect = Http.expectJson FetchedPokemon pokemonEndpointDecoder
        }
    )



-- UPDATE


type Msg
    = FetchedPokemon (Result Http.Error (List Pokemon))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchedPokemon result ->
            ( { model | pokemon = Fetchable.fromResult result }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pokedex"
    , body =
        [ case model.pokemon of
            Fetchable.Loading ->
                Html.text ""

            Fetchable.Success pokemonList ->
                let
                    viewPokemonTile : Pokemon -> Html Msg
                    viewPokemonTile pokemon =
                        Html.a [ Attr.href ("/pokemon/" ++ pokemon.name) ]
                            [ Html.img [ Attr.class "sprite", Attr.src (toPokemonSpriteUrl pokemon) ] []
                            ]
                in
                Html.div [ Attr.class "section__grid" ] (List.map viewPokemonTile pokemonList)

            Fetchable.Failure reason ->
                Html.text reason
        ]
    }



-- POKEAPI STUFF


pokemonEndpointDecoder : Json.Decode.Decoder (List Pokemon)
pokemonEndpointDecoder =
    Json.Decode.field "results"
        (Json.Decode.list pokemonDecoder)


type alias Pokemon =
    { id : Int
    , name : String
    }


pokemonDecoder : Json.Decode.Decoder Pokemon
pokemonDecoder =
    Json.Decode.map2 Pokemon
        pokemonIdDecoder
        (Json.Decode.field "name" Json.Decode.string)


toPokemonSpriteUrl : Pokemon -> String
toPokemonSpriteUrl pokemon =
    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/"
        ++ String.fromInt pokemon.id
        ++ ".png"


{-|

    "https://pokeapi.co/api/v2/pokemon/1/" -> 1

-}
pokemonIdDecoder : Json.Decode.Decoder Int
pokemonIdDecoder =
    Json.Decode.field "url" Json.Decode.string
        |> Json.Decode.andThen
            (\url ->
                let
                    id : Maybe Int
                    id =
                        url
                            |> String.dropLeft
                                (String.length "https://pokeapi.co/api/v2/pokemon/")
                            |> String.dropRight
                                (String.length "/")
                            |> String.toInt
                in
                case id of
                    Just int ->
                        Json.Decode.succeed int

                    Nothing ->
                        Json.Decode.fail ("Could not find ID in " ++ url)
            )
