datatype compInputParseResult = CompInputParseError of string | CompInputParseOk of Comp.compInput
datatype nominalParseResult = NominalParseError of string | NominalParseOk of Comp.nominal

val parseNominalJson : string -> transaction nominalParseResult
val parseCompInputJson : string -> transaction compInputParseResult
