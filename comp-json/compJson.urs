val json_nominal : Json.json Comp.nominal
val json_rawZone : Json.json Comp.rawZone
val json_stopped : Json.json Comp.stopped
val json_zonesWrapper : Json.json {Raw : list Comp.rawZone}
val json_compTask : Json.json Comp.compTask
val json_utcOffset : Json.json {TimeZoneMinutes : int}
val json_earthSphere : Json.json {Radius : Quantity.metres}
val json_earthEllipsoid : Json.json Comp.ellipsoid
val json_earth : Json.json { Sphere : option {Radius : Quantity.metres}, Ellipsoid : option Comp.ellipsoid }
val json_give : Json.json Comp.gives
val json_taskLength : Json.json Comp.taskLength
val json_pilotStatus : Json.json Comp.pilotStatus
val json_compInput : Json.json Comp.compInput
