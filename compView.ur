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
                            <nav class={Bulma.breadcrumb} aria-label="breadcrumbs">
                              <ul>
                                <li><a href="http://localhost:8080/main">Shear Web (Ur/Web)</a></li>
                                <li class={Bulma.is_active}>{[c.CompName]}</li>
                              </ul>
                            </nav>
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

fun joinZoneNames (zones : list Comp.rawZone) : string =
  case zones of
    [] => ""
  | z :: zs =>
      z.ZoneName ^
      (case zs of
         [] => ""
       | _ => "-" ^ joinZoneNames zs)

fun taskRows (tasks : list Comp.compTask) (lengths : list Comp.taskLength) (i : int) =
  case tasks of
    [] => <xml></xml>
  | t :: ts =>
      let
        val turnpoints = joinZoneNames t.Zones.Raw
        val stoppedText =
          case t.Stopped of
            None => ""
          | Some _ => "STOPPED"

        val cancelledText =
          case t.Cancelled of
            None => ""
          | Some True => "CANCELLED"
          | Some False => ""

        val distanceText =
          case lengths of
            [] => ""
          | d :: _ => show d ^ " km"

        val nextLengths =
          case lengths of
            [] => []
          | _ :: ls => ls
      in
        <xml>
          <tr>
            <td>{[show i]}</td>
            <td class={Bulma.td_task_name}>{[t.TaskName]}</td>
            <td class={Bulma.td_task_tps}>{[turnpoints]}</td>
            <td class={Bulma.td_task_dist}>{[distanceText]}</td>
            <td class={Bulma.td_task_stopped}>{[stoppedText]}</td>
            <td class={Bulma.td_task_cancelled}>{[cancelledText]}</td>
          </tr>
          {taskRows ts nextLengths (i + 1)}
        </xml>
      end

fun tasksTable (tasks : list Comp.compTask) (lengths : list Comp.taskLength) =
  <xml>
    <table class={classes Bulma.table_cls Bulma.is_striped}>
      <thead>
        <tr>
          <th>#</th>
          <th class={Bulma.th_task_name}>Name</th>
          <th class={Bulma.th_task_tps}>Turnpoints</th>
          <th class={Bulma.th_task_dist}>Distance</th>
          <th class={Bulma.th_task_stopped}>Stopped</th>
          <th class={Bulma.th_task_cancelled}>Cancelled</th>
        </tr>
      </thead>
      <tbody>{taskRows tasks lengths 1}</tbody>
    </table>
  </xml>

fun statusCells (statuses : list string) =
  case statuses of
    [] => <xml></xml>
  | s :: ss =>
      <xml>
        {case s of
           "" => <xml><td></td></xml>
         | "DF" => <xml><td></td></xml>
         | _ => <xml><td>{[s]}</td></xml>}
        {statusCells ss}
      </xml>

fun pilotRows (pilots : list Comp.pilotStatus) =
  case pilots of
    [] => <xml></xml>
  | p :: ps =>
      <xml>
        <tr>
          <td class={Bulma.td_pid}>{[p.PilotId]}</td>
          <td>{[p.PilotName]}</td>
          {statusCells p.PilotStatus}
        </tr>
        {pilotRows ps}
      </xml>

fun taskNameHeaders (taskNames : list string) =
  case taskNames of
    [] => <xml></xml>
  | n :: ns =>
      <xml><th>{[n]}</th>{taskNameHeaders ns}</xml>

fun taskNamesFromTasks (tasks : list Comp.compTask) =
  case tasks of
    [] => []
  | t :: ts => t.TaskName :: taskNamesFromTasks ts

fun defaultTaskNames (n : int) (i : int) =
  if i > n then
    []
  else
    ("Task " ^ show i) :: defaultTaskNames n (i + 1)

fun countStrings (xs : list string) =
  case xs of
    [] => 0
  | _ :: ys => 1 + countStrings ys

fun pilotsTable (taskNames : list string) (pilots : list Comp.pilotStatus) =
  <xml>
    <table class={classes Bulma.table_cls (classes Bulma.is_bordered Bulma.is_striped)}>
      <thead>
        <tr>
          <th class={Bulma.th_pid}>Id</th>
          <th>Name</th>
          {taskNameHeaders taskNames}
        </tr>
      </thead>
      <tbody>{pilotRows pilots}</tbody>
    </table>
  </xml>

fun widget (compName : string) : transaction page =
    compResult <- Fetch.fetchAndParseCompInput compName;
    nominalResult <- Fetch.fetchAndParseNominal compName;
    tasksResult <- Fetch.fetchAndParseTasks compName;
    taskLengthsResult <- Fetch.fetchAndParseTaskLengths compName;
    pilotsResult <- Fetch.fetchAndParsePilots compName;

    let
      val nominalOpt : option Comp.nominal =
        case nominalResult of
          CompJson.NominalParseError _ => None
        | CompJson.NominalParseOk nominal => Some nominal

      val nominalErr : option string =
        case nominalResult of
          CompJson.NominalParseError err => Some err
        | CompJson.NominalParseOk _ => None

      val tasksOpt : option (list Comp.compTask) =
        case tasksResult of
          CompJson.TasksParseError _ => None
        | CompJson.TasksParseOk tasks => Some tasks

      val tasksErr : option string =
        case tasksResult of
          CompJson.TasksParseError err => Some err
        | CompJson.TasksParseOk _ => None

      val taskLengthsOpt : option (list Comp.taskLength) =
        case taskLengthsResult of
          CompJson.TaskLengthsParseError _ => None
        | CompJson.TaskLengthsParseOk lengths => Some lengths

      val taskLengthsErr : option string =
        case taskLengthsResult of
          CompJson.TaskLengthsParseError err => Some err
        | CompJson.TaskLengthsParseOk _ => None

      val pilotsOpt : option (list Comp.pilotStatus) =
        case pilotsResult of
          CompJson.PilotsParseError _ => None
        | CompJson.PilotsParseOk pilots => Some pilots

      val pilotsErr : option string =
        case pilotsResult of
          CompJson.PilotsParseError err => Some err
        | CompJson.PilotsParseOk _ => None

      val pilotTaskNames : list string =
        case tasksOpt of
          Some tasks => taskNamesFromTasks tasks
        | None =>
            case pilotsOpt of
              None => []
            | Some pilots =>
                case pilots of
                  [] => []
                | p :: _ => defaultTaskNames (countStrings p.PilotStatus) 1
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
                 <div class={Bulma.container}>
                   {case tasksOpt of
                      None => <xml></xml>
                    | Some tasks =>
                        <xml>
                          <div class={Bulma.spacer}></div>
                          {tasksTable tasks (case taskLengthsOpt of None => [] | Some lengths => lengths)}
                        </xml>}
                 </div>
                 {case pilotsOpt of
                    None => <xml></xml>
                  | Some pilots =>
                      <xml>
                        <div class={Bulma.container}>
                          <div class={Bulma.spacer}></div>
                          {pilotsTable pilotTaskNames pilots}
                        </div>
                      </xml>}
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
                   {case tasksErr of
                      None => <xml></xml>
                    | Some err =>
                        <xml>
                          <div class={classes Bulma.notification Bulma.is_light}>
                            <h4>Tasks parse failed</h4>
                            <p>{[err]}</p>
                          </div>
                        </xml>}
                   {case taskLengthsErr of
                      None => <xml></xml>
                    | Some err =>
                        <xml>
                          <div class={classes Bulma.notification Bulma.is_light}>
                            <h4>Task lengths parse failed</h4>
                            <p>{[err]}</p>
                          </div>
                        </xml>}
                   {case pilotsErr of
                      None => <xml></xml>
                    | Some err =>
                        <xml>
                          <div class={classes Bulma.notification Bulma.is_light}>
                            <h4>Pilots parse failed</h4>
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
