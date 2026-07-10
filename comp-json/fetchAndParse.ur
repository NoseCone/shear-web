open QuantityJson

fun parseNominalJson (json : string) : transaction (parseResult Comp.nominal) =
    return (ParseOk (Json.fromJson json : Comp.nominal))

fun parseCompInputJson (json : string) : transaction (parseResult Comp.compInput) =
    return (ParseOk (Json.fromJson json : Comp.compInput))

fun parseTasksJson (json : string) : transaction (parseResult (list Comp.compTask)) =
    return (ParseOk (Json.fromJson json : list Comp.compTask))

fun parseTaskLengthsJson (json : string) : transaction (parseResult (list Comp.taskLength)) =
    return (ParseOk (Json.fromJson json : list Comp.taskLength))

fun parsePilotsJson (json : string) : transaction (parseResult (list Comp.pilotStatus)) =
    return (ParseOk (Json.fromJson json : list Comp.pilotStatus))

fun fetchAndParse [t] (path : string) (parser : string -> transaction t) (compName : string) : transaction t =
    json <- CompFetch.fetch ("http://" ^ compName ^ ".flaretiming.com" ^ path);
    parser json

fun fetchAndParseCompInput (compName : string) : transaction (parseResult Comp.compInput) =
    fetchAndParse "/json/comp-input/comps.json" parseCompInputJson compName

fun fetchAndParseNominal (compName : string) : transaction (parseResult Comp.nominal) =
    fetchAndParse "/json/comp-input/nominals.json" parseNominalJson compName

fun fetchAndParseTasks (compName : string) : transaction (parseResult (list Comp.compTask)) =
    fetchAndParse "/json/comp-input/tasks.json" parseTasksJson compName

fun fetchAndParseTaskLengths (compName : string) : transaction (parseResult (list Comp.taskLength)) =
    fetchAndParse "/json/task-length/task-lengths.json" parseTaskLengthsJson compName

fun fetchAndParsePilots (compName : string) : transaction (parseResult (list Comp.pilotStatus)) =
    fetchAndParse "/json/gap-point/pilots-status.json" parsePilotsJson compName
