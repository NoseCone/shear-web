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
