style quote

fun compWidget () : transaction xbody =
    output <- source <xml><p>Not fetched yet.</p></xml>;

    return <xml>
      <button value="Fetch comps JSON"
              onclick={fn _ =>
                          set output <xml><p>Fetching and parsing...</p></xml>;
                          result <- rpc (Fetch.fetchAndParseCompInput "2020-meduno");
                          set output (case result of
                                        CompJson.ParseError err =>
                                          <xml><h3>Parse failed</h3><p>{[err]}</p></xml>
                                      | CompJson.ParseOk comp =>
                                          <xml><h3>Parsed compInput</h3><pre>{[CompView.renderComp comp]}</pre></xml>)}/>

      <dyn signal={signal output}/>
    </xml>

fun main () =
  c <- compWidget ();
  return <xml>
    <head>
      <link rel="stylesheet" type="text/css" href="http://adam.chlipala.net/style.css"/>
    </head>
    <body>{c}</body>
  </xml>
