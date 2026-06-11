fun render (comp : Comp.compInput) : string =
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
            Comp.GiveConfig g =>
              case g.GiveDistance of
                None => "None"
              | Some d => d

        val giveFraction =
          case c.GiveConfig of
            Comp.GiveConfig g => show g.GiveFraction

        val scoreBack =
          case c.ScoreBack of
            None => "None"
          | Some sb =>
              case sb of
                Comp.ScoreBackTime s => show s ^ " s"
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
        ^ "ScoreBack: " ^ scoreBack
      end

fun widget (compName : string) : transaction page =
    output <- source <xml><p>Not fetched yet.</p></xml>;

    return <xml>
      <head>
        <title>{[compName]}</title>
      </head>
      <body>
        <button value="Fetch comps JSON"
                onclick={fn _ =>
                            set output <xml><p>Fetching and parsing...</p></xml>;
                            result <- rpc (Fetch.fetchAndParseCompInput compName);
                            set output (case result of
                                          CompJson.ParseError err =>
                                            <xml><h3>Parse failed</h3><p>{[err]}</p></xml>
                                        | CompJson.ParseOk comp =>
                                            <xml><h3>Parsed compInput</h3><pre>{[render comp]}</pre></xml>)}/>

        <dyn signal={signal output}/>
      </body>
    </xml>
