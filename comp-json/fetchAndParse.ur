fun fetchAndParse [t] (path : string) (parser : string -> transaction t) (compName : string) : transaction t =
    json <- CompFetch.fetch ("http://" ^ compName ^ ".flaretiming.com" ^ path);
    parser json

fun fetchAndParseCompInput (compName : string) : transaction (CompJson.parseResult Comp.compInput) =
    fetchAndParse "/json/comp-input/comps.json" CompJson.parseCompInputJson compName

fun fetchAndParseNominal (compName : string) : transaction (CompJson.parseResult Comp.nominal) =
    fetchAndParse "/json/comp-input/nominals.json" CompJson.parseNominalJson compName

fun fetchAndParseTasks (compName : string) : transaction (CompJson.parseResult (list Comp.compTask)) =
    fetchAndParse "/json/comp-input/tasks.json" CompJson.parseTasksJson compName

fun fetchAndParseTaskLengths (compName : string) : transaction (CompJson.parseResult (list Comp.taskLength)) =
    fetchAndParse "/json/task-length/task-lengths.json" CompJson.parseTaskLengthsJson compName

fun fetchAndParsePilots (compName : string) : transaction (CompJson.parseResult (list Comp.pilotStatus)) =
    fetchAndParse "/json/gap-point/pilots-status.json" CompJson.parsePilotsJson compName
