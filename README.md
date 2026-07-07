# Shear-Web

> In hang gliding, a shear web connects the upper and lower sail skins
> preventing unwanted billow and shear.

Shear-Web is a multiple page application that needs to be run with:

```pre
$ make run
...
urweb shearWeb -protocol http
./shearWeb.exe
...
Listening on port 8080....
```

The other NoseCone applications and the full Flare Timing application are static
sites.

On the server, using Ur/Web's C FFI, `JSON` files are fetched with
[libcurl][curl] and parsed with [kgabis/parson][parson].

> [!NOTE]
> Another approach would be to use a database with the data imported into the
> database ahead of time.

For the 2012 Hang Gliding Pre-Words Championships held in Forbes, NSW,
Australia, we get what we need from these files:

- [comps.json](http://2012-forbes.flaretiming.com/json/comp-input/comps.json)
- [nominals.json](http://2012-forbes.flaretiming.com/json/comp-input/nominals.json)
- [tasks.json](http://2012-forbes.flaretiming.com/json/comp-input/tasks.json)
- [pilot-status.json](http://2012-forbes.flaretiming.com/json/gap-point/pilots-status.json)
- [task-lengths.json](http://2012-forbes.flaretiming.com/json/task-length/task-lengths.json)

[curl]:https://curl.se/libcurl
[parson]: https://github.com/kgabis/parson
