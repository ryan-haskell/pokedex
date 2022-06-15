module Components.Header exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr


view : { title : String, subtitle : String } -> Html msg
view options =
    Html.div [ Attr.class "column gap-8" ]
        [ Html.h1 [ Attr.class "font__title" ]
            [ Html.text options.title ]
        , Html.h2 [ Attr.class "font__subtitle" ]
            [ Html.text options.subtitle ]
        ]
