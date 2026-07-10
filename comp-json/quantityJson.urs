datatype parseResult t = ParseError of string | ParseOk of t

val json_quantity : string -> Json.json float
val json_metres : Json.json Quantity.metres
val json_kilometres : Json.json Quantity.kilometres
val json_hours : Json.json Quantity.hours
val json_seconds : Json.json Quantity.seconds
