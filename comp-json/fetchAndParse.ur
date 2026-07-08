fun fetchAndParseCompInput (compName : string) : transaction CompJson.compInputParseResult =
  let
    json <- CompFetch.fetch url;
    CompJson.parseCompInputJson json
  where
    val url = "http://" ^ compName ^ ".flaretiming.com/json/comp-input/comps.json"
  end

fun fetchAndParseNominal (compName : string) : transaction CompJson.nominalParseResult =
  let
    json <- CompFetch.fetch url;
    CompJson.parseNominalJson json
  where
    val url = "http://" ^ compName ^ ".flaretiming.com/json/comp-input/nominals.json"
  end

fun fetchAndParseTasks (compName : string) : transaction CompJson.tasksParseResult =
  let
    json <- CompFetch.fetch url;
    CompJson.parseTasksJson json
  where
    val url = "http://" ^ compName ^ ".flaretiming.com/json/comp-input/tasks.json"
  end

fun fetchAndParseTaskLengths (compName : string) : transaction CompJson.taskLengthsParseResult =
  let
    json <- CompFetch.fetch url;
    CompJson.parseTaskLengthsJson json
  where
    val url = "http://" ^ compName ^ ".flaretiming.com/json/task-length/task-lengths.json"
  end

fun fetchAndParsePilots (compName : string) : transaction CompJson.pilotsParseResult =
  let
    json <- CompFetch.fetch url;
    CompJson.parsePilotsJson json
  where
    val url = "http://" ^ compName ^ ".flaretiming.com/json/gap-point/pilots-status.json"
  end
