style quote

fun add x y : float = x + y

val compsUrl = "http://2020-meduno.flaretiming.com/json/comp-input/comps.json"

fun fetchCompsJson () : transaction string =
  CompsFetch.fetch compsUrl

fun compsWidget () : transaction xbody =
  let
    val x : float = add 3. 4.
    val y : string = show (add 5. 9.)
  in
    output <- source <xml><p>Not fetched yet.</p></xml>;

    return <xml>
      <div class={quote}>Here's a quote.</div>
      <span>{txt (add 1.1 2.)}</span>
      <span>{txt x}</span>
      <span>{txt y}</span>

      <hr/>

      <button value="Fetch comps JSON"
              onclick={fn _ =>
                          set output <xml><p>Fetching...</p></xml>;
                          json <- rpc (fetchCompsJson ());
                          set output <xml><h3>Fetched raw JSON</h3><pre>{[json]}</pre></xml>}/>

      <dyn signal={signal output}/>
    </xml>
  end

fun main () =
  c <- compsWidget ();
  return <xml>
    <head>
      <link rel="stylesheet" type="text/css" href="http://adam.chlipala.net/style.css"/>
    </head>
    <body>{c}</body>
  </xml>
