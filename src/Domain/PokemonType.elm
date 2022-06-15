module Domain.PokemonType exposing (PokemonType, decoder, viewBadge)

import Html exposing (Html)
import Html.Attributes exposing (class, style)
import Json.Decode


type PokemonType
    = Normal
    | Fighting
    | Flying
    | Poison
    | Ground
    | Rock
    | Bug
    | Ghost
    | Steel
    | Fire
    | Water
    | Grass
    | Electric
    | Psychic
    | Ice
    | Dragon
    | Dark
    | Fairy
    | Shadow
    | Unknown


decoder : Json.Decode.Decoder PokemonType
decoder =
    Json.Decode.at [ "type", "name" ] Json.Decode.string
        |> Json.Decode.map fromString


fromString : String -> PokemonType
fromString str =
    case str of
        "normal" ->
            Normal

        "fighting" ->
            Fighting

        "flying" ->
            Flying

        "poison" ->
            Poison

        "ground" ->
            Ground

        "rock" ->
            Rock

        "bug" ->
            Bug

        "ghost" ->
            Ghost

        "steel" ->
            Steel

        "fire" ->
            Fire

        "water" ->
            Water

        "grass" ->
            Grass

        "electric" ->
            Electric

        "psychic" ->
            Psychic

        "ice" ->
            Ice

        "dragon" ->
            Dragon

        "dark" ->
            Dark

        "fairy" ->
            Fairy

        "shadow" ->
            Shadow

        _ ->
            Unknown


toString : PokemonType -> String
toString pokemonType =
    case pokemonType of
        Normal ->
            "Normal"

        Fighting ->
            "Fighting"

        Flying ->
            "Flying"

        Poison ->
            "Poison"

        Ground ->
            "Ground"

        Rock ->
            "Rock"

        Bug ->
            "Bug"

        Ghost ->
            "Ghost"

        Steel ->
            "Steel"

        Fire ->
            "Fire"

        Water ->
            "Water"

        Grass ->
            "Grass"

        Electric ->
            "Electric"

        Psychic ->
            "Psychic"

        Ice ->
            "Ice"

        Dragon ->
            "Dragon"

        Dark ->
            "Dark"

        Fairy ->
            "Fairy"

        Shadow ->
            "Shadow"

        Unknown ->
            "Unknown"


toHexColor : PokemonType -> String
toHexColor type_ =
    case type_ of
        Unknown ->
            "#fff"

        Normal ->
            "#A8A77A"

        Fire ->
            "#EE8130"

        Water ->
            "#6390F0"

        Electric ->
            "#F7D02C"

        Grass ->
            "#7AC74C"

        Ice ->
            "#96D9D6"

        Fighting ->
            "#C22E28"

        Poison ->
            "#A33EA1"

        Ground ->
            "#E2BF65"

        Flying ->
            "#A98FF3"

        Psychic ->
            "#F95587"

        Bug ->
            "#A6B91A"

        Rock ->
            "#B6A136"

        Ghost ->
            "#735797"

        Dragon ->
            "#6F35FC"

        Dark ->
            "#705746"

        Steel ->
            "#B7B7CE"

        Fairy ->
            "#D685AD"

        Shadow ->
            "#333"


viewBadge : PokemonType -> Html msg
viewBadge pokemonType =
    Html.div
        [ class "badge"
        , style "background-color" (toHexColor pokemonType)
        ]
        [ Html.text (toString pokemonType) ]
