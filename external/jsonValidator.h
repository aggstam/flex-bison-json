/* Definition of the supported types. This is an enumerated type.*/
#ifndef __jsonValidatorSymbolTable__
#define __jsonValidatorSymbolTable__
/* Type Definitions (enum)  */
typedef enum {type_error, type_integer, type_real, type_string, type_object, type_array, type_constant} jsonType;

/* Forward Function Declarations  */
void initSymbolTable();
int addvar(char *,jsonType,int);
int lookup(char *);
jsonType lookup_type(char *);
int lookup_length(char  *VariableName);
const char * nameOfType(int typeNumber);


#endif
