fun parseCompInputJson (json : string) : transaction (option Comp.compInput) =
  parsed <- CompParse.parse json;

  civilId <- CompParse.civilId parsed;
  earthMath <- CompParse.earthMath parsed;
  disciplineCode <- CompParse.discipline parsed;
  location <- CompParse.location parsed;
  fromDate <- CompParse.fromDate parsed;
  toDate <- CompParse.toDate parsed;
  compName <- CompParse.compName parsed;
  utcOffsetMinutes <- CompParse.utcOffsetMinutes parsed;
  earthRadius <- CompParse.earthRadius parsed;
  giveDistance <- CompParse.giveDistance parsed;
  giveFraction <- CompParse.giveFraction parsed;
  scoreBack <- CompParse.scoreBack parsed;

  CompParse.free parsed;

  let
    val disciplineOpt =
      if disciplineCode = "hg" then Some Comp.HangGliding
      else if disciplineCode = "pg" then Some Comp.Paragliding
      else None
  in
    case disciplineOpt of
      None => return None
    | Some discipline =>
        return (Some (Comp.CompInput
          { CivilId = civilId
          , EarthMath = earthMath
          , Discipline = discipline
          , Location = location
          , From = fromDate
          , To = toDate
          , CompName = compName
          , UtcOffset = Comp.UtcOffset {TimeZoneMinutes = utcOffsetMinutes}
          , EarthModel = Comp.EarthAsSphere {Radius = earthRadius}
          , GiveConfig = Comp.GiveConfig
              { GiveDistance = giveDistance
              , GiveFraction = giveFraction
              }
          , ScoreBack = scoreBack
          }))
  end
