style quote

val compsUrl = "http://2020-meduno.flaretiming.com/json/comp-input/comps.json"

fun fetchCompsJson () : transaction string =
  CompsFetch.fetch compsUrl

fun compsWidget () : transaction xbody =
    output <- source <xml><p>Not fetched yet.</p></xml>;

    return <xml>
      <button value="Fetch comps JSON"
              onclick={fn _ =>
                          set output <xml><p>Fetching...</p></xml>;
                          json <- rpc (fetchCompsJson ());
                          set output <xml><h3>Fetched raw JSON</h3><pre>{[json]}</pre></xml>}/>

      <dyn signal={signal output}/>
    </xml>

fun main () =
  c <- compsWidget ();
  return <xml>
    <head>
      <link rel="stylesheet" type="text/css" href="http://adam.chlipala.net/style.css"/>
    </head>
    <body>{c}</body>
  </xml>
