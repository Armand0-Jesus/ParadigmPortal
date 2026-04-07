module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h3, input, label, li, option, p, select, span, text, ul)
import Html.Attributes exposing (class, placeholder, selected, step, type_, value)
import Html.Events exposing (onClick, onInput)
import String


type EntryKind
    = Income
    | Expense


type alias Entry =
    { id : Int
    , kind : EntryKind
    , description : String
    , amount : Float
    }


type alias Model =
    { nextId : Int
    , kindInput : EntryKind
    , descriptionInput : String
    , amountInput : String
    , entries : List Entry
    , feedback : String
    , hasError : Bool
    }


type Msg
    = SetKind String
    | SetDescription String
    | SetAmount String
    | AddEntry
    | RemoveEntry Int


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initModel
        , view = view
        , update = update
        }


initModel : Model
initModel =
    { nextId = 1
    , kindInput = Income
    , descriptionInput = ""
    , amountInput = ""
    , entries = []
    , feedback = "Agrega ingresos y gastos para calcular tu balance."
    , hasError = False
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetKind rawKind ->
            { model | kindInput = parseKind rawKind }

        SetDescription rawDescription ->
            { model | descriptionInput = rawDescription }

        SetAmount rawAmount ->
            { model | amountInput = rawAmount }

        AddEntry ->
            addEntry model

        RemoveEntry entryId ->
            let
                remaining =
                    List.filter (\entry -> entry.id /= entryId) model.entries
            in
            { model
                | entries = remaining
                , feedback = "Entrada eliminada."
                , hasError = False
            }


addEntry : Model -> Model
addEntry model =
    let
        cleanDescription =
            String.trim model.descriptionInput
    in
    if cleanDescription == "" then
        { model | feedback = "Escribe una descripcion.", hasError = True }

    else
        case String.toFloat model.amountInput of
            Nothing ->
                { model | feedback = "El monto debe ser numerico.", hasError = True }

            Just amount ->
                if amount <= 0 then
                    { model | feedback = "El monto debe ser mayor que 0.", hasError = True }

                else
                    let
                        entry =
                            { id = model.nextId
                            , kind = model.kindInput
                            , description = cleanDescription
                            , amount = amount
                            }
                    in
                    { model
                        | nextId = model.nextId + 1
                        , entries = entry :: model.entries
                        , descriptionInput = ""
                        , amountInput = ""
                        , feedback = "Entrada agregada correctamente."
                        , hasError = False
                    }


parseKind : String -> EntryKind
parseKind rawKind =
    if rawKind == "expense" then
        Expense

    else
        Income


kindToLabel : EntryKind -> String
kindToLabel kind =
    case kind of
        Income ->
            "Ingreso"

        Expense ->
            "Gasto"


sumByKind : EntryKind -> List Entry -> Float
sumByKind targetKind entries =
    entries
        |> List.filter (\entry -> entry.kind == targetKind)
        |> List.map .amount
        |> List.sum


formatMoney : Float -> String
formatMoney amount =
    let
        sign =
            if amount < 0 then
                "-"

            else
                ""

        cents =
            round (abs amount * 100)

        whole =
            cents // 100

        decimalPart =
            modBy 100 cents

        decimalText =
            if decimalPart < 10 then
                "0" ++ String.fromInt decimalPart

            else
                String.fromInt decimalPart
    in
    sign ++ "$" ++ String.fromInt whole ++ "." ++ decimalText


feedbackClass : Bool -> String
feedbackClass hasError =
    if hasError then
        "result-box is-error"

    else
        "result-box"


view : Model -> Html Msg
view model =
    let
        totalIncome =
            sumByKind Income model.entries

        totalExpense =
            sumByKind Expense model.entries

        balance =
            totalIncome - totalExpense
    in
    div [ class "elm-budget-app" ]
        [ div [ class "form-grid form-grid-two" ]
            [ label [ class "field" ]
                [ span [] [ text "Tipo" ]
                , select [ onInput SetKind ]
                    [ option [ value "income", selected (model.kindInput == Income) ] [ text "Ingreso" ]
                    , option [ value "expense", selected (model.kindInput == Expense) ] [ text "Gasto" ]
                    ]
                ]
            , label [ class "field" ]
                [ span [] [ text "Descripcion" ]
                , input
                    [ type_ "text"
                    , placeholder "Ej. Beca o libros"
                    , value model.descriptionInput
                    , onInput SetDescription
                    ]
                    []
                ]
            , label [ class "field" ]
                [ span [] [ text "Monto" ]
                , input
                    [ type_ "number"
                    , step "0.01"
                    , placeholder "0.00"
                    , value model.amountInput
                    , onInput SetAmount
                    ]
                    []
                ]
            ]
        , button [ class "action-btn", onClick AddEntry ] [ text "Agregar entrada" ]
        , p [ class (feedbackClass model.hasError) ] [ text model.feedback ]
        , div [ class "elm-summary-grid" ]
            [ summaryCard "Ingresos" (formatMoney totalIncome)
            , summaryCard "Gastos" (formatMoney totalExpense)
            , summaryCard "Balance" (formatMoney balance)
            ]
        , h3 [ class "elm-list-title" ] [ text "Entradas" ]
        , viewEntries model.entries
        ]


summaryCard : String -> String -> Html msg
summaryCard title amount =
    div [ class "elm-summary-card" ]
        [ p [ class "elm-summary-title" ] [ text title ]
        , p [ class "elm-summary-value" ] [ text amount ]
        ]


viewEntries : List Entry -> Html Msg
viewEntries entries =
    if List.isEmpty entries then
        p [ class "module-help" ] [ text "No hay entradas todavia." ]

    else
        ul [ class "elm-entry-list" ] (List.map viewEntry entries)


viewEntry : Entry -> Html Msg
viewEntry entry =
    li [ class "elm-entry-item" ]
        [ div [ class "elm-entry-main" ]
            [ p [ class "elm-entry-label" ] [ text entry.description ]
            , p [ class "elm-entry-meta" ]
                [ text (kindToLabel entry.kind ++ " | " ++ formatMoney entry.amount) ]
            ]
        , button [ class "secondary-btn", onClick (RemoveEntry entry.id) ] [ text "Eliminar" ]
        ]
