val fetchCompJson : string -> transaction string
val fetchAndParseCompInput : string -> transaction (CompJson.parseResult Comp.compInput)
