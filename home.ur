open Bulma

fun compAnchor (compName : string) (label : string) : xbody =
    <xml><a link={CompView.widget compName}>{[label]}</a></xml>

fun paragliding () =
   <xml>
        <h3>Paragliding</h3>
        <p></p>
        <ul>
            <li>Italian Open
                {compAnchor "2020-italy-open" "2020"}
            </li>
            <li>Dalmatian
                {compAnchor "2019-dalmatian" "2019"}
                {compAnchor "2018-dalmatian" "2018"}
            </li>
            <ul>
                <p></p>
            </ul>
        </ul>
   </xml>

fun archetypes () =
    <xml>
        <h3>Comp Archetypes</h3>
        <p></p>
        <ul>
            <li>{compAnchor "1976-never-land" "1976 Never Land"}</li>
            <li>{compAnchor "1989-lift-lines" "1989 Lift Lines"}</li>
            <ul>
                <p></p>
            </ul>
        </ul>
    </xml>

fun oceania () =
    <xml>
        <h5>Oceania</h5>
        <ul>
            <li>Forbes Flatlands
                {compAnchor "2018-forbes" "2018"}
                {compAnchor "2017-forbes" "2017"}
                {compAnchor "2016-forbes" "2016"}
                {compAnchor "2015-forbes" "2015"}
                {compAnchor "2014-forbes" "2014"}
                {compAnchor "2012-forbes" "2012"}
            </li>
            <li>Dalby Big Air {compAnchor "2017-dalby" "2017"}</li>
        </ul>
    </xml>

fun europe () =
    <xml>
        <h5>Europe</h5>
        <ul>
            <li>Meduno
                {compAnchor "2020-meduno" "2020"}
            </li>
            <li>Tolmezzo
                {compAnchor "2019-italy" "2019"}
            </li>
        </ul>
    </xml>

fun americas () =
    <xml>
        <h5>Americas</h5>
        <ul>
            <li>Green Swamp Klassic 2016
                {compAnchor "2016-greenswamp" "Topless"}
                {compAnchor "2016-greenswamp-sport" "Kingposted"}
            </li>
            <li>Big Spring
                {compAnchor "2016-big-spring" "2016"}
            </li>
            <li>QuestAir Open
                {compAnchor "2016-quest" "2016"}
            </li>
        </ul>
    </xml>

fun hanggliding () =
    <xml>
        <h3>Hang Gliding</h3>
        {oceania ()}
        {europe ()}
        {americas ()}
    </xml>

fun header () =
    <xml>
        <article class="tile is-child notification is-light">
            <p>Shear Web</p>
            <p class="subtitle">Comps scored with <a href="http://flaretiming.com" target="_blank">Flare Timing</a> and
                presented with
                <a href="http://www.impredicative.com/ur/" target="_blank">Ur/Web</a>
            </p>
        </article>
    </xml>

fun invite () =
    <xml>
        <p>Want <a href="http://flaretiming.com/posts/2018-12-19-add-a-comp.html" target="_blank">your comp here</a>?</p>
    </xml>

fun main () : transaction page =
    return <xml>
        <head>
            <title>Ur/Web Shear Web</title>
            <link rel="stylesheet" type="text/css" href="http://2017-dalby.flaretiming.com/styles.css" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
        </head>
        <body>
            <div class="spacer"></div>
            <div class="container is-size-7">
                <div class="content">
                    <div class="tile is-ancestor">
                        <div class="tile is-parent">{header ()}</div>
                    </div>
                    {invite ()}
                    <div class="tile is-ancestor">
                        <div class="tile is-vertical is-5">
                            <div class="tile">
                                <div class="tile is-parent is-vertical">
                                    <div class="is-child box">{paragliding ()}</div>
                                    <div class="is-child box">{archetypes ()}</div>
                                </div>
                            </div>
                        </div>
                        <div class="tile is-vertical is-7">
                            <div class="tile">
                                <div class="tile is-parent is-vertical">
                                    <div class="is-child box">{hanggliding ()}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="spacer"></div>
            {Footer.render ()}
        </body>
    </xml>
