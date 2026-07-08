fun fetchAndParse [t] (path : string) (parser : string -> transaction t) (compName : string) : transaction t =
  json <- CompFetch.fetch ("http://" ^ compName ^ ".flaretiming.com" ^ path);
  parser json

fun fetchAndParseCompInput (compName : string) : transaction CompJson.compInputParseResult =
  fetchAndParse "/json/comp-input/comps.json" CompJson.parseCompInputJson compName

fun fetchAndParseNominal (compName : string) : transaction CompJson.nominalParseResult =
  fetchAndParse "/json/comp-input/nominals.json" CompJson.parseNominalJson compName

fun fetchAndParseTasks (compName : string) : transaction CompJson.tasksParseResult =
  fetchAndParse "/json/comp-input/tasks.json" CompJson.parseTasksJson compName

fun fetchAndParseTaskLengths (compName : string) : transaction CompJson.taskLengthsParseResult =
  fetchAndParse "/json/task-length/task-lengths.json" CompJson.parseTaskLengthsJson compName

fun fetchAndParsePilots (compName : string) : transaction CompJson.pilotsParseResult =
  fetchAndParse "/json/gap-point/pilots-status.json" CompJson.parsePilotsJson compName
