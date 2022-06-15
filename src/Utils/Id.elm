module Utils.Id exposing (toPokemonDetailUrl, toSpriteUrl, urlToIdDecoder)

import Json.Decode


fromPokeApiUrl : { prefix : String } -> String -> String
fromPokeApiUrl { prefix } url =
    if String.startsWith prefix url then
        url
            |> String.dropLeft (String.length prefix)
            |> String.dropRight (String.length "/")

    else
        url


urlToIdDecoder : { url : String } -> Json.Decode.Decoder String
urlToIdDecoder { url } =
    Json.Decode.string
        |> Json.Decode.map (fromPokeApiUrl { prefix = url })


toPokemonDetailUrl : String -> String
toPokemonDetailUrl id =
    "/pokemon/" ++ id


toSpriteUrl : String -> String
toSpriteUrl id =
    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/" ++ id ++ ".png"
