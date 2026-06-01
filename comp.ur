datatype utcOffset =
  UtcOffset of {TimeZoneMinutes : int}

datatype earthSphere =
  EarthSphere of string

datatype earthModel =
  EarthAsSphere of {Radius : string}

datatype giveConfig =
  GiveConfig of {GiveDistance : string, GiveFraction: float}

datatype compInput =
  CompInput of
    { CivilId : string
    , EarthMath : string
    , Discipline : string
    , Location : string
    , From : string
    , To : string
    , CompName : string
    , UtcOffset : utcOffset
    , EarthModel : earthModel
    , GiveConfig : giveConfig
    , ScoreBack : string
    }
