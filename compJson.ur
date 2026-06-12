datatype compInputParseResult = CompInputParseError of string | CompInputParseOk of Comp.compInput
datatype nominalParseResult = NominalParseError of string | NominalParseOk of Comp.nominal

datatype parseResult t = ParseError of string | ParseOk of t

fun fromParseCompInput (r : parseResult Comp.compInput) : compInputParseResult =
  case r of
    ParseError err => CompInputParseError err
  | ParseOk v => CompInputParseOk v

fun fromParseNominal (r : parseResult Comp.nominal) : nominalParseResult =
  case r of
    ParseError err => NominalParseError err
  | ParseOk v => NominalParseOk v

datatype scoreBackParseResult = ScoreBackParseError of string | ScoreBackParseOk of Comp.scoreBackTime

datatype earthModelParseResult = EarthModelParseError of string | EarthModelParseOk of Comp.earthModel

fun parseScoreBackTime (raw : string) : scoreBackParseResult =
  let
    val n = strlen raw
  in
    if n < 3 then
      ScoreBackParseError "Invalid scoreBack; expected '<number> s'"
    else if strsub raw (n - 2) <> #" " || strsub raw (n - 1) <> #"s" then
      ScoreBackParseError ("Invalid scoreBack units; expected '<number> s', a quantity of seconds: " ^ raw)
    else
      case (read (substring raw 0 (n - 2)) : option float) of
        None => ScoreBackParseError ("Invalid scoreBack number: " ^ raw)
      | Some seconds => ScoreBackParseOk (Comp.ScoreBackTime seconds)
  end

fun parseNominalJson (json : string) : transaction nominalParseResult =
  parsed <- CompParse.parseNominal json;

  distance <- CompParse.nominalDistance parsed;
  freeDist <- CompParse.nominalFree parsed;
  time <- CompParse.nominalTime parsed;
  goal <- CompParse.nominalGoal parsed;
  launch <- CompParse.nominalLaunch parsed;

  CompParse.freeNominal parsed;
  return (fromParseNominal (ParseOk (Comp.Nominal
    { Distance = distance
    , Free = freeDist
    , Time = time
    , Goal = goal
    , Launch = launch
    })))

fun parseCompInputJson (json : string) : transaction compInputParseResult =
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
    val scoreBackResult : option scoreBackParseResult =
      case scoreBackRaw of
        None => None
      | Some raw => Some (parseScoreBackTime raw)

    val earthModelResult : earthModelParseResult =
      case earthRadius of
        Some radius =>
          (case earthEquatorialR of
             Some _ => EarthModelParseError "Invalid earth model: found both sphere and ellipsoid fields"
           | None =>
               case earthRecipF of
                 Some _ => EarthModelParseError "Invalid earth model: recipF without ellipsoid.equatorialR"
               | None => EarthModelParseOk (Comp.EarthAsSphere {Radius = radius}))
      | None =>
          case earthEquatorialR of
            None => EarthModelParseError "Missing earth model: expected earth.sphere or earth.ellipsoid"
          | Some equatorialR =>
              case earthRecipF of
                None => EarthModelParseError "Incomplete earth ellipsoid: missing recipF"
              | Some recipF => EarthModelParseOk (Comp.EarthEllipsoid {EquatorialR = equatorialR, RecipF = recipF})

    val disciplineOpt =
      if disciplineCode = "hg" then Some Comp.HangGliding
      else if disciplineCode = "pg" then Some Comp.Paragliding
      else None

    val scoreBack : option Comp.scoreBackTime =
      case scoreBackResult of
        None => None
      | Some (ScoreBackParseOk sb) => Some sb
      | Some (ScoreBackParseError _) => None
  in
    case earthModelResult of
      EarthModelParseError err =>
        CompParse.free parsed;
        return (fromParseCompInput (ParseError err))
    | EarthModelParseOk earthModel =>
        case scoreBackResult of
          Some (ScoreBackParseError err) =>
            CompParse.free parsed;
            return (fromParseCompInput (ParseError err))
        | _ =>
            case disciplineOpt of
              None =>
                CompParse.free parsed;
                return (fromParseCompInput (ParseError ("Unsupported discipline value in JSON: " ^ disciplineCode)))
            | Some discipline =>
                CompParse.free parsed;
                return (fromParseCompInput (ParseOk (Comp.CompInput
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
                  })))
  end
