#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include <urweb.h>
#include "parson.h"
#include "compParse.h"

typedef struct uw_CompParse_parsedComp_struct {
  char *civilId;
  char *earthMath;
  char *discipline;
  char *location;
  char *fromDate;
  char *toDate;
  char *compName;
  int utcOffsetMinutes;
  char *earthRadius;
  char *earthEquatorialR;
  char *earthRecipF;
  char *giveDistance;
  double giveFraction;
  char *scoreBack;
} uw_CompParse_parsedComp_struct;

typedef struct uw_CompParse_parsedNominal_struct {
  char *distance;
  char *freeDist;
  char *time;
  double goal;
  double launch;
} uw_CompParse_parsedNominal_struct;

typedef struct uw_CompParse_parsedTasks_struct {
  int count;
  char **taskName;
  int *zoneCounts;
  char ***zoneNames;
  char **stoppedAnnounced;
  char **stoppedRetroactive;
  int *cancelledPresent;
  int *cancelledValue;
} uw_CompParse_parsedTasks_struct;

typedef struct uw_CompParse_parsedTaskLengths_struct {
  int count;
  double *lengths;
} uw_CompParse_parsedTaskLengths_struct;

static char *copy_required_string(uw_context ctx, JSON_Object *obj, const char *field) {
  const char *s = json_object_get_string(obj, field);
  if (!s) {
    uw_error(ctx, FATAL, "CompParse: missing or non-string field '%s'", field);
  }

  char *out = strdup(s);
  if (!out) {
    uw_error(ctx, FATAL, "CompParse: out of memory while copying '%s'", field);
  }

  return out;
}

static char *copy_optional_string(uw_context ctx, JSON_Object *obj, const char *field) {
  if (!json_object_has_value(obj, field) || json_object_has_value_of_type(obj, field, JSONNull)) {
    return NULL;
  }

  const char *s = json_object_get_string(obj, field);
  if (!s) {
    uw_error(ctx, FATAL, "CompParse: expected optional string field '%s' to be string or null", field);
  }

  char *out = strdup(s);
  if (!out) {
    uw_error(ctx, FATAL, "CompParse: out of memory while copying '%s'", field);
  }

  return out;
}

static char *copy_required_string_or_number(uw_context ctx, JSON_Object *obj, const char *field) {
  const char *s = json_object_get_string(obj, field);
  if (s) {
    char *out = strdup(s);
    if (!out) {
      uw_error(ctx, FATAL, "CompParse: out of memory while copying '%s'", field);
    }
    return out;
  }

  if (json_object_has_value_of_type(obj, field, JSONNumber)) {
    double n = json_object_get_number(obj, field);
    char buf[64];
    snprintf(buf, sizeof(buf), "%.15g", n);

    char *out = strdup(buf);
    if (!out) {
      uw_error(ctx, FATAL, "CompParse: out of memory while copying '%s'", field);
    }
    return out;
  }

  uw_error(ctx, FATAL, "CompParse: missing or invalid field '%s' (expected string or number)", field);
  return NULL;
}

static JSON_Object *required_object(uw_context ctx, JSON_Object *obj, const char *field) {
  JSON_Object *child = json_object_get_object(obj, field);
  if (!child) {
    uw_error(ctx, FATAL, "CompParse: missing or non-object field '%s'", field);
  }
  return child;
}

static double required_number(uw_context ctx, JSON_Object *obj, const char *field) {
  if (!json_object_has_value_of_type(obj, field, JSONNumber)) {
    uw_error(ctx, FATAL, "CompParse: missing or non-number field '%s'", field);
  }
  return json_object_get_number(obj, field);
}

static double parse_required_km(uw_context ctx, JSON_Value *v, const char *field) {
  if (json_value_get_type(v) == JSONNumber) {
    return json_value_get_number(v);
  }

  if (json_value_get_type(v) == JSONString) {
    const char *s = json_value_get_string(v);
    if (!s) uw_error(ctx, FATAL, "CompParse: invalid string in '%s'", field);

    char *end = NULL;
    double n = strtod(s, &end);
    if (end == s) {
      uw_error(ctx, FATAL, "CompParse: invalid numeric string in '%s': %s", field, s);
    }
    return n;
  }

  uw_error(ctx, FATAL, "CompParse: expected number or string in '%s'", field);
  return 0;
}


uw_CompParse_parsedComp uw_CompParse_parse(uw_context ctx, uw_Basis_string json) {
  JSON_Value *root = json_parse_string(json);
  if (!root) {
    uw_error(ctx, FATAL, "CompParse: invalid JSON");
  }

  JSON_Object *obj = json_value_get_object(root);
  if (!obj) {
    json_value_free(root);
    uw_error(ctx, FATAL, "CompParse: expected top-level object");
  }

  uw_CompParse_parsedComp parsed = malloc(sizeof(uw_CompParse_parsedComp_struct));
  if (!parsed) {
    json_value_free(root);
    uw_error(ctx, FATAL, "CompParse: out of memory");
  }

  parsed->civilId = copy_required_string(ctx, obj, "civilId");
  parsed->earthMath = copy_required_string(ctx, obj, "earthMath");
  parsed->discipline = copy_required_string(ctx, obj, "discipline");
  parsed->location = copy_required_string(ctx, obj, "location");
  parsed->fromDate = copy_required_string(ctx, obj, "from");
  parsed->toDate = copy_required_string(ctx, obj, "to");
  parsed->compName = copy_required_string(ctx, obj, "compName");

  JSON_Object *utcOffset = required_object(ctx, obj, "utcOffset");
  parsed->utcOffsetMinutes = (int)required_number(ctx, utcOffset, "timeZoneMinutes");

  parsed->earthRadius = NULL;
  parsed->earthEquatorialR = NULL;
  parsed->earthRecipF = NULL;

  JSON_Object *earth = required_object(ctx, obj, "earth");
  JSON_Object *sphere = json_object_get_object(earth, "sphere");
  JSON_Object *ellipsoid = json_object_get_object(earth, "ellipsoid");

  if (sphere && ellipsoid) {
    uw_error(ctx, FATAL, "CompParse: earth cannot contain both 'sphere' and 'ellipsoid'");
  } else if (sphere) {
    parsed->earthRadius = copy_required_string(ctx, sphere, "radius");
  } else if (ellipsoid) {
    parsed->earthEquatorialR = copy_required_string(ctx, ellipsoid, "equatorialR");
    parsed->earthRecipF = copy_required_string_or_number(ctx, ellipsoid, "recipF");
  } else {
    uw_error(ctx, FATAL, "CompParse: earth must contain either 'sphere' or 'ellipsoid'");
  }

  JSON_Object *give = required_object(ctx, obj, "give");
  parsed->giveDistance = copy_optional_string(ctx, give, "giveDistance");
  parsed->giveFraction = required_number(ctx, give, "giveFraction");

  parsed->scoreBack = copy_optional_string(ctx, obj, "scoreBack");

  json_value_free(root);
  return parsed;
}

uw_Basis_unit uw_CompParse_free(uw_context ctx, uw_CompParse_parsedComp parsed) {
  (void)ctx;
  if (!parsed) return 0;

  free(parsed->civilId);
  free(parsed->earthMath);
  free(parsed->discipline);
  free(parsed->location);
  free(parsed->fromDate);
  free(parsed->toDate);
  free(parsed->compName);
  free(parsed->earthRadius);
  free(parsed->earthEquatorialR);
  free(parsed->earthRecipF);
  free(parsed->giveDistance);
  free(parsed->scoreBack);

  free(parsed);
  return 0;
}

uw_CompParse_parsedNominal uw_CompParse_parseNominal(uw_context ctx, uw_Basis_string json) {
  JSON_Value *root = json_parse_string(json);
  if (!root) {
    uw_error(ctx, FATAL, "CompParse: invalid nominal JSON");
  }

  JSON_Object *obj = json_value_get_object(root);
  if (!obj) {
    json_value_free(root);
    uw_error(ctx, FATAL, "CompParse: expected nominal top-level object");
  }

  uw_CompParse_parsedNominal parsed = malloc(sizeof(uw_CompParse_parsedNominal_struct));
  if (!parsed) {
    json_value_free(root);
    uw_error(ctx, FATAL, "CompParse: out of memory");
  }

  parsed->distance = copy_required_string(ctx, obj, "distance");
  parsed->freeDist = copy_required_string(ctx, obj, "free");
  parsed->time = copy_required_string(ctx, obj, "time");
  parsed->goal = required_number(ctx, obj, "goal");
  parsed->launch = required_number(ctx, obj, "launch");

  json_value_free(root);
  return parsed;
}

uw_Basis_unit uw_CompParse_freeNominal(uw_context ctx, uw_CompParse_parsedNominal parsed) {
  (void)ctx;
  if (!parsed) return 0;

  free(parsed->distance);
  free(parsed->freeDist);
  free(parsed->time);
  free(parsed);
  return 0;
}

uw_CompParse_parsedTasks uw_CompParse_parseTasks(uw_context ctx, uw_Basis_string json) {
  JSON_Value *root = json_parse_string(json);
  if (!root) {
    uw_error(ctx, FATAL, "CompParse: invalid tasks JSON");
  }

  JSON_Array *arr = json_value_get_array(root);
  if (!arr) {
    json_value_free(root);
    uw_error(ctx, FATAL, "CompParse: expected tasks top-level array");
  }

  size_t count = json_array_get_count(arr);
  uw_CompParse_parsedTasks parsed = malloc(sizeof(uw_CompParse_parsedTasks_struct));
  if (!parsed) {
    json_value_free(root);
    uw_error(ctx, FATAL, "CompParse: out of memory");
  }

  parsed->count = (int)count;
  parsed->taskName = calloc(count, sizeof(char*));
  parsed->zoneCounts = calloc(count, sizeof(int));
  parsed->zoneNames = calloc(count, sizeof(char**));
  parsed->stoppedAnnounced = calloc(count, sizeof(char*));
  parsed->stoppedRetroactive = calloc(count, sizeof(char*));
  parsed->cancelledPresent = calloc(count, sizeof(int));
  parsed->cancelledValue = calloc(count, sizeof(int));

  if ((count > 0) &&
      (!parsed->taskName || !parsed->zoneCounts || !parsed->zoneNames || !parsed->stoppedAnnounced
       || !parsed->stoppedRetroactive || !parsed->cancelledPresent || !parsed->cancelledValue)) {
    json_value_free(root);
    uw_error(ctx, FATAL, "CompParse: out of memory");
  }

  for (size_t i = 0; i < count; i++) {
    JSON_Object *task = json_array_get_object(arr, i);
    if (!task) {
      json_value_free(root);
      uw_error(ctx, FATAL, "CompParse: task[%zu] not an object", i);
    }

    parsed->taskName[i] = copy_required_string(ctx, task, "taskName");

    JSON_Object *zones = required_object(ctx, task, "zones");
    JSON_Array *raw = json_object_get_array(zones, "raw");
    if (!raw) {
      json_value_free(root);
      uw_error(ctx, FATAL, "CompParse: task[%zu].zones.raw missing or not array", i);
    }

    size_t zc = json_array_get_count(raw);
    parsed->zoneCounts[i] = (int)zc;
    parsed->zoneNames[i] = calloc(zc, sizeof(char*));
    if (zc > 0 && !parsed->zoneNames[i]) {
      json_value_free(root);
      uw_error(ctx, FATAL, "CompParse: out of memory");
    }

    for (size_t z = 0; z < zc; z++) {
      JSON_Object *zone = json_array_get_object(raw, z);
      if (!zone) {
        json_value_free(root);
        uw_error(ctx, FATAL, "CompParse: task[%zu].zones.raw[%zu] not object", i, z);
      }
      parsed->zoneNames[i][z] = copy_required_string(ctx, zone, "zoneName");
    }

    if (json_object_has_value(task, "stopped") && !json_object_has_value_of_type(task, "stopped", JSONNull)) {
      JSON_Object *stopped = json_object_get_object(task, "stopped");
      if (!stopped) {
        json_value_free(root);
        uw_error(ctx, FATAL, "CompParse: task[%zu].stopped must be object or null", i);
      }
      parsed->stoppedAnnounced[i] = copy_required_string(ctx, stopped, "announced");
      parsed->stoppedRetroactive[i] = copy_required_string(ctx, stopped, "retroactive");
    }

    if (json_object_has_value(task, "cancelled") && !json_object_has_value_of_type(task, "cancelled", JSONNull)) {
      if (!json_object_has_value_of_type(task, "cancelled", JSONBoolean)) {
        json_value_free(root);
        uw_error(ctx, FATAL, "CompParse: task[%zu].cancelled must be boolean or null", i);
      }
      parsed->cancelledPresent[i] = 1;
      parsed->cancelledValue[i] = json_object_get_boolean(task, "cancelled") ? 1 : 0;
    }
  }

  json_value_free(root);
  return parsed;
}

uw_Basis_unit uw_CompParse_freeTasks(uw_context ctx, uw_CompParse_parsedTasks parsed) {
  (void)ctx;
  if (!parsed) return 0;

  for (int i = 0; i < parsed->count; i++) {
    free(parsed->taskName[i]);
    free(parsed->stoppedAnnounced[i]);
    free(parsed->stoppedRetroactive[i]);
    if (parsed->zoneNames[i]) {
      for (int z = 0; z < parsed->zoneCounts[i]; z++) {
        free(parsed->zoneNames[i][z]);
      }
      free(parsed->zoneNames[i]);
    }
  }

  free(parsed->taskName);
  free(parsed->zoneCounts);
  free(parsed->zoneNames);
  free(parsed->stoppedAnnounced);
  free(parsed->stoppedRetroactive);
  free(parsed->cancelledPresent);
  free(parsed->cancelledValue);
  free(parsed);
  return 0;
}

uw_CompParse_parsedTaskLengths uw_CompParse_parseTaskLengths(uw_context ctx, uw_Basis_string json) {
  JSON_Value *root = json_parse_string(json);
  if (!root) {
    uw_error(ctx, FATAL, "CompParse: invalid task lengths JSON");
  }

  JSON_Array *arr = json_value_get_array(root);
  if (!arr) {
    json_value_free(root);
    uw_error(ctx, FATAL, "CompParse: expected task lengths top-level array");
  }

  size_t count = json_array_get_count(arr);
  uw_CompParse_parsedTaskLengths parsed = malloc(sizeof(uw_CompParse_parsedTaskLengths_struct));
  if (!parsed) {
    json_value_free(root);
    uw_error(ctx, FATAL, "CompParse: out of memory");
  }

  parsed->count = (int)count;
  parsed->lengths = calloc(count, sizeof(double));
  if (count > 0 && !parsed->lengths) {
    json_value_free(root);
    uw_error(ctx, FATAL, "CompParse: out of memory");
  }

  for (size_t i = 0; i < count; i++) {
    JSON_Value *v = json_array_get_value(arr, i);
    parsed->lengths[i] = parse_required_km(ctx, v, "task-length");
  }

  json_value_free(root);
  return parsed;
}

uw_Basis_unit uw_CompParse_freeTaskLengths(uw_context ctx, uw_CompParse_parsedTaskLengths parsed) {
  (void)ctx;
  if (!parsed) return 0;
  free(parsed->lengths);
  free(parsed);
  return 0;
}

uw_Basis_string uw_CompParse_civilId(uw_context ctx, uw_CompParse_parsedComp parsed) { return uw_strdup(ctx, parsed->civilId); }
uw_Basis_string uw_CompParse_earthMath(uw_context ctx, uw_CompParse_parsedComp parsed) { return uw_strdup(ctx, parsed->earthMath); }
uw_Basis_string uw_CompParse_discipline(uw_context ctx, uw_CompParse_parsedComp parsed) { return uw_strdup(ctx, parsed->discipline); }
uw_Basis_string uw_CompParse_location(uw_context ctx, uw_CompParse_parsedComp parsed) { return uw_strdup(ctx, parsed->location); }
uw_Basis_string uw_CompParse_fromDate(uw_context ctx, uw_CompParse_parsedComp parsed) { return uw_strdup(ctx, parsed->fromDate); }
uw_Basis_string uw_CompParse_toDate(uw_context ctx, uw_CompParse_parsedComp parsed) { return uw_strdup(ctx, parsed->toDate); }
uw_Basis_string uw_CompParse_compName(uw_context ctx, uw_CompParse_parsedComp parsed) { return uw_strdup(ctx, parsed->compName); }
uw_Basis_int uw_CompParse_utcOffsetMinutes(uw_context ctx, uw_CompParse_parsedComp parsed) { (void)ctx; return parsed->utcOffsetMinutes; }
uw_Basis_string uw_CompParse_earthRadius(uw_context ctx, uw_CompParse_parsedComp parsed) {
  if (!parsed->earthRadius) return NULL;
  return uw_strdup(ctx, parsed->earthRadius);
}
uw_Basis_string uw_CompParse_earthEquatorialR(uw_context ctx, uw_CompParse_parsedComp parsed) {
  if (!parsed->earthEquatorialR) return NULL;
  return uw_strdup(ctx, parsed->earthEquatorialR);
}
uw_Basis_string uw_CompParse_earthRecipF(uw_context ctx, uw_CompParse_parsedComp parsed) {
  if (!parsed->earthRecipF) return NULL;
  return uw_strdup(ctx, parsed->earthRecipF);
}
uw_Basis_string uw_CompParse_giveDistance(uw_context ctx, uw_CompParse_parsedComp parsed) {
  if (!parsed->giveDistance) return NULL;
  return uw_strdup(ctx, parsed->giveDistance);
}
uw_Basis_float uw_CompParse_giveFraction(uw_context ctx, uw_CompParse_parsedComp parsed) { (void)ctx; return parsed->giveFraction; }
uw_Basis_string uw_CompParse_scoreBack(uw_context ctx, uw_CompParse_parsedComp parsed) {
  if (!parsed->scoreBack) return NULL;
  return uw_strdup(ctx, parsed->scoreBack);
}

uw_Basis_string uw_CompParse_nominalDistance(uw_context ctx, uw_CompParse_parsedNominal parsed) { return uw_strdup(ctx, parsed->distance); }
uw_Basis_string uw_CompParse_nominalFree(uw_context ctx, uw_CompParse_parsedNominal parsed) { return uw_strdup(ctx, parsed->freeDist); }
uw_Basis_string uw_CompParse_nominalTime(uw_context ctx, uw_CompParse_parsedNominal parsed) { return uw_strdup(ctx, parsed->time); }
uw_Basis_float uw_CompParse_nominalGoal(uw_context ctx, uw_CompParse_parsedNominal parsed) { (void)ctx; return parsed->goal; }
uw_Basis_float uw_CompParse_nominalLaunch(uw_context ctx, uw_CompParse_parsedNominal parsed) { (void)ctx; return parsed->launch; }

uw_Basis_int uw_CompParse_tasksCount(uw_context ctx, uw_CompParse_parsedTasks parsed) { (void)ctx; return parsed->count; }
uw_Basis_string uw_CompParse_taskName(uw_context ctx, uw_CompParse_parsedTasks parsed, uw_Basis_int taskIndex) {
  if (taskIndex < 0 || taskIndex >= parsed->count) uw_error(ctx, FATAL, "CompParse: task index out of bounds");
  return uw_strdup(ctx, parsed->taskName[taskIndex]);
}
uw_Basis_int uw_CompParse_taskZoneCount(uw_context ctx, uw_CompParse_parsedTasks parsed, uw_Basis_int taskIndex) {
  if (taskIndex < 0 || taskIndex >= parsed->count) uw_error(ctx, FATAL, "CompParse: task index out of bounds");
  return parsed->zoneCounts[taskIndex];
}
uw_Basis_string uw_CompParse_taskZoneName(uw_context ctx, uw_CompParse_parsedTasks parsed, uw_Basis_int taskIndex, uw_Basis_int zoneIndex) {
  if (taskIndex < 0 || taskIndex >= parsed->count) uw_error(ctx, FATAL, "CompParse: task index out of bounds");
  if (zoneIndex < 0 || zoneIndex >= parsed->zoneCounts[taskIndex]) uw_error(ctx, FATAL, "CompParse: zone index out of bounds");
  return uw_strdup(ctx, parsed->zoneNames[taskIndex][zoneIndex]);
}
uw_Basis_string uw_CompParse_taskStoppedAnnounced(uw_context ctx, uw_CompParse_parsedTasks parsed, uw_Basis_int taskIndex) {
  if (taskIndex < 0 || taskIndex >= parsed->count) uw_error(ctx, FATAL, "CompParse: task index out of bounds");
  if (!parsed->stoppedAnnounced[taskIndex]) return NULL;
  return uw_strdup(ctx, parsed->stoppedAnnounced[taskIndex]);
}
uw_Basis_string uw_CompParse_taskStoppedRetroactive(uw_context ctx, uw_CompParse_parsedTasks parsed, uw_Basis_int taskIndex) {
  if (taskIndex < 0 || taskIndex >= parsed->count) uw_error(ctx, FATAL, "CompParse: task index out of bounds");
  if (!parsed->stoppedRetroactive[taskIndex]) return NULL;
  return uw_strdup(ctx, parsed->stoppedRetroactive[taskIndex]);
}
uw_Basis_int uw_CompParse_taskCancelledPresent(uw_context ctx, uw_CompParse_parsedTasks parsed, uw_Basis_int taskIndex) {
  if (taskIndex < 0 || taskIndex >= parsed->count) uw_error(ctx, FATAL, "CompParse: task index out of bounds");
  return parsed->cancelledPresent[taskIndex];
}
uw_Basis_bool uw_CompParse_taskCancelledValue(uw_context ctx, uw_CompParse_parsedTasks parsed, uw_Basis_int taskIndex) {
  if (taskIndex < 0 || taskIndex >= parsed->count) uw_error(ctx, FATAL, "CompParse: task index out of bounds");
  return parsed->cancelledValue[taskIndex] ? 1 : 0;
}

uw_Basis_int uw_CompParse_taskLengthsCount(uw_context ctx, uw_CompParse_parsedTaskLengths parsed) { (void)ctx; return parsed->count; }
uw_Basis_float uw_CompParse_taskLength(uw_context ctx, uw_CompParse_parsedTaskLengths parsed, uw_Basis_int taskIndex) {
  if (taskIndex < 0 || taskIndex >= parsed->count) uw_error(ctx, FATAL, "CompParse: task length index out of bounds");
  return parsed->lengths[taskIndex];
}
