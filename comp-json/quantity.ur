datatype metres = Metres of float
datatype kilometres = Kilometres of float
datatype hours = Hours of float
datatype seconds = Seconds of float

val show_metres : show metres =
    mkShow (fn (Metres x) => show x ^ " m")

val show_kilometres : show kilometres =
    mkShow (fn (Kilometres x) => show x ^ " km")

val show_hours : show hours =
    mkShow (fn (Hours x) => show x ^ " h")

val show_seconds : show seconds =
    mkShow (fn (Seconds x) => show x ^ " s")
