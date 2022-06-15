module Components.TileSection exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr


type alias Tile =
    { title : String
    , subtitle : String
    , url : String
    }


view :
    { title : String
    , tiles : List Tile
    }
    -> Html msg
view options =
    Html.section [ Attr.class "section" ]
        [ Html.h3 [ Attr.class "section__title" ]
            [ Html.text options.title ]
        , Html.div [ Attr.class "section__grid" ]
            (List.map viewPokemon (List.range 1 151))
        ]


viewPokemon : Int -> Html msg
viewPokemon id =
    let
        url : String
        url =
            "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" ++ String.fromInt id ++ ".png"
    in
    Html.img [ Attr.src url, Attr.class "sprite" ] []



-- Html.a [ Attr.class "tile", Attr.href tile.url ]
--     [ Html.h4 [ Attr.class "tile__title" ]
--         [ Html.text tile.title ]
--     , Html.p [ Attr.class "tile__subtitle" ]
--         [ Html.text tile.subtitle ]
--     ]
