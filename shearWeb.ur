style container
style spacer
style content
style tile
style is_ancestor
style is_parent
style notification
style is_light
style subtitle
style is_vertical
style is_5
style is_child
style box
style is_7
style footer_cls
style is_size_7

fun siteCss () : transaction page =
    returnBlob (textBlob SiteCssAsset.content) (blessMime "text/css")

fun main () =
    return <xml>
        <head>
            <title>Ur/Web Shear Web</title>
            <link rel="stylesheet" type="text/css" href="http://localhost:8080/siteCss" />


            <meta name="viewport" content="width=device-width, initial-scale=1" />
        </head>
        <body>
            <div>
                <div>
                    <div class={container}>
                        <div class={spacer}></div>
                        <div class={content}>
                            <div class={classes tile is_ancestor}>
                                <div class={classes tile is_parent}>
                                    <article class={classes tile (classes is_child (classes notification is_light))}>
                                        <p>Shear Web</p>
                                        <p class={subtitle}>Comps scored with <a href="https://flaretiming.com">Flare Timing</a> and
                                            presented with
                                            <a href="http://www.impredicative.com/ur/">Ur/Web</a>
                                        </p>
                                    </article>
                                </div>
                            </div>
                            <p>Want <a href="https://flaretiming.com/posts/2018-12-19-add-a-comp.html">your comp here</a>?</p>
                            <div class={classes tile is_ancestor}>
                                <div class={classes is_vertical is_5}>
                                    <div class={tile}>
                                        <div class={classes tile is_vertical}>
                                            <div class={classes is_child box}>
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
                                            <div class={classes is_child box}>
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
                                <div class={classes is_vertical is_7}>
                                    <div class={tile}>
                                        <div class={classes tile is_vertical}>
                                            <div class={classes is_child box}>
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
                <footer class={footer_cls}>
                    <div class={container}>
                        <div class={content}>
                            <div class={is_size_7}><strong title="app-view-0.29 2020-12-19T14:27">Flare Timing</strong> by
                                <a href="http://www.blockscope.com" target="_blank">Block Scope</a><br/>(<a
                                    href="http://www.flaretiming.com/about.html" target="_blank">About</a>, <a
                                    href="http://www.flaretiming.com/disclaim.html" target="_blank">Disclaimer</a>,
                                <a href="http://www.flaretiming.com/blog.html" target="_blank">Blog</a>)<br/><br/>Map data
                                © <a href="http://www.openstreetmap.org/copyright" target="_blank">OpenStreetMap</a> contributors
                            </div>
                        </div>
                    </div>
                </footer>
            </div>
        </body>
    </xml>
