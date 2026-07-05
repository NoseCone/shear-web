open Monad

(* NOTE:
   We intentionally keep the exported result types monomorphic (`compInputParseResult`
   and `nominalParseResult`) even though this module uses a local polymorphic
   helper `parseResult`.

   In this codebase/Ur/Web toolchain, exposing polymorphic `ParseOk`/`ParseError`
   across module boundaries has triggered a backend C codegen failure
   (`__uwd_UNBOUND__...` in generated webapp.c), even when type-checking succeeds.

   So: use `parseResult` only as an internal helper, then convert via
   `fromParseCompInput` / `fromParseNominal` before returning from public functions.
*)
datatype compInputParseResult = CompInputParseError of string | CompInputParseOk of Comp.compInput
datatype nominalParseResult = NominalParseError of string | NominalParseOk of Comp.nominal
datatype tasksParseResult = TasksParseError of string | TasksParseOk of list Comp.compTask
datatype taskLengthsParseResult = TaskLengthsParseError of string | TaskLengthsParseOk of list Comp.taskLength
datatype pilotsParseResult = PilotsParseError of string | PilotsParseOk of list Comp.pilotStatus

datatype parseResult t = ParseError of string | ParseOk of t

fun fromParseCompInput (r : parseResult Comp.compInput) : compInputParseResult =
  case r of
    ParseError err => CompInputParseError err
  | ParseOk v => CompInputParseOk v

fun fromParseNominal (r : parseResult Comp.nominal) : nominalParseResult =
  case r of
    ParseError err => NominalParseError err
  | ParseOk v => NominalParseOk v

fun fromParseTasks (r : parseResult (list Comp.compTask)) : tasksParseResult =
  case r of
    ParseError err => TasksParseError err
  | ParseOk v => TasksParseOk v

fun fromParseTaskLengths (r : parseResult (list Comp.taskLength)) : taskLengthsParseResult =
  case r of
    ParseError err => TaskLengthsParseError err
  | ParseOk v => TaskLengthsParseOk v

fun fromParsePilots (r : parseResult (list Comp.pilotStatus)) : pilotsParseResult =
  case r of
    ParseError err => PilotsParseError err
  | ParseOk v => PilotsParseOk v

datatype scoreBackParseResult = ScoreBackParseError of string | ScoreBackParseOk of Comp.scoreBackTime

datatype nominalDistanceParseResult = NominalDistanceParseError of string | NominalDistanceParseOk of float

datatype nominalTimeParseResult = NominalTimeParseError of string | NominalTimeParseOk of float

datatype earthModelParseResult = EarthModelParseError of string | EarthModelParseOk of Comp.earthModel

fun parseScoreBackTime (raw : string) : scoreBackParseResult =
  case String.ssplit {Haystack = raw, Needle = " s"} of
    None => ScoreBackParseError ("Invalid scoreBack units; expected '<number> s', a quantity of seconds: " ^ raw)
  | Some (num, rest) =>
      if rest <> "" then ScoreBackParseError ("Invalid scoreBack units; expected '<number> s', a quantity of seconds: " ^ raw)
      else (case (read num : option float) of
        None => ScoreBackParseError ("Invalid scoreBack number: " ^ raw)
      | Some seconds => ScoreBackParseOk (Comp.ScoreBackTime seconds))

fun parseNominalDistance (raw : string) : nominalDistanceParseResult =
  case String.ssplit {Haystack = raw, Needle = " km"} of
    None => NominalDistanceParseError ("Invalid nominalDistance units; expected '<number> km', a quantity of kilometres: " ^ raw)
  | Some (num, rest) =>
      if rest <> "" then NominalDistanceParseError ("Invalid nominalDistance units; expected '<number> km', a quantity of kilometres: " ^ raw)
      else (case (read num : option float) of
        None => NominalDistanceParseError ("Invalid nominalDistance number: " ^ raw)
      | Some km => NominalDistanceParseOk km)

fun parseNominalTime (raw : string) : nominalTimeParseResult =
  case String.ssplit {Haystack = raw, Needle = " h"} of
    None => NominalTimeParseError ("Invalid nominalTime units; expected '<number> h', a quantity of hours: " ^ raw)
  | Some (num, rest) =>
      if rest <> "" then NominalTimeParseError ("Invalid nominalTime units; expected '<number> h', a quantity of hours: " ^ raw)
      else (case (read num : option float) of
        None => NominalTimeParseError ("Invalid nominalTime number: " ^ raw)
      | Some hours => NominalTimeParseOk hours)

fun parseNominalJson (json : string) : transaction nominalParseResult =
  parsed <- CompParse.parseNominal json;

  distance <- Monad.mp parseNominalDistance (CompParse.nominalDistance parsed);
  freeDist <- Monad.mp parseNominalDistance (CompParse.nominalFree parsed);
  time <- Monad.mp parseNominalTime (CompParse.nominalTime parsed);
  goal <- CompParse.nominalGoal parsed;
  launch <- CompParse.nominalLaunch parsed;

  CompParse.freeNominal parsed;
  return (case (distance, freeDist, time) of
    (NominalDistanceParseError err, _, _) => NominalParseError err
  | (_, NominalDistanceParseError err, _) => NominalParseError err
  | (_, _, NominalTimeParseError err) => NominalParseError err
  | (NominalDistanceParseOk distance, NominalDistanceParseOk freeDist, NominalTimeParseOk hours) =>
      fromParseNominal (ParseOk (Comp.Nominal
        { Distance = distance
        , Free = freeDist
        , Time = hours
        , Goal = goal
        , Launch = launch
        })))

fun parseTasksJson (json : string) : transaction tasksParseResult =
  parsed <- CompParse.parseTasks json;

  n <- CompParse.tasksCount parsed;

  let
    fun zonesLoop ti zi zc : transaction (list Comp.rawZone) =
      if zi >= zc then
        return []
      else
        zoneName <- CompParse.taskZoneName parsed ti zi;
        rest <- zonesLoop ti (zi + 1) zc;
        return ({ZoneName = zoneName} :: rest)

    fun tasksLoop i : transaction (list Comp.compTask) =
      if i >= n then
        return []
      else
        taskName <- CompParse.taskName parsed i;
        zc <- CompParse.taskZoneCount parsed i;
        rawZones <- zonesLoop i 0 zc;
        stoppedAnnounced <- CompParse.taskStoppedAnnounced parsed i;
        stoppedRetroactive <- CompParse.taskStoppedRetroactive parsed i;
        cancelledPresent <- CompParse.taskCancelledPresent parsed i;
        cancelledValue <- CompParse.taskCancelledValue parsed i;

        rest <- tasksLoop (i + 1);

        let
          val stopped =
            case stoppedAnnounced of
              None => None
            | Some announced =>
                case stoppedRetroactive of
                  None => None
                | Some retroactive => Some {Announced = announced, Retroactive = retroactive}

          val cancelled =
            if cancelledPresent = 0 then
              None
            else
              Some cancelledValue
        in
          return ({ TaskName = taskName
                  , Zones = {Raw = rawZones}
                  , Stopped = stopped
                  , Cancelled = cancelled
                  } :: rest)
        end
  in
    tasks <- tasksLoop 0;
    CompParse.freeTasks parsed;
    return (fromParseTasks (ParseOk tasks))
  end

fun parseTaskLengthsJson (json : string) : transaction taskLengthsParseResult =
  parsed <- CompParse.parseTaskLengths json;
  n <- CompParse.taskLengthsCount parsed;

  let
    fun lengthsLoop i : transaction (list Comp.taskLength) =
      if i >= n then
        return []
      else
        d <- CompParse.taskLength parsed i;
        rest <- lengthsLoop (i + 1);
        return (d :: rest)
  in
    lengths <- lengthsLoop 0;
    CompParse.freeTaskLengths parsed;
    return (fromParseTaskLengths (ParseOk lengths))
  end

fun parsePilotsJson (json : string) : transaction pilotsParseResult =
  parsed <- CompParse.parsePilots json;
  n <- CompParse.pilotsCount parsed;

  let
    fun statusesLoop pi si sc : transaction (list string) =
      if si >= sc then
        return []
      else
        st <- CompParse.pilotStatus parsed pi si;
        rest <- statusesLoop pi (si + 1) sc;
        return (st :: rest)

    fun pilotsLoop i : transaction (list Comp.pilotStatus) =
      if i >= n then
        return []
      else
        pid <- CompParse.pilotId parsed i;
        pname <- CompParse.pilotName parsed i;
        sc <- CompParse.pilotStatusCount parsed i;
        statuses <- statusesLoop i 0 sc;
        rest <- pilotsLoop (i + 1);
        return ({ PilotId = pid
                , PilotName = pname
                , PilotStatus = statuses
                } :: rest)
  in
    pilots <- pilotsLoop 0;
    CompParse.freePilots parsed;
    return (fromParsePilots (ParseOk pilots))
  end

fun parseCompInputJson (json : string) : transaction compInputParseResult =
  parsed <- CompParse.parse json;

  civilId <- CompParse.civilId parsed;
  earthMath <- CompParse.earthMath parsed;
  disciplineCode <- CompParse.discipline parsed;
  location <- CompParse.location parsed;
  fromDate <- CompParse.fromDate parsed;
  toDate <- CompParse.toDate parsed;
  compName <- CompParse.compName parsed;
  utcOffsetMinutes <- CompParse.utcOffsetMinutes parsed;
  earthRadius <- CompParse.earthRadius parsed;
  earthEquatorialR <- CompParse.earthEquatorialR parsed;
  earthRecipF <- CompParse.earthRecipF parsed;
  giveDistance <- CompParse.giveDistance parsed;
  giveFraction <- CompParse.giveFraction parsed;
  scoreBackRaw <- CompParse.scoreBack parsed;

  let
    val scoreBackResult : option scoreBackParseResult =
      case scoreBackRaw of
        None => None
      | Some raw => Some (parseScoreBackTime raw)

    val earthModelResult : earthModelParseResult =
      case earthRadius of
        Some radius =>
          (case earthEquatorialR of
             Some _ => EarthModelParseError "Invalid earth model: found both sphere and ellipsoid fields"
           | None =>
               case earthRecipF of
                 Some _ => EarthModelParseError "Invalid earth model: recipF without ellipsoid.equatorialR"
               | None => EarthModelParseOk (Comp.EarthAsSphere {Radius = radius}))
      | None =>
          case earthEquatorialR of
            None => EarthModelParseError "Missing earth model: expected earth.sphere or earth.ellipsoid"
          | Some equatorialR =>
              case earthRecipF of
                None => EarthModelParseError "Incomplete earth ellipsoid: missing recipF"
              | Some recipF => EarthModelParseOk (Comp.EarthEllipsoid {EquatorialR = equatorialR, RecipF = recipF})

    val disciplineOpt =
      if disciplineCode = "hg" then Some Comp.HangGliding
      else if disciplineCode = "pg" then Some Comp.Paragliding
      else None

    val scoreBack : option Comp.scoreBackTime =
      case scoreBackResult of
        None => None
      | Some (ScoreBackParseOk sb) => Some sb
      | Some (ScoreBackParseError _) => None
  in
    case earthModelResult of
      EarthModelParseError err =>
        CompParse.free parsed;
        return (fromParseCompInput (ParseError err))
    | EarthModelParseOk earthModel =>
        case scoreBackResult of
          Some (ScoreBackParseError err) =>
            CompParse.free parsed;
            return (fromParseCompInput (ParseError err))
        | _ =>
            case disciplineOpt of
              None =>
                CompParse.free parsed;
                return (fromParseCompInput (ParseError ("Unsupported discipline value in JSON: " ^ disciplineCode)))
            | Some discipline =>
                CompParse.free parsed;
                return (fromParseCompInput (ParseOk (Comp.CompInput
                  { CivilId = civilId
                  , EarthMath = earthMath
                  , Discipline = discipline
                  , Location = location
                  , From = fromDate
                  , To = toDate
                  , CompName = compName
                  , UtcOffset = Comp.UtcOffset {TimeZoneMinutes = utcOffsetMinutes}
                  , EarthModel = earthModel
                  , GiveConfig = Comp.GiveConfig
                      { GiveDistance = giveDistance
                      , GiveFraction = giveFraction
                      }
                  , ScoreBack = scoreBack
                  })))
  end
