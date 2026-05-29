style quote

fun add x y : float = x + y

val compsUrl = "http://2020-meduno.flaretiming.com/json/comp-input/comps.json"

fun fetchCompsJson () : transaction string =
  CompsFetch.fetch compsUrl

fun renderPage (fetched : option string) =
  let
    val x : float = add 3. 4.
    val y : string = show (add 5. 9.)
  in
    return <xml>
      <head>
        <link rel="stylesheet" type="text/css" href="http://adam.chlipala.net/style.css"/>
      </head>

      <body>
        <div class={quote}>Here's a quote.</div>
        <span>{txt (add 1.1 2.)}</span>
        <span>{txt x}</span>
        <span>{txt y}</span>

        <hr/>

        <form>
          <submit value="Fetch comps JSON" action={fetchAndShow}/>
        </form>

        {case fetched of
           None => <xml><p>Not fetched yet.</p></xml>
         | Some raw => <xml><h3>Fetched raw JSON</h3><pre>{[raw]}</pre></xml>}
      </body>
    </xml>
  end

and fetchAndShow () =
  raw <- fetchCompsJson ();
  renderPage (Some raw)

fun main () =
  renderPage None
