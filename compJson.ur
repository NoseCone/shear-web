datatype parseResult t = ParseError of string | ParseOk of t

fun parseScoreBackTime (raw : string) : parseResult Comp.scoreBackTime =
  let
    val n = strlen raw
  in
    if n < 3 then
      ParseError "Invalid scoreBack; expected '<number> s'"
    else if strsub raw (n - 2) <> #" " || strsub raw (n - 1) <> #"s" then
      ParseError ("Invalid scoreBack units; expected '<number> s', a quantity of seconds: " ^ raw)
    else
      case (read (substring raw 0 (n - 2)) : option float) of
        None => ParseError ("Invalid scoreBack number: " ^ raw)
      | Some seconds => ParseOk (Comp.ScoreBackTime seconds)
  end

fun parseCompInputJson (json : string) : transaction (parseResult Comp.compInput) =
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
  scoreBackRaw <- CompParse.scoreBack parsed;

  let
    val scoreBackResult = parseScoreBackTime scoreBackRaw

    val disciplineOpt =
      if disciplineCode = "hg" then Some Comp.HangGliding
      else if disciplineCode = "pg" then Some Comp.Paragliding
      else None
  in
    case scoreBackResult of
      ParseError err =>
        CompParse.free parsed;
        return (ParseError err)
    | ParseOk scoreBack =>
        case disciplineOpt of
          None =>
            CompParse.free parsed;
            return (ParseError ("Unsupported discipline value in JSON: " ^ disciplineCode))
        | Some discipline =>
            CompParse.free parsed;
            return (ParseOk (Comp.CompInput
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
