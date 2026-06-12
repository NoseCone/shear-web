type parsedComp
type parsedNominal

val parse : string -> transaction parsedComp
val free : parsedComp -> transaction unit

val parseNominal : string -> transaction parsedNominal
val freeNominal : parsedNominal -> transaction unit

val civilId : parsedComp -> transaction string
val earthMath : parsedComp -> transaction string
val discipline : parsedComp -> transaction string
val location : parsedComp -> transaction string
val fromDate : parsedComp -> transaction string
val toDate : parsedComp -> transaction string
val compName : parsedComp -> transaction string
val utcOffsetMinutes : parsedComp -> transaction int
val earthRadius : parsedComp -> transaction (option string)
val earthEquatorialR : parsedComp -> transaction (option string)
val earthRecipF : parsedComp -> transaction (option string)
val giveDistance : parsedComp -> transaction (option string)
val giveFraction : parsedComp -> transaction float
val scoreBack : parsedComp -> transaction (option string)

val nominalDistance : parsedNominal -> transaction string
val nominalFree : parsedNominal -> transaction string
val nominalTime : parsedNominal -> transaction string
val nominalGoal : parsedNominal -> transaction float
val nominalLaunch : parsedNominal -> transaction float
