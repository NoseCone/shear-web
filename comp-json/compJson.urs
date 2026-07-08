datatype parseResult t = ParseError of string | ParseOk of t

val parseNominalJson : string -> transaction (parseResult Comp.nominal)
val parseCompInputJson : string -> transaction (parseResult Comp.compInput)
val parseTasksJson : string -> transaction (parseResult (list Comp.compTask))
val parseTaskLengthsJson : string -> transaction (parseResult (list Comp.taskLength))
val parsePilotsJson : string -> transaction (parseResult (list Comp.pilotStatus))
