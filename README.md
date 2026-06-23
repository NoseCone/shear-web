# shear-web

## Running

Run with:

```pre
$ make run
...
./shearWeb.exe
Database connection initialized.
Starting the Ur/Web native HTTP server, which is intended for use
ONLY DURING DEVELOPMENT.  You probably want to use one of the other backends,
behind a production-quality HTTP server, for a real deployment.

Listening on port 8080....
```

## Testing

For adhoc JSON parsing testing, try editing the `*.json` example files and
hard-coding the URL to that file, hosted locally with:

```pre
$ python3 -m http.server
```
