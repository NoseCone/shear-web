fun fetchAndParseCompInput (compName : string) : transaction (CompJson.parseResult Comp.compInput) =
  let
    json <- CompFetch.fetch(mkCompUrl compName);
    CompJson.parseCompInputJson json
  where
    fun mkCompUrl (compName : string) =
      "http://" ^ compName ^ ".flaretiming.com/json/comp-input/comps.json"
  end
