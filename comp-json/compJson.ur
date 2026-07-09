open Monad

datatype parseResult t = ParseError of string | ParseOk of t

(* ──────────────────────────── quantity helpers ──────────────────────────── *)

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

(* ──────────────────────── JSON codecs ──────────────────────────────────── *)
(* Named values for every codec so that list codecs (which require an
   explicit json_list call rather than typeclass synthesis) can be composed
   without ambiguity.                                                        *)

val json_rawZone : Json.json Comp.rawZone =
    Json.json_record {ZoneName = Json.json_string} {ZoneName = "zoneName"}

val json_rawZoneList : Json.json (list Comp.rawZone) =
    Json.json_list json_rawZone

(* {"raw": [...]} — the "zones" wrapper object; extra keys are ignored *)
val json_zonesWrapper : Json.json {Raw : list Comp.rawZone} =
    Json.json_record {Raw = json_rawZoneList} {Raw = "raw"}

val json_stopped : Json.json Comp.stopped =
    Json.json_record
        {Announced = Json.json_string, Retroactive = Json.json_string}
        {Announced = "announced", Retroactive = "retroactive"}

(* Full task — "stopped" and "cancelled" are optional/nullable.
   json_record_withOptional treats absent *or* null optional fields as None. *)
val json_compTask : Json.json Comp.compTask =
    Json.json_record_withOptional
        {TaskName = Json.json_string, Zones = json_zonesWrapper}
        {TaskName = "taskName", Zones = "zones"}
        {Stopped = json_stopped, Cancelled = Json.json_bool}
        {Stopped = "stopped", Cancelled = "cancelled"}

val json_compTaskList : Json.json (list Comp.compTask) =
    Json.json_list json_compTask

(* utcOffset: {"timeZoneMinutes": int} *)
val json_utcOffset : Json.json {TimeZoneMinutes : int} =
    Json.json_record {TimeZoneMinutes = Json.json_int} {TimeZoneMinutes = "timeZoneMinutes"}

(* earth sub-objects *)
val json_earthSphere : Json.json {Radius : string} =
    Json.json_record {Radius = Json.json_string} {Radius = "radius"}

val json_earthEllipsoid : Json.json {EquatorialR : string, RecipF : string} =
    Json.json_record
        {EquatorialR = Json.json_string, RecipF = Json.json_string}
        {EquatorialR = "equatorialR", RecipF = "recipF"}

(* earth: exactly one of "sphere" or "ellipsoid" present; both parsed as
   optional so we can validate and discriminate afterwards. *)
val json_earth : Json.json {Sphere : option {Radius : string},
                             Ellipsoid : option {EquatorialR : string, RecipF : string}} =
    Json.json_record_withOptional
        {} {}
        {Sphere = json_earthSphere, Ellipsoid = json_earthEllipsoid}
        {Sphere = "sphere", Ellipsoid = "ellipsoid"}

(* give: required giveFraction, optional giveDistance *)
val json_give : Json.json {GiveDistance : option string, GiveFraction : float} =
    Json.json_record_withOptional
        {GiveFraction = Json.json_float}
        {GiveFraction = "giveFraction"}
        {GiveDistance = Json.json_string}
        {GiveDistance = "giveDistance"}

(* nominal: distance/free/time are unit-annotated strings; goal/launch are
   plain floats. Field names map directly to the camelCase JSON keys. *)
val json_nominalRaw : Json.json {Distance : string, Free : string, Time : string,
                                  Goal : float, Launch : float} =
    Json.json_record
        { Distance = Json.json_string, Free = Json.json_string, Time = Json.json_string
        , Goal = Json.json_float, Launch = Json.json_float
        }
        {Distance = "distance", Free = "free", Time = "time",
         Goal = "goal", Launch = "launch"}

(* compInputRaw: all required fields plus optional scoreBack.
   Ur/Web row types are unordered so field order in the record literal
   is irrelevant to the type. *)
val json_compInputRaw
    : Json.json { CivilId    : string
                , CompName   : string
                , Discipline : string
                , Earth      : {Sphere : option {Radius : string},
                                Ellipsoid : option {EquatorialR : string, RecipF : string}}
                , EarthMath  : string
                , From       : string
                , Give       : {GiveDistance : option string, GiveFraction : float}
                , Location   : string
                , ScoreBack  : option string
                , To         : string
                , UtcOffset  : {TimeZoneMinutes : int}
                } =
    Json.json_record_withOptional
        { CivilId    = Json.json_string
        , CompName   = Json.json_string
        , Discipline = Json.json_string
        , Earth      = json_earth
        , EarthMath  = Json.json_string
        , From       = Json.json_string
        , Give       = json_give
        , Location   = Json.json_string
        , To         = Json.json_string
        , UtcOffset  = json_utcOffset
        }
        { CivilId    = "civilId"
        , CompName   = "compName"
        , Discipline = "discipline"
        , Earth      = "earth"
        , EarthMath  = "earthMath"
        , From       = "from"
        , Give       = "give"
        , Location   = "location"
        , To         = "to"
        , UtcOffset  = "utcOffset"
        }
        {ScoreBack = Json.json_string}
        {ScoreBack = "scoreBack"}

(* ──────────────────────── conversion helpers ───────────────────────────── *)

fun convertNominal (r : {Distance : string, Free : string, Time : string,
                          Goal : float, Launch : float})
                   : parseResult Comp.nominal =
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

fun convertCompInput (raw : {CivilId    : string,
                               CompName   : string,
                               Discipline : string,
                               Earth      : {Sphere    : option {Radius : string},
                                             Ellipsoid : option {EquatorialR : string, RecipF : string}},
                               EarthMath  : string,
                               From       : string,
                               Give       : {GiveDistance : option string, GiveFraction : float},
                               Location   : string,
                               ScoreBack  : option string,
                               To         : string,
                               UtcOffset  : {TimeZoneMinutes : int}})
                      : parseResult Comp.compInput =
    let
        val earthModelResult : parseResult Comp.earthModel =
            case (raw.Earth.Sphere, raw.Earth.Ellipsoid) of
              (Some sphere, None) =>
                (case parseEarthRadius sphere.Radius of
                    ParseError err => ParseError err
                  | ParseOk r => ParseOk (Comp.EarthAsSphere {Radius = r}))
            | (None, Some ellipsoid) =>
                ParseOk (Comp.EarthEllipsoid { EquatorialR = ellipsoid.EquatorialR
                                             , RecipF      = ellipsoid.RecipF
                                             })
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
              None              => None
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
                        { CivilId    = raw.CivilId
                        , EarthMath  = raw.EarthMath
                        , Discipline = discipline
                        , Location   = raw.Location
                        , From       = raw.From
                        , To         = raw.To
                        , CompName   = raw.CompName
                        , UtcOffset  = Comp.UtcOffset {TimeZoneMinutes = raw.UtcOffset.TimeZoneMinutes}
                        , EarthModel = earthModel
                        , GiveConfig = Comp.GiveConfig
                            { GiveDistance = raw.Give.GiveDistance
                            , GiveFraction = raw.Give.GiveFraction
                            }
                        , ScoreBack  = scoreBack
                        })
    end

(* ──────────────────────────── public API ───────────────────────────────── *)

fun parseNominalJson (s : string) : transaction (parseResult Comp.nominal) =
    return (convertNominal (Json.fromJson json_nominalRaw s))

fun parseCompInputJson (s : string) : transaction (parseResult Comp.compInput) =
    return (convertCompInput (Json.fromJson json_compInputRaw s))

fun parseTasksJson (s : string) : transaction (parseResult (list Comp.compTask)) =
    return (ParseOk (Json.fromJson json_compTaskList s))

fun parseTaskLengthsJson (s : string) : transaction (parseResult (list Comp.taskLength)) =
    return (convertTaskLengths (Json.fromJson (Json.json_list Json.json_string) s))

fun parsePilotsJson (s : string) : transaction (parseResult (list Comp.pilotStatus)) =
    return (convertPilots
        (Json.fromJson
            (Json.json_list (Json.json_list (Json.json_list Json.json_string)))
            s))
