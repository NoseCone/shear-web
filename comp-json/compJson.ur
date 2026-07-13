open Monad
open Quantity
open QuantityJson

val json_nominal : Json.json Comp.nominal =
    let
        val json_record : Json.json
              { Distance : kilometres
              , Free : kilometres
              , Time : hours
              , Goal : float
              , Launch : float
              } =
            Json.json_record
                { Distance = "distance"
                , Free = "free"
                , Goal = "goal"
                , Launch = "launch"
                , Time = "time"
                }
    in
        Json.json_derived Comp.Nominal (fn (Comp.Nominal x) => x)
    end

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

val json_earthSphere : Json.json {Radius : metres} =
    Json.json_record {Radius = "radius"}

val json_earthEllipsoid : Json.json Comp.ellipsoid =
    Json.json_record {EquatorialR = "equatorialR", RecipF = "recipF"}

val json_earth : Json.json { Sphere : option {Radius : metres}, Ellipsoid : option Comp.ellipsoid } =
    Json.json_record_withOptional {} {Sphere = "sphere", Ellipsoid = "ellipsoid"}

val json_give : Json.json Comp.gives =
    Json.json_record_withOptional
        {GiveFraction = "giveFraction"}
        {GiveDistance = "giveDistance"}

val json_taskLength : Json.json Comp.taskLength = json_quantity "km"

val json_pilotStatus : Json.json Comp.pilotStatus =
    let
        fun parsePilotRow (row : list (list string)) : parseResult Comp.pilotStatus =
            case row of
              (pid :: pname :: []) :: statuses :: [] => ParseOk {PilotId = pid, PilotName = pname, PilotStatus = statuses}
            | _ :: _ :: [] => ParseError "Expected exactly [id, name] in pilot identifier pair"
            | _ => ParseError "Expected exactly [[id, name], [statuses...]] in pilot row"

        fun fromRow (s : string) : Comp.pilotStatus * string =
            let
                val (row, rest) : list (list string) * string = Json.fromJson' s
            in
                case parsePilotRow row of
                  ParseError err => error <xml>{[err]}</xml>
                | ParseOk pilot => (pilot, rest)
            end

        fun toRow ({PilotId = pid, PilotName = pname, PilotStatus = statuses} : Comp.pilotStatus) : list (list string) =
            (pid :: pname :: []) :: statuses :: []
    in
        Json.mkJson
            { ToJson = fn p => Json.toJson (toRow p)
            , FromJson = fromRow
            }
    end

val json_earthModel : Json.json Comp.earthModel =
    let
        fun fromRaw (raw : { Sphere : option Comp.sphere, Ellipsoid : option Comp.ellipsoid }) : parseResult Comp.earthModel =
            case (raw.Sphere, raw.Ellipsoid) of
              (Some sphere, None) => ParseOk (Comp.EarthSphere sphere)
            | (None, Some ellipsoid) => ParseOk (Comp.EarthEllipsoid ellipsoid)
            | (Some _, Some _) => ParseError "Invalid earth model; cannot have both sphere and ellipsoid"
            | (None, None) => ParseError "Invalid earth model; must have either sphere or ellipsoid"

        fun toRaw (model : Comp.earthModel) : { Sphere : option Comp.sphere, Ellipsoid : option Comp.ellipsoid } =
            case model of
              Comp.EarthSphere sphere => {Sphere = Some sphere, Ellipsoid = None}
            | Comp.EarthEllipsoid ellipsoid => {Sphere = None, Ellipsoid = Some ellipsoid}

        fun parseEarthModel (s : string) : Comp.earthModel * string =
            let
                val (raw, rest) : { Sphere : option Comp.sphere, Ellipsoid : option Comp.ellipsoid } * string = Json.fromJson' s
            in
                case fromRaw raw of
                  ParseError err => error <xml>{[err]}</xml>
                | ParseOk model => (model, rest)
            end
    in
        Json.mkJson
            { ToJson = fn m => Json.toJson (toRaw m)
            , FromJson = parseEarthModel
            }
    end

val json_discipline : Json.json Comp.discipline =
    let
        fun parseDiscipline (s : string) : Comp.discipline * string =
            let
                val (raw, rest) : string * string = Json.fromJson' s
            in
                case read raw of
                  Some d => (d, rest)
                | None => error <xml>{["Unsupported discipline value in JSON: " ^ raw]}</xml>
            end
    in
        Json.mkJson
            { ToJson = fn d => Json.toJson (show d)
            , FromJson = parseDiscipline
            }
    end

val json_tzMinutes : Json.json Comp.tzMinutes =
    Json.json_record {TimeZoneMinutes = "timeZoneMinutes"}

val json_utcOffset : Json.json Comp.utcOffset =
    Json.json_derived Comp.UtcOffset (fn (Comp.UtcOffset x) => x)

val json_scoreBackTime : Json.json Comp.scoreBackTime =
    Json.json_derived Comp.ScoreBackTime (fn (Comp.ScoreBackTime x) => x)

val json_giveConfig : Json.json Comp.giveConfig =
    Json.json_derived Comp.GiveConfig (fn (Comp.GiveConfig x) => x)

val json_compInput : Json.json Comp.compInput =
    let
        val json_compSettings : Json.json Comp.compSettings =
            Json.json_record_withOptional
                { CivilId = "civilId"
                , CompName = "compName"
                , Discipline = "discipline"
                , EarthModel = "earth"
                , EarthMath = "earthMath"
                , From = "from"
                , GiveConfig = "give"
                , Location = "location"
                , To = "to"
                , UtcOffset = "utcOffset"
                }
                {ScoreBack = "scoreBack"}
    in
        Json.json_derived Comp.CompInput (fn (Comp.CompInput x) => x)
    end
