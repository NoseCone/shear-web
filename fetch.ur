fun fetchCompJson (compName : string) : transaction string =
  let
    CompFetch.fetch (mkCompUrl compName)
  where
    fun mkCompUrl (compName : string) =
      "http://" ^ compName ^ ".flaretiming.com/json/comp-input/comps.json"
  end

fun fetchAndParseCompInput (compName : string) : transaction (CompJson.parseResult Comp.compInput) =
  json <- fetchCompJson compName;
  CompJson.parseCompInputJson json
