open QuantityJson

fun fetchAndParse [t] (path : string) (compName : string) (parser : string -> transaction t) : transaction t =
    json <- CompFetch.fetch ("http://" ^ compName ^ ".flaretiming.com" ^ path);
    parser json

fun fetchAndParseNominal (compName : string) : transaction (parseResult Comp.nominal) =
    fetchAndParse "/json/comp-input/nominals.json" compName (fn json =>
        return (ParseOk (Json.fromJson json : Comp.nominal)))

fun fetchAndParseTaskLengths (compName : string) : transaction (parseResult (list Comp.taskLength)) =
    fetchAndParse "/json/task-length/task-lengths.json" compName (fn json =>
        return (ParseOk (Json.fromJson json : list Comp.taskLength)))

fun fetchAndParseTasks (compName : string) : transaction (parseResult (list Comp.compTask)) =
    fetchAndParse "/json/comp-input/tasks.json" compName (fn json =>
        return (ParseOk (Json.fromJson json : list Comp.compTask)))

fun fetchAndParsePilots (compName : string) : transaction (parseResult (list Comp.pilotStatus)) =
    fetchAndParse "/json/gap-point/pilots-status.json" compName (fn json =>
        return (ParseOk (Json.fromJson json : list Comp.pilotStatus)))

fun fetchAndParseCompInput (compName : string) : transaction (parseResult Comp.compInput) =
    fetchAndParse "/json/comp-input/comps.json" compName (fn json =>
        return (ParseOk (Json.fromJson json : Comp.compInput)))
