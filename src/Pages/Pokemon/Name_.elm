module Pages.Pokemon.Name_ exposing (Model, Msg, page)

import Domain.PokemonType exposing (PokemonType)
import ElmLand.Layout exposing (Layout)
import ElmLand.Page exposing (Page)
import Fetchable exposing (Fetchable)
import Html exposing (Html)
import Html.Attributes exposing (alt, class, href, src)
import Http
import Json.Decode
import Utils.Id
import View exposing (View)


layout : Layout
layout =
    ElmLand.Layout.Sidebar


page : { name : String } -> Page Model Msg
page params =
    ElmLand.Page.element
        { init = init params
        , update = update
        , view = view params
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { pokemon : Fetchable Pokemon
    , species : Fetchable PokemonSpecies
    , evolutionChain : Fetchable EvolutionChain
    }


init : { name : String } -> ( Model, Cmd Msg )
init params =
    ( { pokemon = Fetchable.Loading
      , species = Fetchable.Loading
      , evolutionChain = Fetchable.Loading
      }
    , Cmd.batch
        [ Http.get
            { url = "http://localhost:5000/api/v2/pokemon/" ++ params.name
            , expect = Http.expectJson FetchedPokemon decoder
            }
        , Http.get
            { url = "http://localhost:5000/api/v2/pokemon-species/" ++ params.name
            , expect = Http.expectJson FetchedPokemonSpecies pokemonSpeciesDecoder
            }
        ]
    )



-- UPDATE


type Msg
    = FetchedPokemon (Result Http.Error Pokemon)
    | FetchedPokemonSpecies (Result Http.Error PokemonSpecies)
    | FetchedEvolutionChain (Result Http.Error EvolutionChain)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchedPokemon result ->
            ( { model | pokemon = Fetchable.fromResult result }
            , Cmd.none
            )

        FetchedPokemonSpecies result ->
            ( { model | species = Fetchable.fromResult result }
            , case result of
                Ok { evolutionChainId } ->
                    Http.get
                        { url = "https://pokeapi.co/api/v2/evolution-chain/" ++ evolutionChainId
                        , expect = Http.expectJson FetchedEvolutionChain evolutionChainDecoder
                        }

                Err _ ->
                    Cmd.none
            )

        FetchedEvolutionChain result ->
            ( { model | evolutionChain = Fetchable.fromResult result }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : { name : String } -> Model -> View Msg
view params model =
    case ( model.pokemon, model.species ) of
        ( Fetchable.Loading, _ ) ->
            { title = "Pokedex"
            , body =
                [ Html.text "Loading..."
                ]
            }

        ( _, Fetchable.Loading ) ->
            { title = "Pokedex"
            , body = [ Html.text "Loading..." ]
            }

        ( Fetchable.Success pokemon, Fetchable.Success species ) ->
            { title = species.name ++ " | Pokedex"
            , body =
                [ --Html.p [] [ Html.text (Debug.toString model) ]
                  --,
                  Html.div [ class "column gap-32" ]
                    [ Html.div []
                        [ Html.h1 [ class "section__title" ] [ Html.text species.name ]
                        , Html.div [ class "row gap-8" ] (List.map Domain.PokemonType.viewBadge pokemon.types)
                        , Html.img [ alt pokemon.name, src pokemon.spriteUrl ] []
                        ]
                    , viewEvolutionChain model.evolutionChain
                    ]
                ]
            }

        _ ->
            { title = "Pokemon Not Found | Pokedex"
            , body =
                [ Html.div [ class "column gap-16" ]
                    [ Html.h1 [ class "section__title" ] [ Html.text "pokemon not found..." ]
                    , Html.a [ class "link", href "/pokemon/bulbasaur" ] [ Html.text "Here's a Bulbasaur?" ]
                    ]
                ]
            }


viewTypeBadge : String -> Html Msg
viewTypeBadge typeName =
    Html.span [ class "badge" ] [ Html.text typeName ]


viewEvolutionChain : Fetchable EvolutionChain -> Html Msg
viewEvolutionChain fetchable =
    case fetchable of
        Fetchable.Loading ->
            Html.text ""

        Fetchable.Failure _ ->
            Html.text ""

        Fetchable.Success pokemon ->
            Html.div [ class "section" ]
                [ Html.h3 [ class "section__title" ] [ Html.text "Evolutions" ]
                , Html.div [ class "section__grid" ] (List.map viewPokemonPreview pokemon)
                ]


viewPokemonPreview : PokemonPreview -> Html Msg
viewPokemonPreview pokemon =
    Html.a [ href (Utils.Id.toPokemonDetailUrl pokemon.name) ]
        [ Html.img
            [ class "sprite"
            , src (Utils.Id.toSpriteUrl pokemon.id)
            , alt pokemon.name
            ]
            []
        , Html.p [ class "sprite__label" ] [ Html.text pokemon.name ]
        ]



-- JSON DECODERS


type alias Pokemon =
    { id : Int
    , name : String
    , spriteUrl : String
    , types : List PokemonType
    }


decoder : Json.Decode.Decoder Pokemon
decoder =
    Json.Decode.map4 Pokemon
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.at [ "sprites", "other", "official-artwork", "front_default" ] Json.Decode.string)
        (Json.Decode.field "types" (Json.Decode.list Domain.PokemonType.decoder))



-- POKEMON SPECIES


type alias PokemonSpecies =
    { name : String
    , evolutionChainId : String
    }


pokemonSpeciesDecoder : Json.Decode.Decoder PokemonSpecies
pokemonSpeciesDecoder =
    Json.Decode.map2 PokemonSpecies
        nameDecoder
        (Json.Decode.at [ "evolution_chain", "url" ] evolutionChainIdDecoder)


nameDecoder : Json.Decode.Decoder String
nameDecoder =
    Json.Decode.field "names" (Json.Decode.list languageNameDecoder)
        |> Json.Decode.andThen fromLanguageNamesToEnglishName


type alias LanguageName =
    { languageCode : String
    , name : String
    }


fromLanguageNamesToEnglishName : List LanguageName -> Json.Decode.Decoder String
fromLanguageNamesToEnglishName languageNames =
    case
        languageNames
            |> List.filter (\{ languageCode } -> languageCode == "en")
            |> List.head
    of
        Just { name } ->
            Json.Decode.succeed name

        Nothing ->
            Json.Decode.fail "Couldn't find a name!"


languageNameDecoder : Json.Decode.Decoder LanguageName
languageNameDecoder =
    Json.Decode.map2 LanguageName
        (Json.Decode.at [ "language", "name" ] Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)


evolutionChainIdDecoder : Json.Decode.Decoder String
evolutionChainIdDecoder =
    Utils.Id.urlToIdDecoder { url = "https://pokeapi.co/api/v2/evolution-chain/" }



-- EVOLUTION


type alias EvolutionChain =
    List PokemonPreview


type alias PokemonPreview =
    { id : String
    , name : String
    }


type NestedChain
    = NestedChain NestedChainStuff


type alias NestedChainStuff =
    { id : String
    , name : String
    , evolvesTo : List NestedChain
    }


evolutionChainDecoder : Json.Decode.Decoder EvolutionChain
evolutionChainDecoder =
    Json.Decode.field "chain" nestedChainDecoder
        |> Json.Decode.map flattenNestedChainThingie
        |> Json.Decode.map excludeBeyondOriginal151


excludeBeyondOriginal151 : List PokemonPreview -> List PokemonPreview
excludeBeyondOriginal151 pokemon =
    List.filter
        (\{ id } ->
            case String.toInt id of
                Just num ->
                    if num > 151 then
                        False

                    else
                        True

                Nothing ->
                    False
        )
        pokemon


flattenNestedChainThingie : NestedChain -> EvolutionChain
flattenNestedChainThingie (NestedChain chain) =
    [ { id = chain.id, name = chain.name } ]
        ++ List.concatMap flattenNestedChainThingie chain.evolvesTo


nestedChainDecoder : Json.Decode.Decoder NestedChain
nestedChainDecoder =
    Json.Decode.map NestedChain
        (Json.Decode.map3 NestedChainStuff
            (Json.Decode.at [ "species", "url" ] pokemonSpeciesIdDecoder)
            (Json.Decode.at [ "species", "name" ] Json.Decode.string)
            (Json.Decode.field "evolves_to" (Json.Decode.list (Json.Decode.lazy (\_ -> nestedChainDecoder))))
        )


pokemonSpeciesIdDecoder : Json.Decode.Decoder String
pokemonSpeciesIdDecoder =
    Utils.Id.urlToIdDecoder { url = "https://pokeapi.co/api/v2/pokemon-species/" }
