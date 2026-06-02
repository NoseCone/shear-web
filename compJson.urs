datatype parseResult t = ParseError of string | ParseOk of t

val parseCompInputJson : string -> transaction (parseResult (option Comp.compInput))
