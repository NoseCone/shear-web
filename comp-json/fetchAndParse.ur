open QuantityJson

fun fetchAndParse [t] (path : string) (compName : string) (parser : string -> t) : transaction (parseResult t) =
    json <- CompFetch.fetch ("http://" ^ compName ^ ".flaretiming.com" ^ path);
    return (ParseOk (parser json))

fun fetchAndParseNominal (compName : string) : transaction (parseResult Comp.nominal) =
    fetchAndParse "/json/comp-input/nominals.json" compName Json.fromJson

fun fetchAndParseTaskLengths (compName : string) : transaction (parseResult (list Comp.taskLength)) =
    fetchAndParse "/json/task-length/task-lengths.json" compName Json.fromJson

fun fetchAndParseTasks (compName : string) : transaction (parseResult (list Comp.compTask)) =
    fetchAndParse "/json/comp-input/tasks.json" compName Json.fromJson

fun fetchAndParsePilots (compName : string) : transaction (parseResult (list Comp.pilotStatus)) =
    fetchAndParse "/json/gap-point/pilots-status.json" compName Json.fromJson

fun fetchAndParseCompInput (compName : string) : transaction (parseResult Comp.compInput) =
    fetchAndParse "/json/comp-input/comps.json" compName Json.fromJson
