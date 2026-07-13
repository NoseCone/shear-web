open Quantity

datatype utcOffset = UtcOffset of {TimeZoneMinutes : int}
datatype discipline = HangGliding | Paragliding

type sphere = {Radius : metres}
type ellipsoid = {EquatorialR: metres, RecipF : float}

datatype earthModel =
    EarthSphere of sphere
  | EarthEllipsoid of ellipsoid

type gives = {GiveDistance : option string, GiveFraction: float}
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
datatype compInput =
  CompInput of
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
