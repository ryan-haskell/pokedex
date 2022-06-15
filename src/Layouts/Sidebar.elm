module Layouts.Sidebar exposing (layout)

import Components.Sidebar
import Html exposing (Html)
import Html.Attributes as Attr
import View exposing (View)


layout : { page : View msg } -> View msg
layout { page } =
    { title = page.title
    , body =
        [ Html.div
            [ Attr.class "layout" ]
            [ Components.Sidebar.view
            , Html.div [ Attr.class "page" ] page.body
            ]
        ]
    }
