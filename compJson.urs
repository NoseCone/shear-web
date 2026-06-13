datatype compInputParseResult = CompInputParseError of string | CompInputParseOk of Comp.compInput
datatype nominalParseResult = NominalParseError of string | NominalParseOk of Comp.nominal
datatype tasksParseResult = TasksParseError of string | TasksParseOk of list Comp.compTask
datatype taskLengthsParseResult = TaskLengthsParseError of string | TaskLengthsParseOk of list Comp.taskLength

val parseNominalJson : string -> transaction nominalParseResult
val parseCompInputJson : string -> transaction compInputParseResult
val parseTasksJson : string -> transaction tasksParseResult
val parseTaskLengthsJson : string -> transaction taskLengthsParseResult
