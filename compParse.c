#include <stdlib.h>
#include <string.h>

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
  char *giveDistance;
  double giveFraction;
  char *scoreBack;
} uw_CompParse_parsedComp_struct;

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

  JSON_Object *earth = required_object(ctx, obj, "earth");
  JSON_Object *sphere = required_object(ctx, earth, "sphere");
  parsed->earthRadius = copy_required_string(ctx, sphere, "radius");

  JSON_Object *give = required_object(ctx, obj, "give");
  parsed->giveDistance = copy_required_string(ctx, give, "giveDistance");
  parsed->giveFraction = required_number(ctx, give, "giveFraction");

  parsed->scoreBack = copy_required_string(ctx, obj, "scoreBack");

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
  free(parsed->giveDistance);
  free(parsed->scoreBack);
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
uw_Basis_string uw_CompParse_earthRadius(uw_context ctx, uw_CompParse_parsedComp parsed) { return uw_strdup(ctx, parsed->earthRadius); }
uw_Basis_string uw_CompParse_giveDistance(uw_context ctx, uw_CompParse_parsedComp parsed) { return uw_strdup(ctx, parsed->giveDistance); }
uw_Basis_float uw_CompParse_giveFraction(uw_context ctx, uw_CompParse_parsedComp parsed) { (void)ctx; return parsed->giveFraction; }
uw_Basis_string uw_CompParse_scoreBack(uw_context ctx, uw_CompParse_parsedComp parsed) { return uw_strdup(ctx, parsed->scoreBack); }
