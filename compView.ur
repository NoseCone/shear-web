fun render (comp : Comp.compInput) : string =
  case comp of
    Comp.CompInput c =>
      let
        val tz =
          case c.UtcOffset of
            Comp.UtcOffset u => show u.TimeZoneMinutes

        val earthModelText =
          case c.EarthModel of
            Comp.EarthAsSphere e =>
              "Earth.sphere.radius: " ^ e.Radius
          | Comp.EarthEllipsoid e =>
              "Earth.ellipsoid.equatorialR: " ^ e.EquatorialR ^ "\n"
              ^ "Earth.ellipsoid.recipF: " ^ e.RecipF

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
        ^ earthModelText ^ "\n"
        ^ "Give.giveDistance: " ^ giveDistance ^ "\n"
        ^ "Give.giveFraction: " ^ giveFraction ^ "\n"
        ^ "ScoreBack: " ^ scoreBack
      end

fun metric (label : string) (value : string) (accent : css_class) : xbody =
    <xml>
      <div class={Bulma.control}>
        <div class={classes Bulma.tags Bulma.has_addons}>
          <span class={Bulma.tag}>{[label]}</span>
          <span class={classes Bulma.tag accent}>{[value]}</span>
        </div>
      </div>
    </xml>

fun summary (comp : Comp.compInput) (nominal : option Comp.nominal) : xbody =
  case comp of
    Comp.CompInput c =>
      let
        val tz =
          case c.UtcOffset of
            Comp.UtcOffset u => show u.TimeZoneMinutes

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

        val nominalDistance =
          case nominal of
            None => "Unknown"
          | Some n =>
              case n of
                Comp.Nominal x => x.Distance

        val nominalFree =
          case nominal of
            None => "Unknown"
          | Some n =>
              case n of
                Comp.Nominal x => x.Free

        val nominalTime =
          case nominal of
            None => "Unknown"
          | Some n =>
              case n of
                Comp.Nominal x => x.Time

        val nominalGoal =
          case nominal of
            None => "Unknown"
          | Some n =>
              case n of
                Comp.Nominal x => show x.Goal

        val nominalLaunch =
          case nominal of
            None => "Unknown"
          | Some n =>
              case n of
                Comp.Nominal x => show x.Launch
      in
        <xml>
          <div>
            <div class={Bulma.container}>
              <div class={Bulma.spacer}></div>
              <section>
                <div class={classes Bulma.container Bulma.is_size_7}>
                  <div class={Bulma.spacer}></div>
                  <div class={Bulma.container}>
                    <div class={classes Bulma.tile Bulma.is_ancestor}>
                      <div class={Bulma.tile}>
                        <div class={classes Bulma.tile Bulma.is_parent}>
                          <div class={classes Bulma.tile (classes Bulma.is_child Bulma.box)}>
                            <p class={classes Bulma.title Bulma.is_3}>{[c.CompName]}</p>
                            <p class={classes Bulma.title Bulma.is_5}>{[c.From ^ " to " ^ c.To ^ ", " ^ c.Location]}</p>
                            <div class={Bulma.example}>
                              <div class={classes Bulma.field (classes Bulma.is_grouped Bulma.is_grouped_multiline)}>
                                {metric "UTC offset" tz Bulma.is_warning}
                                {metric "Minimum distance" giveDistance Bulma.is_black}
                                {metric "Nominal free" nominalFree Bulma.is_black}
                                {metric "Nominal distance" nominalDistance Bulma.is_info}
                                {metric "Nominal time" nominalTime Bulma.is_success}
                                {metric "Nominal goal" nominalGoal Bulma.is_primary}
                                {metric "Nominal launch" nominalLaunch Bulma.is_primary}
                                {metric "Give fraction" giveFraction Bulma.is_info}
                                {metric "Score-back time" scoreBack Bulma.is_danger}
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </section>
            </div>
          </div>
        </xml>
      end

fun widget (compName : string) : transaction page =
    compResult <- Fetch.fetchAndParseCompInput compName;
    nominalResult <- Fetch.fetchAndParseNominal compName;

    let
      val nominalOpt : option Comp.nominal =
        case nominalResult of
          CompJson.NominalParseError _ => None
        | CompJson.NominalParseOk nominal => Some nominal

      val nominalErr : option string =
        case nominalResult of
          CompJson.NominalParseError err => Some err
        | CompJson.NominalParseOk _ => None
    in
      return <xml>
        <head>
          <title>{[compName]}</title>
          <link rel="stylesheet" type="text/css" href="http://localhost:8080/css" />
          <meta name="viewport" content="width=device-width, initial-scale=1" />
        </head>
        <body>
          {case compResult of
             CompJson.CompInputParseError err =>
               <xml>
                 <div class={Bulma.container}>
                   <div class={Bulma.spacer}></div>
                   <div class={classes Bulma.notification Bulma.is_light}>
                     <h4>Parse failed</h4>
                     <p>{[err]}</p>
                   </div>
                 </div>
                 {Footer.render ()}
               </xml>
           | CompJson.CompInputParseOk comp =>
               <xml>
                 {summary comp nominalOpt}
                 {Footer.render ()}
                 <div class={Bulma.container}>
                   <div class={Bulma.spacer}></div>
                   {case nominalErr of
                      None => <xml></xml>
                    | Some err =>
                        <xml>
                          <div class={classes Bulma.notification Bulma.is_light}>
                            <h4>Nominals parse failed</h4>
                            <p>{[err]}</p>
                          </div>
                        </xml>}
                   <div class={Bulma.content}>
                     <h4>Parsed compInput</h4>
                     <pre>{[render comp]}</pre>
                   </div>
                 </div>
               </xml>}
        </body>
      </xml>
    end
