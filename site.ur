style quote

fun fetchCompJson (compName : string) : transaction string =
  let
    CompFetch.fetch (mkCompUrl compName)
  where
    fun mkCompUrl (compName : string) =
      "http://" ^ compName ^ ".flaretiming.com/json/comp-input/comps.json"
  end

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

fun renderComp (comp : Comp.compInput) : string =
  case comp of
    Comp.CompInput c =>
      let
        val tz =
          case c.UtcOffset of
            Comp.UtcOffset u => show u.TimeZoneMinutes

        val radius =
          case c.EarthModel of
            Comp.EarthAsSphere e => e.Radius

        val giveDistance =
          case c.GiveConfig of
            Comp.GiveConfig g => g.GiveDistance

        val giveFraction =
          case c.GiveConfig of
            Comp.GiveConfig g => show g.GiveFraction
      in
        "CivilId: " ^ c.CivilId ^ "\n"
        ^ "EarthMath: " ^ c.EarthMath ^ "\n"
        ^ "Discipline: "
        ^ (case c.Discipline of
             Comp.HangGliding => "hg"
           | Comp.Paragliding => "pg")
        ^ "\n"
        ^ "Location: " ^ c.Location ^ "\n"
        ^ "From: " ^ c.From ^ "\n"
        ^ "To: " ^ c.To ^ "\n"
        ^ "CompName: " ^ c.CompName ^ "\n"
        ^ "UtcOffset.TimeZoneMinutes: " ^ tz ^ "\n"
        ^ "Earth.sphere.radius: " ^ radius ^ "\n"
        ^ "Give.giveDistance: " ^ giveDistance ^ "\n"
        ^ "Give.giveFraction: " ^ giveFraction ^ "\n"
        ^ "ScoreBack: " ^ c.ScoreBack
      end

fun fetchAndParseCompInput (compName : string) : transaction (option Comp.compInput) =
  json <- fetchCompJson compName;
  parseCompInputJson json

fun compWidget () : transaction xbody =
    output <- source <xml><p>Not fetched yet.</p></xml>;

    return <xml>
      <button value="Fetch comps JSON"
              onclick={fn _ =>
                          set output <xml><p>Fetching and parsing...</p></xml>;
                          compOpt <- rpc (fetchAndParseCompInput "2020-meduno");
                          set output (case compOpt of
                                        None => <xml><h3>Parse failed</h3><p>Unsupported discipline value in JSON.</p></xml>
                                      | Some comp => <xml><h3>Parsed compInput</h3><pre>{[renderComp comp]}</pre></xml>)}/>

      <dyn signal={signal output}/>
    </xml>

fun main () =
  c <- compWidget ();
  return <xml>
    <head>
      <link rel="stylesheet" type="text/css" href="http://adam.chlipala.net/style.css"/>
    </head>
    <body>{c}</body>
  </xml>
