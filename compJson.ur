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
  earthEquatorialR <- CompParse.earthEquatorialR parsed;
  earthRecipF <- CompParse.earthRecipF parsed;
  giveDistance <- CompParse.giveDistance parsed;
  giveFraction <- CompParse.giveFraction parsed;
  scoreBackRaw <- CompParse.scoreBack parsed;

  let
    val scoreBackResult =
      case scoreBackRaw of
        None => ParseOk None
      | Some raw =>
          case parseScoreBackTime raw of
            ParseError err => ParseError err
          | ParseOk scoreBack => ParseOk (Some scoreBack)

    val earthModelResult : parseResult Comp.earthModel =
      case earthRadius of
        Some radius =>
          (case earthEquatorialR of
             Some _ => ParseError "Invalid earth model: found both sphere and ellipsoid fields"
           | None =>
               case earthRecipF of
                 Some _ => ParseError "Invalid earth model: recipF without ellipsoid.equatorialR"
               | None => ParseOk (Comp.EarthAsSphere {Radius = radius}))
      | None =>
          case earthEquatorialR of
            None => ParseError "Missing earth model: expected earth.sphere or earth.ellipsoid"
          | Some equatorialR =>
              case earthRecipF of
                None => ParseError "Incomplete earth ellipsoid: missing recipF"
              | Some recipF => ParseOk (Comp.EarthEllipsoid {EquatorialR = equatorialR, RecipF = recipF})

    val disciplineOpt =
      if disciplineCode = "hg" then Some Comp.HangGliding
      else if disciplineCode = "pg" then Some Comp.Paragliding
      else None
  in
    case earthModelResult of
      ParseError err =>
        CompParse.free parsed;
        return (ParseError err)
    | ParseOk earthModel =>
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
                  , EarthModel = earthModel
                  , GiveConfig = Comp.GiveConfig
                      { GiveDistance = giveDistance
                      , GiveFraction = giveFraction
                      }
                  , ScoreBack = scoreBack
                  }))
  end
