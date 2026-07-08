fun fetchAndParseCompInput (compName : string) : transaction CompJson.compInputParseResult =
  let
    json <- CompFetch.fetch(mkCompUrl compName);
    CompJson.parseCompInputJson json
  where
    fun mkCompUrl (compName : string) =
      "http://" ^ compName ^ ".flaretiming.com/json/comp-input/comps.json"
  end

fun fetchAndParseNominal (compName : string) : transaction CompJson.nominalParseResult =
  let
    json <- CompFetch.fetch(mkNominalUrl compName);
    CompJson.parseNominalJson json
  where
    fun mkNominalUrl (compName : string) =
      "http://" ^ compName ^ ".flaretiming.com/json/comp-input/nominals.json"
  end

fun fetchAndParseTasks (compName : string) : transaction CompJson.tasksParseResult =
  let
    json <- CompFetch.fetch(mkTasksUrl compName);
    CompJson.parseTasksJson json
  where
    fun mkTasksUrl (compName : string) =
      "http://" ^ compName ^ ".flaretiming.com/json/comp-input/tasks.json"
  end

fun fetchAndParseTaskLengths (compName : string) : transaction CompJson.taskLengthsParseResult =
  let
    json <- CompFetch.fetch(mkTaskLengthsUrl compName);
    CompJson.parseTaskLengthsJson json
  where
    fun mkTaskLengthsUrl (compName : string) =
      "http://" ^ compName ^ ".flaretiming.com/json/task-length/task-lengths.json"
  end

fun fetchAndParsePilots (compName : string) : transaction CompJson.pilotsParseResult =
  let
    json <- CompFetch.fetch(mkPilotsUrl compName);
    CompJson.parsePilotsJson json
  where
    fun mkPilotsUrl (compName : string) =
      "http://" ^ compName ^ ".flaretiming.com/json/gap-point/pilots-status.json"
  end
