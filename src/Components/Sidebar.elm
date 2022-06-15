module Components.Sidebar exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr


type alias Link =
    { image : String
    , label : String
    , url : String
    }


links : List Link
links =
    [ { image = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png"
      , label = "Pokemon"
      , url = "/pokemon"
      }
    ]


view : Html msg
view =
    Html.aside [ Attr.class "sidebar" ]
        [ Html.a [ Attr.class "sidebar__brand", Attr.href "/" ] [ Html.text "Pokédex" ]
        , Html.div [ Attr.class "sidebar__links" ]
            (List.map viewLink links)
        ]


viewLink : Link -> Html msg
viewLink link =
    Html.a [ Attr.class "sidebar__link", Attr.href link.url ]
        [ Html.span
            [ Attr.class "sidebar__link-image"
            , Attr.style "background-image"
                ("url('$1')"
                    |> String.replace "$1" link.image
                )
            ]
            []
        , Html.span [ Attr.class "sidebar__link-label" ] [ Html.text link.label ]
        ]
