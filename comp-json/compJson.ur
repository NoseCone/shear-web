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

type earthModelRaw =
    { Sphere : option {Radius : metres}
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
    , ScoreBack : option seconds
    , To : string
    , UtcOffset : {TimeZoneMinutes : int}
    }

val json_compInput : Json.json Comp.compInput =
    let
        fun fromRaw (raw : compInputRaw) : parseResult Comp.compInput =
            let
                val earthModelResult : parseResult Comp.earthModel =
                    case (raw.Earth.Sphere, raw.Earth.Ellipsoid) of
                      (Some sphere, None) =>
                        let
                            val Metres r = sphere.Radius
                        in
                            ParseOk (Comp.EarthAsSphere {Radius = r})
                        end
                    | (None, Some ellipsoid) => ParseOk (Comp.EarthEllipsoid ellipsoid)
                    | (Some _, Some _) => ParseError "Invalid earth model: found both sphere and ellipsoid fields"
                    | (None, None) => ParseError "Missing earth model: expected earth.sphere or earth.ellipsoid"

                val disciplineOpt : option Comp.discipline =
                    if raw.Discipline = "hg" then Some Comp.HangGliding
                    else if raw.Discipline = "pg" then Some Comp.Paragliding
                    else None

                val scoreBack : option Comp.scoreBackTime =
                    Option.mp (fn (Seconds s) => Comp.ScoreBackTime s) raw.ScoreBack
            in
                case earthModelResult of
                  ParseError err => ParseError err
                | ParseOk earthModel =>
                    case disciplineOpt of
                      None => ParseError ("Unsupported discipline value in JSON: " ^ raw.Discipline)
                    | Some discipline =>
                        ParseOk
                            (Comp.CompInput
                                { CivilId = raw.CivilId
                                , EarthMath = raw.EarthMath
                                , Discipline = discipline
                                , Location = raw.Location
                                , From = raw.From
                                , To = raw.To
                                , CompName = raw.CompName
                                , UtcOffset = Comp.UtcOffset {TimeZoneMinutes = raw.UtcOffset.TimeZoneMinutes}
                                , EarthModel = earthModel
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
                val earth : earthModelRaw =
                    case c.EarthModel of
                      Comp.EarthAsSphere e => {Sphere = Some {Radius = Metres e.Radius}, Ellipsoid = None}
                    | Comp.EarthEllipsoid ellipsoid => {Sphere = None, Ellipsoid = Some ellipsoid}

                val discipline : string =
                    case c.Discipline of
                      Comp.HangGliding => "hg"
                    | Comp.Paragliding => "pg"

                val give : Comp.gives =
                    case c.GiveConfig of Comp.GiveConfig g => g

                val scoreBack : option seconds =
                    Option.mp (fn sb => case sb of Comp.ScoreBackTime s => Seconds s) c.ScoreBack

                val utcOffset : {TimeZoneMinutes : int} =
                    case c.UtcOffset of Comp.UtcOffset u => {TimeZoneMinutes = u.TimeZoneMinutes}
            in
                { CivilId = c.CivilId
                , CompName = c.CompName
                , Discipline = discipline
                , Earth = earth
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
                , Earth = "earth"
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
