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
        fun fromString (s : string) : parseResult Comp.discipline =
            case s of
              "hg" => ParseOk Comp.HangGliding
            | "pg" => ParseOk Comp.Paragliding
            | _ => ParseError ("Unsupported discipline value in JSON: " ^ s)

        fun toString (d : Comp.discipline) : string =
            case d of
              Comp.HangGliding => "hg"
            | Comp.Paragliding => "pg"

        fun parseDiscipline (s : string) : Comp.discipline * string =
            let
                val (raw, rest) : string * string = Json.fromJson' s
            in
                case fromString raw of
                  ParseError err => error <xml>{[err]}</xml>
                | ParseOk d => (d, rest)
            end
    in
        Json.mkJson
            { ToJson = fn d => Json.toJson (toString d)
            , FromJson = parseDiscipline
            }
    end

type compInputRaw =
    { CivilId : string
    , CompName : string
    , Discipline : Comp.discipline
    , EarthModel : Comp.earthModel
    , EarthMath  : string
    , From : string
    , Give : Comp.gives
    , Location : string
    , ScoreBack : option seconds
    , To : string
    , UtcOffset : {TimeZoneMinutes : int}
    }

val json_compInput : Json.json Comp.compInput =
    let
        fun fromRaw (raw : compInputRaw) : parseResult Comp.compInput =
            let
                val scoreBack : option Comp.scoreBackTime =
                    Option.mp Comp.ScoreBackTime raw.ScoreBack
            in
                ParseOk
                    (Comp.CompInput
                        { CivilId = raw.CivilId
                        , EarthMath = raw.EarthMath
                        , Discipline = raw.Discipline
                        , Location = raw.Location
                        , From = raw.From
                        , To = raw.To
                        , CompName = raw.CompName
                        , UtcOffset = Comp.UtcOffset {TimeZoneMinutes = raw.UtcOffset.TimeZoneMinutes}
                        , EarthModel = raw.EarthModel
                        , GiveConfig =
                            Comp.GiveConfig
                                { GiveDistance = raw.Give.GiveDistance
                                , GiveFraction = raw.Give.GiveFraction
                                }
                        , ScoreBack = scoreBack
                        })
            end

        fun toRaw ((Comp.CompInput c) : Comp.compInput) : compInputRaw =
            let
                val give : Comp.gives =
                    case c.GiveConfig of Comp.GiveConfig g => g

                val scoreBack : option seconds =
                    Option.mp (fn (Comp.ScoreBackTime s) => s) c.ScoreBack

                val utcOffset : {TimeZoneMinutes : int} =
                    case c.UtcOffset of Comp.UtcOffset u => {TimeZoneMinutes = u.TimeZoneMinutes}
            in
                { CivilId = c.CivilId
                , CompName = c.CompName
                , Discipline = c.Discipline
                , EarthModel = c.EarthModel
                , EarthMath = c.EarthMath
                , From = c.From
                , Give = give
                , Location = c.Location
                , ScoreBack = scoreBack
                , To = c.To
                , UtcOffset = utcOffset
                }
            end

        val json_compInputRaw : Json.json compInputRaw =
            Json.json_record_withOptional
                { CivilId = "civilId"
                , CompName = "compName"
                , Discipline = "discipline"
                , EarthModel = "earth"
                , EarthMath = "earthMath"
                , From = "from"
                , Give = "give"
                , Location = "location"
                , To = "to"
                , UtcOffset = "utcOffset"
                }
                {ScoreBack = "scoreBack"}

        fun parseCompInput (s : string) : Comp.compInput * string =
            let
                val (raw, rest) : compInputRaw * string = Json.fromJson' s
            in
                case fromRaw raw of
                  ParseError err => error <xml>{[err]}</xml>
                | ParseOk c => (c, rest)
            end
    in
        Json.mkJson
            { ToJson = fn c => Json.toJson (toRaw c)
            , FromJson = parseCompInput
            }
    end
