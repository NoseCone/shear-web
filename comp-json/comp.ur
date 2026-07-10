open Quantity

datatype utcOffset = UtcOffset of {TimeZoneMinutes : int}
datatype discipline = HangGliding | Paragliding
datatype earthSphere = EarthSphere of string
type ellipsoid = {EquatorialR: string, RecipF : float}

datatype earthModel =
    EarthAsSphere of {Radius : float}
  | EarthEllipsoid of ellipsoid

type gives = {GiveDistance : option string, GiveFraction: float}
datatype giveConfig = GiveConfig of gives
datatype scoreBackTime = ScoreBackTime of float

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
datatype compInput =
  CompInput of
    { CivilId : string
    , EarthMath : string
    , Discipline : discipline
    , Location : string
    , From : string
    , To : string
    , CompName : string
    , UtcOffset : utcOffset
    , EarthModel : earthModel
    , GiveConfig : giveConfig
    , ScoreBack : option scoreBackTime
    }

type taskLength = float
type rawZone = { ZoneName: string }
type stopped = { Announced: string, Retroactive: string }

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
