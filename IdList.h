#include <iostream>
#include <vector>
#include <string>

using namespace std;

struct exp {
     string type;
     int intval;
     float floatval;
     bool boolval;
};

struct IdInfo {
    string type;
    string name;
    int constant; 
    int publ;
    int pvt;
    int protect;

    bool isparam;

    int intval;
    float floatval;
    char charval;
    string stringval;
    bool boolval;

    string functionName;
    string className;
    string global;
};

struct params {
    string name;
    string type;

    int intval;
    float floatval;
    char charval;
    string stringval;
    bool boolval;
};

struct IdInfoFunc{
    string name;
    string type;
    int paramNumber;
    string className;
    bool hasParams;

    int int_value;
    float float_value;
    bool bool_value;
    char char_value;
    string string_value;

    vector<params> parameters;
};

struct funvect{
    string name;
};

struct classes {
    string className;
};

struct parametri {
    string type;
};

class call_list_prm {
    public: 
    vector<parametri> call_params;

    // public: 

    call_list_prm(string type);
    void setParamType(string type);
    string getParamType();
    void printParams();
};

class exps {
    vector<exp> express;

    public:

    exps(string type);
    void addExpType(string type);
    string getExpType();
    void setExpIntValue(int value);
    void setExpFloatValue(float value);
    void setExpBoolValue(bool value);
    int getExpIntValue();
    float getExpFloatValue();
    bool getExpBoolValue();
};

class IdList {
    public:
    vector<IdInfo> vars;
    vector<IdInfoFunc> functions; 
    vector<funvect> funvector;
    vector<classes> cls;

    //push.back(funvector);
    //pop(funvector); 
   
    // public:
    void setfunvector(const char* s);

    bool existsVar(const char* s);
    bool isConst(const char* s);
    void addVar(const char* type, const char* name );
    void addVarIntValue(const char* var, int value);
    void addVarFloatValue(const char* var, float value);
    void addVarBoolValue(const char* var, bool value);
    void addVarCharValue(const char* var, char value);
    void addVarStringValue(const char* var, const char* value);
    void setVarVisibility(const char* var, const char* where);
    string getVarTypeForParams(const char* funcName);

    string getVarStringSValue(const char* var);

    void nowIsConst(const char* s);
    void isNotConst(const char* s);
    bool sameType(const char* var1, const char* var2);
    void getValueFromVar(const char* var1, const char* var2);
    string getType(const char* var);
    void setGlobal(const char* var);
    void setClassName(const char* var, const char* className);
    void setFuncName(const char* var, const char* funcName);

    int getVarIntValue(const char* s);
    float getVarFloatValue(const char* s);
    bool getVarBoolValue(const char* s);
    char getVarCharValue(const char* s);
    string  getVarStringValue(const char* s);


    //functii
    bool existsFunc(const char* s);
    void addVarFunc(const char* type, const char* name);
    void addVarIntValueFunc(const char* var,int value);

    // void addFuncIntValue(const char* funct, int value);
    // void addFuncFltValue(const char* funct, float value);
    // void addFuncBoolValue(const char* funct, bool value);
    // void addFuncCharValue(const char* funct, char value);
    // void addFuncStringValue(const char* funct, const char* value);

    bool sameTypeFuncVar(const char* FuncName, const char* VarName);
    void setFuncType(const char* FuncName, const char* type);

    void addFuncIntValue(const char* var, int value);
    void addFuncFloatValue(const char* var, float value);
    void addFuncBoolValue(const char* var, bool value);
    void addFuncCharValue(const char* var, char value);
    void addFuncStringValue(const char* var, string value); // id = id
    void addFuncStringValuePlain(const char* var, const char * value); // id = "string"

    // int compute_int_math(int var1, const char* operation, int var2);
    int compute_int_math(int var1, int operation, int var2);

    bool compute_int_cmp(int var1, int operation, int var2);

    float compute_float_math(float var1, int operation, float var2);

    bool compute_float_cmp(float var1, int operation, float var2);

    bool compute_bool_value(bool var1, int operation, bool var2);

    void setVarFuncName(const char* s, string functName);
    void setVarClassName(const char* s, string className);
    string getFuncName();
    string getFuncType(const char* s);

    int getFuncNameVar(const char* s);

    bool existsclsVar(const char* s);
    void addclsVar(const char* s);
    void addVarClassName(const char* s, const char* classname);
    void setPrivacy(const char* s, const char* prv);
    void setFuncClassName(const char* s, const char* className);
    string getPrivacy(const char* s);
    string getVarClassName(const char* s);
    void addVarTypeParam(const char* var, const char* type);
    void setFuncHasParams(const char* var, bool value);
    bool funcHasParams(const char* s);
    void pushParam(const char* s, const char* type, const char* id);
    void isParam(const char* s);
    string getClassName(const char* s);

    void printfuncNames();
    void printFunctions();
    void printVars();
    ~IdList();
};

// bool sameParams(const char* s, call_list_prm parametr);






