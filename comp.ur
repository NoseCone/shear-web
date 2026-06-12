datatype utcOffset =
  UtcOffset of {TimeZoneMinutes : int}

datatype discipline =
  HangGliding
| Paragliding

datatype earthSphere =
  EarthSphere of string

datatype earthModel =
    EarthAsSphere of {Radius : string}
  | EarthEllipsoid of {EquatorialR: string, RecipF : string}

datatype giveConfig =
  GiveConfig of {GiveDistance : option string, GiveFraction: float}

datatype scoreBackTime =
  ScoreBackTime of float

datatype nominal =
  Nominal of
  { Distance : string
  , Free : string
  , Time : string
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
