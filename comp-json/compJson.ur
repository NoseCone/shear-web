open Monad

datatype parseResult t = ParseError of string | ParseOk of t

fun parseQuantity (unit : string) (unitName : string) (label : string) (raw : string) : parseResult float =
    case String.ssplit {Haystack = raw, Needle = " " ^ unit} of
      None => ParseError ("Invalid " ^ label ^ " units; expected '<number> " ^ unit ^ "', a quantity of " ^ unitName ^ ": " ^ raw)
    | Some (num, rest) =>
        if rest <> "" then ParseError ("Invalid " ^ label ^ " units; expected '<number> " ^ unit ^ "', a quantity of " ^ unitName ^ ": " ^ raw)
        else case (read num : option float) of
            None => ParseError ("Invalid " ^ label ^ " number: " ^ raw)
          | Some x => ParseOk x

fun parseEarthRadius (raw : string) : parseResult float =
    parseQuantity "m" "metres" "earth radius" raw

fun parseScoreBackTime (raw : string) : parseResult Comp.scoreBackTime =
    case parseQuantity "s" "seconds" "scoreBack" raw of
      ParseError err => ParseError err
    | ParseOk seconds => ParseOk (Comp.ScoreBackTime seconds)

fun parseNominalDistance (raw : string) : parseResult float =
    parseQuantity "km" "kilometres" "nominalDistance" raw

fun parseNominalTime (raw : string) : parseResult float =
    parseQuantity "h" "hours" "nominalTime" raw

fun parseTaskLength (raw : string) : parseResult float =
    parseQuantity "km" "kilometres" "taskLength" raw

val json_rawZone : Json.json Comp.rawZone =
    Json.json_record {ZoneName = "zoneName"}

val json_stopped : Json.json Comp.stopped =
    Json.json_record {Announced = "announced", Retroactive = "retroactive"}

val json_zonesWrapper : Json.json {Raw : list Comp.rawZone} =
    Json.json_record {Raw = "raw"}

val json_compTask : Json.json Comp.compTask =
    Json.json_record_withOptional
        {TaskName = "taskName", Zones = "zones"}
        {Stopped  = "stopped",  Cancelled = "cancelled"}

val json_utcOffset : Json.json {TimeZoneMinutes : int} =
    Json.json_record {TimeZoneMinutes = "timeZoneMinutes"}

val json_earthSphere : Json.json {Radius : string} =
    Json.json_record {Radius = "radius"}

val json_earthEllipsoid : Json.json Comp.ellipsoid =
    Json.json_record {EquatorialR = "equatorialR", RecipF = "recipF"}

val json_earth : Json.json { Sphere : option {Radius : string}, Ellipsoid : option Comp.ellipsoid } =
    Json.json_record_withOptional {} {Sphere = "sphere", Ellipsoid = "ellipsoid"}

val json_give : Json.json Comp.gives =
    Json.json_record_withOptional
        {GiveFraction = "giveFraction"}
        {GiveDistance = "giveDistance"}

type nominalRaw =
    { Distance : string
    , Free : string
    , Goal : float
    , Launch : float
    , Time : string
    }

val json_nominalRaw : Json.json nominalRaw =
    Json.json_record
        { Distance = "distance"
        , Free = "free"
        , Goal = "goal"
        , Launch = "launch"
        , Time = "time"
        }

type earthModelRaw =
    { Sphere : option {Radius : string}
    , Ellipsoid : option Comp.ellipsoid
    }

type compInputRaw =
    { CivilId : string
    , CompName : string
    , Discipline : string
    , Earth : earthModelRaw
    , EarthMath  : string
    , From : string
    , Give : Comp.gives
    , Location : string
    , ScoreBack : option string
    , To : string
    , UtcOffset : {TimeZoneMinutes : int}
    }

val json_compInputRaw : Json.json compInputRaw =
    Json.json_record_withOptional
        { CivilId = "civilId"
        , CompName = "compName"
        , Discipline = "discipline"
        , Earth = "earth"
        , EarthMath = "earthMath"
        , From = "from"
        , Give = "give"
        , Location = "location"
        , To = "to"
        , UtcOffset = "utcOffset"
        }
        {ScoreBack = "scoreBack"}

fun convertNominal (r : nominalRaw) : parseResult Comp.nominal =
    case (parseNominalDistance r.Distance, parseNominalDistance r.Free, parseNominalTime r.Time) of
      (ParseOk d, ParseOk f, ParseOk t) =>
        ParseOk (Comp.Nominal {Distance = d, Free = f, Time = t, Goal = r.Goal, Launch = r.Launch})
    | (ParseError e, _, _) => ParseError e
    | (_, ParseError e, _) => ParseError e
    | (_, _, ParseError e) => ParseError e

fun convertTaskLengths (strs : list string) : parseResult (list Comp.taskLength) =
    case strs of
      [] => ParseOk []
    | s :: rest =>
        case parseTaskLength s of
          ParseError err => ParseError err
        | ParseOk km =>
            case convertTaskLengths rest of
              ParseError err => ParseError err
            | ParseOk ks => ParseOk (km :: ks)

fun parsePilotRow (row : list (list string)) : parseResult Comp.pilotStatus =
    case row of
      idName :: statuses :: [] =>
        (case idName of
           pid :: pname :: [] =>
             ParseOk {PilotId = pid, PilotName = pname, PilotStatus = statuses}
         | _ => ParseError "Expected exactly [id, name] in pilot identifier pair")
    | _ => ParseError "Expected exactly [[id, name], [statuses...]] in pilot row"

fun convertPilots (rows : list (list (list string))) : parseResult (list Comp.pilotStatus) =
    case rows of
      [] => ParseOk []
    | row :: rest =>
        case parsePilotRow row of
          ParseError err => ParseError err
        | ParseOk pilot =>
            case convertPilots rest of
              ParseError err => ParseError err
            | ParseOk ps => ParseOk (pilot :: ps)

fun convertCompInput (raw : compInputRaw) : parseResult Comp.compInput =
    let
        val earthModelResult : parseResult Comp.earthModel =
            case (raw.Earth.Sphere, raw.Earth.Ellipsoid) of
              (Some sphere, None) =>
                (case parseEarthRadius sphere.Radius of
                    ParseError err => ParseError err
                  | ParseOk r => ParseOk (Comp.EarthAsSphere {Radius = r}))
            | (None, Some ellipsoid) => ParseOk (Comp.EarthEllipsoid ellipsoid)
            | (Some _, Some _) =>
                ParseError "Invalid earth model: found both sphere and ellipsoid fields"
            | (None, None) =>
                ParseError "Missing earth model: expected earth.sphere or earth.ellipsoid"

        val disciplineOpt : option Comp.discipline =
            if raw.Discipline = "hg" then Some Comp.HangGliding
            else if raw.Discipline = "pg" then Some Comp.Paragliding
            else None

        val scoreBackResult : option (parseResult Comp.scoreBackTime) =
            Option.mp parseScoreBackTime raw.ScoreBack

        val scoreBack : option Comp.scoreBackTime =
            case scoreBackResult of
              None => None
            | Some (ParseOk sb) => Some sb
            | Some (ParseError _) => None
    in
        case earthModelResult of
          ParseError err => ParseError err
        | ParseOk earthModel =>
            case scoreBackResult of
              Some (ParseError err) => ParseError err
            | _ =>
                case disciplineOpt of
                  None =>
                    ParseError ("Unsupported discipline value in JSON: " ^ raw.Discipline)
                | Some discipline =>
                    ParseOk (Comp.CompInput
                        { CivilId = raw.CivilId
                        , EarthMath = raw.EarthMath
                        , Discipline = discipline
                        , Location = raw.Location
                        , From = raw.From
                        , To = raw.To
                        , CompName = raw.CompName
                        , UtcOffset = Comp.UtcOffset {TimeZoneMinutes = raw.UtcOffset.TimeZoneMinutes}
                        , EarthModel = earthModel
                        , GiveConfig = Comp.GiveConfig
                            { GiveDistance = raw.Give.GiveDistance
                            , GiveFraction = raw.Give.GiveFraction
                            }
                        , ScoreBack  = scoreBack
                        })
    end

fun parseNominalJson (json : string) : transaction (parseResult Comp.nominal) =
    return (convertNominal (Json.fromJson json : nominalRaw))

fun parseCompInputJson (json : string) : transaction (parseResult Comp.compInput) =
    return (convertCompInput (Json.fromJson json : compInputRaw))

fun parseTasksJson (json : string) : transaction (parseResult (list Comp.compTask)) =
    return (ParseOk (Json.fromJson json : list Comp.compTask))

fun parseTaskLengthsJson (json : string) : transaction (parseResult (list Comp.taskLength)) =
    return (convertTaskLengths (Json.fromJson json : list string))

fun parsePilotsJson (json : string) : transaction (parseResult (list Comp.pilotStatus)) =
    return (convertPilots (Json.fromJson json : list (list (list string))))
