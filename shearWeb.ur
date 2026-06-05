fun main () =
  return <xml>
    <head>
      <title>Ur/Web Shear Web</title>
      <link rel="stylesheet" type="text/css" href="http://svelte.flaretiming.com/_app/assets/pages/__layout.svelte-a0a62b13.css" />
      (*
      TODO: Find out why I can't use meta tags with a charset attribute:
        Error in final record unification
        Can't unify record constructors
        Have:  [Nam = meta, Content = string, Id = id]
        Need:  <UNIF:U167::{Type}> ++ [Charset = string]
        Stuck unifying these records after canceling matching pieces:
        Have:  [Nam = meta, Content = string, Id = id]
        Need:  ([Charset = string]) ++ <UNIF:U167::{Type}>
      <meta charset="utf-8" />
      SEE: Manual "There is limited support for the HTML <meta> tag"
      *)
      <meta name="viewport" content="width=device-width, initial-scale=1" />
    </head>
    <body>
        <div>
            (*
            WARNING: Can't declare a main tag using val em : bodyTag boxAttrs,
            if I do, I get an error: "syntax error: inserting EQ".
            *)
            <div>
                Hello
            </div>
        </div>
    </body>
  </xml>
