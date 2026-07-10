open QuantityJson

fun fetchAndParse [t] (_ : Json.json t) (path : string) (compName : string) : transaction (parseResult t) =
    json <- CompFetch.fetch ("http://" ^ compName ^ ".flaretiming.com" ^ path);
    return (ParseOk (Json.fromJson json))

fun fetchAndParseNominal (compName : string) : transaction (parseResult Comp.nominal) =
    fetchAndParse "/json/comp-input/nominals.json" compName

fun fetchAndParseTaskLengths (compName : string) : transaction (parseResult (list Comp.taskLength)) =
    fetchAndParse "/json/task-length/task-lengths.json" compName

fun fetchAndParseTasks (compName : string) : transaction (parseResult (list Comp.compTask)) =
    fetchAndParse "/json/comp-input/tasks.json" compName

fun fetchAndParsePilots (compName : string) : transaction (parseResult (list Comp.pilotStatus)) =
    fetchAndParse "/json/gap-point/pilots-status.json" compName

fun fetchAndParseCompInput (compName : string) : transaction (parseResult Comp.compInput) =
    fetchAndParse "/json/comp-input/comps.json" compName
