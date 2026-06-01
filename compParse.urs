type parsedComp

val parse : string -> transaction parsedComp
val free : parsedComp -> transaction unit

val civilId : parsedComp -> string
val earthMath : parsedComp -> string
val discipline : parsedComp -> string
val location : parsedComp -> string
val fromDate : parsedComp -> string
val toDate : parsedComp -> string
val compName : parsedComp -> string
val utcOffsetMinutes : parsedComp -> int
val earthRadius : parsedComp -> string
val giveDistance : parsedComp -> string
val giveFraction : parsedComp -> float
val scoreBack : parsedComp -> string
