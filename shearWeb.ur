val css = Css.siteCss

fun main () =
    return <xml>
        <head>
            <title>Ur/Web Shear Web</title>
            <link rel="stylesheet" type="text/css" href="http://localhost:8080/css" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
        </head>
        <body>
            <div>
                <div>
                    <div class={Bulma.container}>
                        <div class={Bulma.spacer}></div>
                        <div class={Bulma.content}>
                            <div class={classes Bulma.tile Bulma.is_ancestor}>
                                <div class={classes Bulma.tile Bulma.is_parent}>
                                    <article class={classes Bulma.tile (classes Bulma.is_child (classes Bulma.notification Bulma.is_light))}>
                                        <p>Shear Web</p>
                                        <p class={Bulma.subtitle}>Comps scored with <a href="http://flaretiming.com" target="_blank">Flare Timing</a> and
                                            presented with
                                            <a href="http://www.impredicative.com/ur/" target="_blank">Ur/Web</a>
                                        </p>
                                    </article>
                                </div>
                            </div>
                            <p>Want <a href="http://flaretiming.com/posts/2018-12-19-add-a-comp.html" target="_blank">your comp here</a>?</p>
                            <div class={classes Bulma.tile Bulma.is_ancestor}>
                                <div class={classes Bulma.is_vertical Bulma.is_5}>
                                    <div class={Bulma.tile}>
                                        <div class={classes Bulma.tile Bulma.is_vertical}>
                                            <div class={classes Bulma.is_child Bulma.box}>
                                                <h3>Paragliding</h3>
                                                <p></p>
                                                <ul>
                                                    <li>Italian Open
                                                        <a link={CompView.widget("2020-italy-open")}>2020</a>
                                                    </li>
                                                    <li>Dalmatian
                                                        <a link={CompView.widget("2019-dalmatian")}>2019</a>
                                                        <a link={CompView.widget("2018-dalmatian")}>2018</a>
                                                    </li>
                                                    <ul>
                                                        <p></p>
                                                    </ul>
                                                </ul>
                                            </div>
                                            <div class={classes Bulma.is_child Bulma.box}>
                                                <h3>Comp Archetypes</h3>
                                                <p></p>
                                                <ul>
                                                    <li><a link={CompView.widget("1976-never-land")}>1976 Never Land</a></li>
                                                    <li><a link={CompView.widget("1989-lift-lines")}>1989 Lift Lines</a></li>
                                                    <ul>
                                                        <p></p>
                                                    </ul>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class={classes Bulma.is_vertical Bulma.is_7}>
                                    <div class={Bulma.tile}>
                                        <div class={classes Bulma.tile Bulma.is_vertical}>
                                            <div class={classes Bulma.is_child Bulma.box}>
                                                <h3>Hang Gliding</h3>
                                                <h5>Oceania</h5>
                                                <ul>
                                                    <li>Forbes Flatlands
                                                        <a link={CompView.widget("2018-forbes")}>2018</a>
                                                        <a link={CompView.widget("2017-forbes")}>2017</a>
                                                        <a link={CompView.widget("2016-forbes")}>2016</a>
                                                        <a link={CompView.widget("2015-forbes")}>2015</a>
                                                        <a link={CompView.widget("2014-forbes")}>2014</a>
                                                        <a link={CompView.widget("2012-forbes")}>2012</a>
                                                    </li>
                                                    <li>Dalby Big Air <a link={CompView.widget("2017-dalby")}>2017</a></li>
                                                </ul>
                                                <h5>Europe</h5>
                                                <ul>
                                                    <li>Meduno
                                                        <a link={CompView.widget("2020-meduno")}>2020</a>
                                                    </li>
                                                    <li>Tolmezzo
                                                        <a link={CompView.widget("2019-italy")}>2019</a>
                                                    </li>
                                                </ul>
                                                <h5>Americas</h5>
                                                <ul>
                                                    <li>Green Swamp Klassic 2016
                                                        <a link={CompView.widget("2016-greenswamp")}>Topless</a>
                                                        <a link={CompView.widget("2016-greenswamp-sport")}>Kingposted</a>
                                                    </li>
                                                    <li>Big Spring
                                                        <a link={CompView.widget("2016-big-spring")}>2016</a>
                                                    </li>
                                                    <li>QuestAir Open
                                                        <a link={CompView.widget("2016-quest")}>2016</a>
                                                    </li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                {Footer.render ()}
            </div>
        </body>
    </xml>
