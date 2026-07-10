datatype parseResult t = ParseError of string | ParseOk of t

val json_quantity : string -> Json.json float
