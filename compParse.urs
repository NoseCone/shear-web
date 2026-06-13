type parsedComp
type parsedNominal
type parsedTasks
type parsedTaskLengths
type parsedPilots

val parse : string -> transaction parsedComp
val free : parsedComp -> transaction unit

val parseNominal : string -> transaction parsedNominal
val freeNominal : parsedNominal -> transaction unit

val parseTasks : string -> transaction parsedTasks
val freeTasks : parsedTasks -> transaction unit
val tasksCount : parsedTasks -> transaction int
val taskName : parsedTasks -> int -> transaction string
val taskZoneCount : parsedTasks -> int -> transaction int
val taskZoneName : parsedTasks -> int -> int -> transaction string
val taskStoppedAnnounced : parsedTasks -> int -> transaction (option string)
val taskStoppedRetroactive : parsedTasks -> int -> transaction (option string)
val taskCancelledPresent : parsedTasks -> int -> transaction int
val taskCancelledValue : parsedTasks -> int -> transaction bool

val parseTaskLengths : string -> transaction parsedTaskLengths
val freeTaskLengths : parsedTaskLengths -> transaction unit
val taskLengthsCount : parsedTaskLengths -> transaction int
val taskLength : parsedTaskLengths -> int -> transaction float

val parsePilots : string -> transaction parsedPilots
val freePilots : parsedPilots -> transaction unit
val pilotsCount : parsedPilots -> transaction int
val pilotId : parsedPilots -> int -> transaction string
val pilotName : parsedPilots -> int -> transaction string
val pilotStatusCount : parsedPilots -> int -> transaction int
val pilotStatus : parsedPilots -> int -> int -> transaction string

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
