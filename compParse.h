#include <urweb.h>

typedef struct uw_CompParse_parsedComp_struct *uw_CompParse_parsedComp;

uw_CompParse_parsedComp uw_CompParse_parse(uw_context ctx, uw_Basis_string json);
uw_Basis_unit uw_CompParse_free(uw_context ctx, uw_CompParse_parsedComp parsed);

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
