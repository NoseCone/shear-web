#include <urweb.h>

typedef struct uw_CompParse_parsedComp_struct *uw_CompParse_parsedComp;
typedef struct uw_CompParse_parsedNominal_struct *uw_CompParse_parsedNominal;
typedef struct uw_CompParse_parsedTasks_struct *uw_CompParse_parsedTasks;
typedef struct uw_CompParse_parsedTaskLengths_struct *uw_CompParse_parsedTaskLengths;

uw_CompParse_parsedComp uw_CompParse_parse(uw_context ctx, uw_Basis_string json);
uw_Basis_unit uw_CompParse_free(uw_context ctx, uw_CompParse_parsedComp parsed);

uw_CompParse_parsedNominal uw_CompParse_parseNominal(uw_context ctx, uw_Basis_string json);
uw_Basis_unit uw_CompParse_freeNominal(uw_context ctx, uw_CompParse_parsedNominal parsed);

uw_CompParse_parsedTasks uw_CompParse_parseTasks(uw_context ctx, uw_Basis_string json);
uw_Basis_unit uw_CompParse_freeTasks(uw_context ctx, uw_CompParse_parsedTasks parsed);
uw_Basis_int uw_CompParse_tasksCount(uw_context ctx, uw_CompParse_parsedTasks parsed);
uw_Basis_string uw_CompParse_taskName(uw_context ctx, uw_CompParse_parsedTasks parsed, uw_Basis_int taskIndex);
uw_Basis_int uw_CompParse_taskZoneCount(uw_context ctx, uw_CompParse_parsedTasks parsed, uw_Basis_int taskIndex);
uw_Basis_string uw_CompParse_taskZoneName(uw_context ctx, uw_CompParse_parsedTasks parsed, uw_Basis_int taskIndex, uw_Basis_int zoneIndex);
uw_Basis_string uw_CompParse_taskStoppedAnnounced(uw_context ctx, uw_CompParse_parsedTasks parsed, uw_Basis_int taskIndex);
uw_Basis_string uw_CompParse_taskStoppedRetroactive(uw_context ctx, uw_CompParse_parsedTasks parsed, uw_Basis_int taskIndex);
uw_Basis_int uw_CompParse_taskCancelledPresent(uw_context ctx, uw_CompParse_parsedTasks parsed, uw_Basis_int taskIndex);
uw_Basis_bool uw_CompParse_taskCancelledValue(uw_context ctx, uw_CompParse_parsedTasks parsed, uw_Basis_int taskIndex);

uw_CompParse_parsedTaskLengths uw_CompParse_parseTaskLengths(uw_context ctx, uw_Basis_string json);
uw_Basis_unit uw_CompParse_freeTaskLengths(uw_context ctx, uw_CompParse_parsedTaskLengths parsed);
uw_Basis_int uw_CompParse_taskLengthsCount(uw_context ctx, uw_CompParse_parsedTaskLengths parsed);
uw_Basis_float uw_CompParse_taskLength(uw_context ctx, uw_CompParse_parsedTaskLengths parsed, uw_Basis_int taskIndex);

uw_Basis_string uw_CompParse_civilId(uw_context ctx, uw_CompParse_parsedComp parsed);
uw_Basis_string uw_CompParse_earthMath(uw_context ctx, uw_CompParse_parsedComp parsed);
uw_Basis_string uw_CompParse_discipline(uw_context ctx, uw_CompParse_parsedComp parsed);
uw_Basis_string uw_CompParse_location(uw_context ctx, uw_CompParse_parsedComp parsed);
uw_Basis_string uw_CompParse_fromDate(uw_context ctx, uw_CompParse_parsedComp parsed);
uw_Basis_string uw_CompParse_toDate(uw_context ctx, uw_CompParse_parsedComp parsed);
uw_Basis_string uw_CompParse_compName(uw_context ctx, uw_CompParse_parsedComp parsed);
uw_Basis_int uw_CompParse_utcOffsetMinutes(uw_context ctx, uw_CompParse_parsedComp parsed);
uw_Basis_string uw_CompParse_earthRadius(uw_context ctx, uw_CompParse_parsedComp parsed);
uw_Basis_string uw_CompParse_earthEquatorialR(uw_context ctx, uw_CompParse_parsedComp parsed);
uw_Basis_string uw_CompParse_earthRecipF(uw_context ctx, uw_CompParse_parsedComp parsed);
uw_Basis_string uw_CompParse_giveDistance(uw_context ctx, uw_CompParse_parsedComp parsed);
uw_Basis_float uw_CompParse_giveFraction(uw_context ctx, uw_CompParse_parsedComp parsed);
uw_Basis_string uw_CompParse_scoreBack(uw_context ctx, uw_CompParse_parsedComp parsed);

uw_Basis_string uw_CompParse_nominalDistance(uw_context ctx, uw_CompParse_parsedNominal parsed);
uw_Basis_string uw_CompParse_nominalFree(uw_context ctx, uw_CompParse_parsedNominal parsed);
uw_Basis_string uw_CompParse_nominalTime(uw_context ctx, uw_CompParse_parsedNominal parsed);
uw_Basis_float uw_CompParse_nominalGoal(uw_context ctx, uw_CompParse_parsedNominal parsed);
uw_Basis_float uw_CompParse_nominalLaunch(uw_context ctx, uw_CompParse_parsedNominal parsed);
