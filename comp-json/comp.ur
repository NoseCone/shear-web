open Quantity

type sphere = {Radius : metres}
type ellipsoid = {EquatorialR: metres, RecipF : float}
type gives = {GiveDistance : option string, GiveFraction: float}
type tzMinutes = {TimeZoneMinutes : int}

datatype utcOffset = UtcOffset of tzMinutes

datatype discipline = HangGliding | Paragliding

val show_discipline : show discipline =
    mkShow (fn d => case d of HangGliding => "hg" | Paragliding => "pg")

datatype earthModel =
    EarthSphere of sphere
  | EarthEllipsoid of ellipsoid

datatype giveConfig = GiveConfig of gives
datatype scoreBackTime = ScoreBackTime of seconds

datatype nominal =
  Nominal of
    { Distance : kilometres
    , Free : kilometres
    , Time : hours
    , Goal : float
    , Launch : float
    }

(* For now, we don't care too much for types other than strings, since we're
just displaying the comp input. As as example of parsing with failure, look at
ScoreBack. *)
type compSettings =
    { CivilId : string
    , CompName : string
    , Location : string
    , UtcOffset : utcOffset
    , From : string
    , To : string
    , Discipline : discipline
    , EarthModel : earthModel
    , EarthMath : string
    , GiveConfig : giveConfig
    , ScoreBack : option scoreBackTime
    }

datatype compInput = CompInput of compSettings

type taskLength = float
type rawZone = {ZoneName: string}
type stopped = {Announced: string, Retroactive: string}

type compTask =
    { TaskName: string
    , Zones: { Raw: list rawZone }
    , Stopped: option stopped
    , Cancelled: option bool
    }

type pilotStatus =
    { PilotId: string
    , PilotName: string
    , PilotStatus: list string
    }
