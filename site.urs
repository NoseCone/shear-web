val fetchCompJson : string -> transaction string
val fetchAndParseCompInput : string -> transaction (option Comp.compInput)
val main : unit -> transaction page
