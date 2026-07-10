open Quantity

datatype parseResult t = ParseError of string | ParseOk of t

fun parseQuantity (unit : string) (unitName : string) (label : string) (raw : string) : parseResult float =
    case String.ssplit {Haystack = raw, Needle = " " ^ unit} of
      None => ParseError ("Invalid " ^ label ^ " units; expected '<number> " ^ unit ^ "', a quantity of " ^ unitName ^ ": " ^ raw)
    | Some (num, rest) =>
        if rest <> "" then ParseError ("Invalid " ^ label ^ " units; expected '<number> " ^ unit ^ "', a quantity of " ^ unitName ^ ": " ^ raw)
        else case (read num : option float) of
            None => ParseError ("Invalid " ^ label ^ " number: " ^ raw)
          | Some x => ParseOk x

fun quantityUnitName (unitSymbol : string) : string = case unitSymbol of
    "s" => "seconds"
  | "h" => "hours"
  | "m" => "metres"
  | "km" => "kilometres"
  | _ => error <xml>Unsupported quantity unit {[unitSymbol]} (supported: s, m, km, h)</xml>

fun json_quantity (unitSymbol : string) : Json.json float =
    let
        val unitName = quantityUnitName unitSymbol

        fun fromQ (s : string) : float * string =
            let
                val (raw, rest) : string * string = Json.fromJson' s
            in
                case parseQuantity unitSymbol unitName "quantity" raw of
                  ParseError err => error <xml>{[err]}</xml>
                | ParseOk x => (x, rest)
            end
    in
        Json.mkJson
            { ToJson = fn x => Json.toJson (show x ^ " " ^ unitSymbol)
            , FromJson = fromQ
            }
    end

val json_metres : Json.json metres =
    let val json_float = json_quantity "m" in Json.json_derived Metres (fn (Metres x) => x) end

val json_kilometres : Json.json kilometres =
    let val json_float = json_quantity "km" in Json.json_derived Kilometres (fn (Kilometres x) => x) end

val json_hours : Json.json hours =
    let val json_float = json_quantity "h" in Json.json_derived Hours (fn (Hours x) => x) end

val json_seconds : Json.json seconds =
    let val json_float = json_quantity "s" in Json.json_derived Seconds (fn (Seconds x) => x) end
