open Monad

datatype parseResult t = ParseError of string | ParseOk of t

fun parseEarthRadius (raw : string) : parseResult float =
    case String.ssplit {Haystack = raw, Needle = " m"} of
      None => ParseError ("Invalid earth radius units; expected '<number> m', a quantity of metres: " ^ raw)
    | Some (num, rest) =>
        if rest <> "" then ParseError ("Invalid earth radius units; expected '<number> m', a quantity of metres: " ^ raw)
        else (case (read num : option float) of
            None => ParseError ("Invalid earth radius number: " ^ raw)
          | Some m => ParseOk m)

fun parseScoreBackTime (raw : string) : parseResult Comp.scoreBackTime =
    case String.ssplit {Haystack = raw, Needle = " s"} of
      None => ParseError ("Invalid scoreBack units; expected '<number> s', a quantity of seconds: " ^ raw)
    | Some (num, rest) =>
        if rest <> "" then ParseError ("Invalid scoreBack units; expected '<number> s', a quantity of seconds: " ^ raw)
        else (case (read num : option float) of
            None => ParseError ("Invalid scoreBack number: " ^ raw)
          | Some seconds => ParseOk (Comp.ScoreBackTime seconds))

fun parseNominalDistance (raw : string) : parseResult float =
    case String.ssplit {Haystack = raw, Needle = " km"} of
      None => ParseError ("Invalid nominalDistance units; expected '<number> km', a quantity of kilometres: " ^ raw)
    | Some (num, rest) =>
        if rest <> "" then ParseError ("Invalid nominalDistance units; expected '<number> km', a quantity of kilometres: " ^ raw)
        else (case (read num : option float) of
            None => ParseError ("Invalid nominalDistance number: " ^ raw)
          | Some km => ParseOk km)

fun parseNominalTime (raw : string) : parseResult float =
    case String.ssplit {Haystack = raw, Needle = " h"} of
      None => ParseError ("Invalid nominalTime units; expected '<number> h', a quantity of hours: " ^ raw)
    | Some (num, rest) =>
        if rest <> "" then ParseError ("Invalid nominalTime units; expected '<number> h', a quantity of hours: " ^ raw)
        else (case (read num : option float) of
            None => ParseError ("Invalid nominalTime number: " ^ raw)
          | Some hours => ParseOk hours)

fun parseNominalJson (json : string) : transaction (parseResult Comp.nominal) =
    parsed <- CompParse.parseNominal json;

    distance <- Monad.mp parseNominalDistance (CompParse.nominalDistance parsed);
    freeDist <- Monad.mp parseNominalDistance (CompParse.nominalFree parsed);
    time <- Monad.mp parseNominalTime (CompParse.nominalTime parsed);
    goal <- CompParse.nominalGoal parsed;
    launch <- CompParse.nominalLaunch parsed;

    CompParse.freeNominal parsed;
    return (case (distance, freeDist, time) of
        (ParseError err, _, _) => ParseError err
      | (_, ParseError err, _) => ParseError err
      | (_, _, ParseError err) => ParseError err
      | (ParseOk distance, ParseOk freeDist, ParseOk hours) =>
            ParseOk (Comp.Nominal
                { Distance = distance
                , Free = freeDist
                , Time = hours
                , Goal = goal
                , Launch = launch
                }))

fun parseTasksJson (json : string) : transaction (parseResult (list Comp.compTask)) =
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
        return (ParseOk tasks)
    end

fun parseTaskLengthsJson (json : string) : transaction (parseResult (list Comp.taskLength)) =
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
        return (ParseOk lengths)
    end

fun parsePilotsJson (json : string) : transaction (parseResult (list Comp.pilotStatus)) =
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
        return (ParseOk pilots)
    end

fun parseCompInputJson (json : string) : transaction (parseResult Comp.compInput) =
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
        val scoreBackResult : option (parseResult Comp.scoreBackTime) =
          Option.mp parseScoreBackTime scoreBackRaw

        val earthModelResult : parseResult Comp.earthModel =
            case earthRadius of
              Some radius =>
                (case earthEquatorialR of
                    Some _ => ParseError "Invalid earth model: found both sphere and ellipsoid fields"
                  | None =>
                    case earthRecipF of
                      Some _ => ParseError "Invalid earth model: recipF without ellipsoid.equatorialR"
                    | None =>
                        (case parseEarthRadius radius of
                            ParseError err => ParseError err
                          | ParseOk r => ParseOk (Comp.EarthAsSphere {Radius = r})))
            | None =>
                case earthEquatorialR of
                  None => ParseError "Missing earth model: expected earth.sphere or earth.ellipsoid"
                | Some equatorialR =>
                    case earthRecipF of
                      None => ParseError "Incomplete earth ellipsoid: missing recipF"
                    | Some recipF => ParseOk (Comp.EarthEllipsoid {EquatorialR = equatorialR, RecipF = recipF})

        val disciplineOpt =
            if disciplineCode = "hg" then Some Comp.HangGliding
            else if disciplineCode = "pg" then Some Comp.Paragliding
            else None

        val scoreBack : option Comp.scoreBackTime =
            case scoreBackResult of
              None => None
            | Some (ParseOk sb) => Some sb
            | Some (ParseError _) => None
    in
        case earthModelResult of
          ParseError err =>
            CompParse.free parsed;
            return (ParseError err)
        | ParseOk earthModel =>
            case scoreBackResult of
              Some (ParseError err) =>
                CompParse.free parsed;
                return (ParseError err)
            | _ =>
                case disciplineOpt of
                  None =>
                    CompParse.free parsed;
                    return (ParseError ("Unsupported discipline value in JSON: " ^ disciplineCode))
                | Some discipline =>
                    CompParse.free parsed;
                    return (ParseOk (Comp.CompInput
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
                        }))
    end
