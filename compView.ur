open Bulma
open FetchAndParse

fun metric (label : string) (value : string) (accent : css_class) : xbody =
    <xml>
        <div class="control">
            <div class="tags has-addons">
                <span class="tag">{[label]}</span>
                <span class={classes Bulma.tag accent}>{[value]}</span>
            </div>
        </div>
    </xml>

fun breadcrumb (compName : string) : xbody =
    <xml>
        <nav class={Bulma.breadcrumb} aria-label="breadcrumbs">
            <ul>
                <li><a href={bless "/main"}>Shear Web (Ur/Web)</a></li>
                <li class="is-active">{[compName]}</li>
            </ul>
        </nav>
    </xml>

fun compHeader ((Comp.CompInput c) : Comp.compInput) : xbody =
    <xml>
        <p class="titular is-3">{[c.CompName]}</p>
        <p class="titular is-5">{[c.From ^ " to " ^ c.To ^ ", " ^ c.Location]}</p>
    </xml>

fun summary ((Comp.CompInput c) : Comp.compInput) (nominal : option Comp.nominal) : xbody =
    let
        val tz = case c.UtcOffset of Comp.UtcOffset u => show u.TimeZoneMinutes ^ " mins"
        val Comp.GiveConfig g = c.GiveConfig

        val giveDistance =
            case g.GiveDistance of
              None => "None"
            | Some d => d

        fun nominalField f =
            case nominal of
              None => "Unknown"
            | Some (Comp.Nominal x) => f x

        val nominalDistance = nominalField (fn x => show x.Distance ^ " km")
        val nominalFree = nominalField (fn x => show x.Free ^ " km")
        val nominalTime = nominalField (fn x => show x.Time ^ " h")
        val nominalGoal = nominalField (fn x => show x.Goal)
        val nominalLaunch = nominalField (fn x => show x.Launch)

        val scoreBack =
            case c.ScoreBack of
              None => "None"
            | Some sb => case sb of Comp.ScoreBackTime s => show (round (s/ 60.)) ^ " mins"
    in
        <xml>
            <div class="example">
                <div class="field is-grouped is-grouped-multiline">
                    {metric "UTC offset" tz Bulma.is_warning}
                    {metric "minimum distance" giveDistance Bulma.is_black}
                    {metric "nominal free" nominalFree Bulma.is_black}
                    {metric "nominal distance" nominalDistance Bulma.is_info}
                    {metric "nominal time" nominalTime Bulma.is_success}
                    {metric "nominal goal" nominalGoal Bulma.is_primary}
                    {metric "nominal launch" nominalLaunch Bulma.is_primary}
                    {metric "score back time" scoreBack Bulma.is_danger}
                </div>
            </div>
        </xml>
    end

fun settingsTable ((Comp.CompInput c) : Comp.compInput) : xbody =
    let
        val giveDescription = case c.GiveConfig of Comp.GiveConfig g =>
                case g.GiveDistance of
                  None => "give fraction only, no give distance"
                | Some d => "give distance " ^ d ^ " and give fraction"

        val giveValue = case c.GiveConfig of Comp.GiveConfig g => show g.GiveFraction

        val earthDescription = case c.EarthModel of
              Comp.EarthAsSphere _ => "Sphere with radius"
            | Comp.EarthEllipsoid _ => "Ellipsoid"

        val earthValue = case c.EarthModel of
              Comp.EarthAsSphere e => show (round e.Radius) ^ " m" (* Use round to avoid scientific notation *)
            | Comp.EarthEllipsoid e => "equatorialR " ^ e.EquatorialR ^ " m, recipF " ^ e.RecipF
    in
        <xml>
            <table class="tabular is-bordered">
                <thead>
                    <tr>
                        <th colspan={3}></th>
                        <th>Value</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <th>* Give</th>
                        <td colspan={2}>{[giveDescription]}</td>
                        <td>{[giveValue]}</td>
                    </tr>
                    <tr>
                        <th>Earth model</th>
                        <td colspan={2}>{[earthDescription]}</td>
                        <td>{[earthValue]}</td>
                    </tr>
                    <tr>
                        <th colspan={3}>Earth math</th>
                        <td>{[c.EarthMath]}</td>
                    </tr>
                </tbody>
                <tfoot>
                    <tr>
                        <td colspan={4}>* Adjusting the turnpoint radius with some give for pilots just short of the control zone</td>
                    </tr>
                </tfoot>
            </table>
        </xml>
    end

datatype compTab = SettingsTab | TasksTab | PilotsTab

fun joinZoneNames (zones : list Comp.rawZone) : string =
    case zones of
      [] => ""
    | z :: zs => z.ZoneName ^ case zs of [] => "" | _ => "-" ^ joinZoneNames zs

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
                    <td class="td-task-name">{[t.TaskName]}</td>
                    <td class="td-task-tps">{[turnpoints]}</td>
                    <td class="td-task-dist">{[distanceText]}</td>
                    <td class="td-task-stopped">{[stoppedText]}</td>
                    <td class="td-task-cancelled">{[cancelledText]}</td>
                </tr>
                {taskRows ts nextLengths (i + 1)}
            </xml>
        end

fun tasksTable (tasks : list Comp.compTask) (lengths : list Comp.taskLength) =
    <xml>
        <table class="tabular is-striped">
            <thead>
                <tr>
                    <th>#</th>
                    <th class="th-task-name">Name</th>
                    <th class="th-task-tps">Turnpoints</th>
                    <th class="th-task-dist">Distance</th>
                    <th class="th-task-stopped">Stopped</th>
                    <th class="th-task-cancelled">Cancelled</th>
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
                <td class="td-pid">{[p.PilotId]}</td>
                <td>{[p.PilotName]}</td>
                {statusCells p.PilotStatus}
            </tr>
            {pilotRows ps}
        </xml>

fun taskNameHeaders (taskNames : list string) =
    case taskNames of
      [] => <xml></xml>
    | n :: ns => <xml><th>{[n]}</th>{taskNameHeaders ns}</xml>

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
        <table class="tabular is-bordered is-striped">
            <thead>
                <tr>
                    <th class="th-pid">Id</th>
                    <th>Name</th>
                    {taskNameHeaders taskNames}
                </tr>
            </thead>
            <tbody>{pilotRows pilots}</tbody>
        </table>
    </xml>

fun widget (compName : string) : transaction page =
    widgetTab compName TasksTab

and widgetSettings (compName : string) : transaction page =
    widgetTab compName SettingsTab

and widgetPilots (compName : string) : transaction page =
    widgetTab compName PilotsTab

and widgetTab (compName : string) (activeTab : compTab) : transaction page =
    compResult <- fetchAndParseCompInput compName;
    nominalResult <- fetchAndParseNominal compName;
    tasksResult <- fetchAndParseTasks compName;
    taskLengthsResult <- fetchAndParseTaskLengths compName;
    pilotsResult <- fetchAndParsePilots compName;
    idUw <- fresh; (* serves no purpose other than to show how to use #ids in Ur/Web *)

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
                <link rel="stylesheet" type="text/css" href="http://2017-dalby.flaretiming.com/styles.css" />
                <meta name="viewport" content="width=device-width, initial-scale=1" />
            </head>
            <body>
                {case compResult of
                  CompJson.CompInputParseError err =>
                    <xml>
                        <div class="container">
                            <div class="spacer"></div>
                            <div class="notification is-light">
                                <h4>Parse failed</h4>
                                <p>{[err]}</p>
                            </div>
                        </div>
                        {Footer.render ()}
                    </xml>
                | CompJson.CompInputParseOk comp =>
                    <xml>
                        <div class="spacer"></div>
                        <div id={idUw} class="container is-size-7">
                            <div>
                                <div class="spacer"></div>
                                <div class="container">
                                    <div class="tile is-ancestor">
                                        <div class="tile">
                                            <div class="tile is-parent">
                                                <div class="tile is-child box">
                                                    {compHeader comp}
                                                    {summary comp nominalOpt}
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="spacer"></div>
                                <div class="box">
                                    {case comp of Comp.CompInput c => breadcrumb c.CompName}
                                    <div class="tabs">
                                        <ul>
                                            {case activeTab of
                                              SettingsTab => <xml><li class="is-active"><a link={widgetSettings compName}>Settings</a></li></xml>
                                            | _ => <xml><li><a link={widgetSettings compName}>Settings</a></li></xml>}
                                            {case activeTab of
                                              TasksTab => <xml><li class="is-active"><a link={widget compName}>Tasks</a></li></xml>
                                            | _ => <xml><li><a link={widget compName}>Tasks</a></li></xml>}
                                            {case activeTab of
                                              PilotsTab => <xml><li class="is-active"><a link={widgetPilots compName}>Pilots</a></li></xml>
                                            | _ => <xml><li><a link={widgetPilots compName}>Pilots</a></li></xml>}
                                        </ul>
                                    </div>
                                    {case activeTab of
                                      SettingsTab => <xml>{settingsTable comp}</xml>
                                    | TasksTab =>
                                        <xml>
                                            {case tasksOpt of
                                              None => <xml></xml>
                                            | Some tasks =>
                                                tasksTable tasks (case taskLengthsOpt of None => [] | Some lengths => lengths)}
                                        </xml>
                                    | PilotsTab =>
                                        <xml>
                                            {case pilotsOpt of
                                              None => <xml></xml>
                                            | Some pilots => pilotsTable pilotTaskNames pilots}
                                        </xml>}
                                </div>
                            </div>
                        </div>
                        {Footer.render ()}
                        <div class="container">
                            <div class="spacer"></div>
                            {case nominalErr of
                              None => <xml></xml>
                            | Some err =>
                                <xml>
                                    <div class="notification is-light">
                                        <h4>Nominals parse failed</h4>
                                        <p>{[err]}</p>
                                    </div>
                                </xml>}
                            {case tasksErr of
                              None => <xml></xml>
                            | Some err =>
                                <xml>
                                    <div class="notification is-light">
                                        <h4>Tasks parse failed</h4>
                                        <p>{[err]}</p>
                                    </div>
                                </xml>}
                            {case taskLengthsErr of
                              None => <xml></xml>
                            | Some err =>
                                <xml>
                                    <div class="notification is-light">
                                        <h4>Task lengths parse failed</h4>
                                        <p>{[err]}</p>
                                    </div>
                                </xml>}
                            {case pilotsErr of
                              None => <xml></xml>
                            | Some err =>
                                <xml>
                                    <div class="notification is-light">
                                        <h4>Pilots parse failed</h4>
                                        <p>{[err]}</p>
                                    </div>
                                </xml>}
                        </div>
                    </xml>}
            </body>
        </xml>
    end
