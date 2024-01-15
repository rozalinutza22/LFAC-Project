#include <fstream>
#include "IdList.h"
using namespace std;

ofstream fout("symbol_table.txt");

void IdList::addVar(const char* type, const char* name) {
    IdInfo var = {string(type), string(name)};
    vars.push_back(var);
}


bool IdList::existsVar(const char* var) {
    string strvar = string(var);
     for (IdInfo& v : vars) {
        if (strvar == v.name) { 
            return true;
        }
    }
    return false;
}

void IdList::printVars() {
    fout << "Variables: " << endl;
    for (const IdInfo& v : vars) {
        fout << "name: " << v.name << " type:" << v.type;

        if (v.constant == 1) 
            fout << " const";

        fout <<  " value:";

        if (v.type == "int")
            fout << ' ' <<  v.intval;
        else if (v.type == "float") 
            fout << ' ' <<  v.floatval;
        else if (v.type == "bool") 
            fout << ' ' <<  boolalpha << v.boolval;
        else if (v.type == "char") 
            fout << ' ' <<  v.charval;
        else if (v.type == "string") 
            fout << ' ' <<  v.stringval;

        if (!v.className.empty()) {
            fout << ' ' << "class: " << v.className;
        }else if (!v.functionName.empty()) {
            fout << ' ' << "function: " << v.functionName << endl;
        }else if (!v.global.empty()) {
            fout << ' ' << "vizibilitate: globala" << endl;
        }else fout << endl;

        if (v.className.empty() == 0) {
            fout << " privacy: ";

            if (v.protect == 1)
                fout << "protected" << endl;
            else if (v.publ == 1) 
                fout << "public" << endl;
            else if (v.pvt == 1) 
                fout << "private" << endl; 
            else fout << endl;
        }else fout << endl;

        fout << endl;
        
        // if (v.className.empty() != 1 && v.functionName.empty() != 1)
        //     cout << endl;

        // if (v.className.empty() != 0) 
        //     cout << ' ' << "clasa: " << v.className << endl;
        // else if (v.functionName.empty() != 0) 
        //     cout << ' ' << "functia: " << v.functionName << endl;
        // else if (v.global.empty() != 1) cout << ' ' << "vizibilitate: global" << endl;
        // else if (v.global.empty() != 0) cout << ' ' << "vizibilitate: local" << endl;
     }
}

void IdList::setVarVisibility(const char* var, const char* where) {
    string strvar1 = string(var);
    string strvar2 = string(where);

    for (IdInfo& v : vars) {
        if (v.name == strvar1) 
            v.global = strvar2;
    }
}

void IdList::printFunctions() {
    fout << endl;
    fout << "Functions: " << endl;
    for (const IdInfoFunc& v : functions) {
        fout << "name: " << v.name << " type: " << v.type << " value:";

        if (v.type == "int")
            fout << ' ' <<  v.int_value;
        else if (v.type == "float") 
            fout << ' ' <<  v.float_value;
        else if (v.type == "bool") 
            fout << ' ' <<  boolalpha << v.bool_value;
        else if (v.type == "char") 
            fout << ' ' <<  v.char_value;
        else if (v.type == "string") 
            fout << ' ' <<  v.string_value;

        if (v.className.empty() == 0) {
            fout << " className: " << v.className << endl;
        }

        if(v.hasParams == 0) {
            fout << " nr_parametri: " << 0 << endl;
        }else if (v.hasParams == 1){
            fout << " tip_parametri: ";

            for (IdInfo& y : vars) {
                if (y.isparam == true && y.functionName == v.name) {
                    fout << y.type << ' ';
                }
            }

            fout << endl;
        }

        fout << endl;
    }
}

void IdList::isParam(const char* s) {
    string strvar = string(s);

    for (IdInfo& v : vars) {
        if (v.name == strvar) 
            v.isparam = true;
    }
}

string IdList::getVarTypeForParams(const char* funcName) {
    string strvar = string(funcName);
    string res;

    for (IdInfo& v : vars) {
        if (v.functionName == strvar) {
            if (v.isparam == true)
                res = v.type;
        }
    }
    
    return res;
}

bool IdList::funcHasParams(const char* s) {
    bool has;
    string strvar = string(s);

    for (IdInfoFunc& v : functions) {
        if (v.name == strvar) 
            if (v.hasParams == true)
                has = true;
            else has = false;
    }

    return has;
}

void IdList::pushParam(const char* s, const char* type, const char* id) {
    string strvar1 = string(s);

    params var = {string(id), string(type)};

    for (IdInfoFunc& v : functions) {
        if (v.name == strvar1) {
            v.parameters.push_back(var);
        }
    }

}

// void IdList::addVar(const char* type, const char*name) {
//     IdInfo var = {string(type), string(name)};
//     vars.push_back(var);
// }

void IdList::addVarIntValue(const char* var,int value) {
    string strvar = string(var);
     for (IdInfo& v : vars) {
        if (strvar == v.name) { 
            v.intval = value;
        }
    }
}

void IdList::addVarFloatValue(const char* var, float value) {
    string strvar = string(var);
     for (IdInfo& v : vars) {
        if (strvar == v.name) { 
            v.floatval = value;
        }
    }
}

void IdList::addVarBoolValue(const char* var, bool value) {
    string strvar = string(var);
     for (IdInfo& v : vars) {
        if (strvar == v.name) { 
            v.boolval = value;
        }
    }
}

void IdList::addVarCharValue(const char* var, char value) {
    string strvar = string(var);
     for (IdInfo& v : vars) {
        if (strvar == v.name) { 
            v.charval = value;
        }
    }

}

void IdList::addVarStringValue(const char* var, const char* value) {
    string strvar = string(var);
    string strvalue = string(value);
     for (IdInfo& v : vars) {
        if (strvar == v.name) { 
            v.stringval = strvalue;
        }
    }
}

bool IdList::isConst(const char* s) {
    string strvar = string(s);
     for (IdInfo& v : vars) {
        if (strvar == v.name) { 
            if (v.constant == 1)
                return true;
        }
    }

    return false;
}

void IdList::nowIsConst(const char* s) {
    string strvar = string(s);
    for (IdInfo& v : vars) {
        if (strvar == v.name) { 
            v.constant = 1;
        }
    }
}

bool IdList::sameType(const char* var1, const char* var2) {
    string strvar1 = string(var1);
    string strvar2 = string(var2);

    string type1;
    string type2;

    for (IdInfo& v : vars) {
        if (strvar1 == v.name) 
            type1 = v.type;
    }

    for (IdInfo& v : vars) {
        if (strvar2 == v.name) 
            type2 = v.type;
    }

    if (type1 == type2)
        return true;
    else return false;
}

string IdList::getType(const char* var) {
    string strvar = string(var);
    string strtype;

    for (IdInfo& v : vars) {
        if (strvar == v.name) 
            strtype = v.type;
    }

    return strtype;
}

void IdList::getValueFromVar(const char* var1, const char* var2) {
    string strvar1 = string(var1);
    string strvar2 = string(var2);

    string strtype = getType(var1);

    if (strtype == "int") {
        int value;

        for (IdInfo& v : vars) {
            if (strvar2 == v.name) 
                value = v.intval;
        }

        for (IdInfo& v : vars) {
            if (strvar1 == v.name) 
                v.intval = value;
        }
    }else if (strtype == "float") {
            float value;

            for (IdInfo& v : vars) {
                if (strvar2 == v.name) 
                    value = v.floatval;
            }

            for (IdInfo& v : vars) {
                if (strvar1 == v.name) 
                    v.floatval = value;
            }
    }else if (strtype == "bool") {
            bool value;

            for (IdInfo& v : vars) {
                if (strvar2 == v.name) 
                    value = v.boolval;
            }

            for (IdInfo& v : vars) {
                if (strvar1 == v.name) 
                    v.boolval = value;
            }
    }else if (strtype == "char") {
            char value;

            for (IdInfo& v : vars) {
                if (strvar2 == v.name) 
                    value = v.charval;
            }

            for (IdInfo& v : vars) {
                if (strvar1 == v.name) 
                    v.charval = value;
            }
    }else if (strtype == "string") {
            string value;

            for (IdInfo& v : vars) {
                if (strvar2 == v.name) 
                    value = v.stringval;
            }

            for (IdInfo& v : vars) {
                if (strvar1 == v.name) 
                    v.stringval = value;
            }
    }
}

 void IdList::isNotConst(const char* s) {
    string strvar = string(s);

    for (IdInfo& v : vars) {
        if (strvar == v.name) 
            v.constant = 0;
    }
 }

 void IdList::setGlobal(const char* var) {
    string strvar = string(var);

    for (IdInfo& v : vars) {
        if (strvar == v.name) 
            v.global = "global";
    }
 }

void IdList::setClassName(const char* var, const char* className) {
    string strvar = string(var);
    string strname = string(className);

    for (IdInfo& v : vars) {
        if (strvar == v.name) 
            v.className = strname;
    }
}


void IdList::setFuncName(const char* var, const char* funcName) {
    string strvar = string(var);
    string strname = string(funcName);

    for (IdInfoFunc& v : functions) {
        if (strvar == v.name) 
            v.name = strname;
    }
}

bool IdList::existsFunc(const char* s) {
    string strvar = string(s);

    for (IdInfoFunc& v : functions) {
        if (strvar == v.name) { 
            return true;
        }
    }
    return false;
}

void IdList::addVarFunc(const char* type, const char* name) {
    IdInfoFunc var = {string(name), string(type)};
    functions.push_back(var);
}

void IdList::setFuncClassName(const char* s, const char* className) {
    string strvar1 = string(s);
    string strvar2 = string(className);

    for (IdInfoFunc& v : functions) {
        if (strvar1 == v.name) { 
            v.className = strvar2;
        }
    }
}

void IdList::addVarIntValueFunc(const char* var,int value) {
    string strvar = string(var);
     for (IdInfoFunc& v : functions) {
        if (strvar == v.name) { 
            for (params& y : v.parameters)
                y.intval = value;
        }
    }
}

bool IdList::sameTypeFuncVar(const char* FuncName, const char* VarName){
    string Func = string(FuncName);
    string Return = string(VarName);

    string type1;
    string type2;

    for (IdInfoFunc& v : functions) {
        if (Func == v.name) 
            type1 = v.type;
    }

    for (IdInfo& v : vars) {
        if (Return == v.name) 
            type2 = v.type;
    }
    
    if (type1 == type2)
        return true;
    else return false;

}

void IdList::setFuncType(const char* FuncName, const char* type) {
    string strvar1 = string(FuncName);
    string strvar2 = string(type);

    for (IdInfoFunc& v : functions) {
        if (strvar1 == v.name) 
            v.type = strvar2;
    }
}

void IdList::addFuncIntValue(const char* var, int value) {
    string strvar = string(var);

     for (IdInfoFunc& v : functions) {
        if (strvar == v.name) { 
            v.int_value = value;
        }
    }

}

void IdList::addFuncFloatValue(const char* var, float value) {
    string strvar = string(var);

     for (IdInfoFunc& v : functions) {
        if (strvar == v.name) { 
            v.float_value = value;
        }
    }
}

void IdList::addFuncBoolValue(const char* var, bool value) {
    string strvar = string(var);

     for (IdInfoFunc& v : functions) {
        if (strvar == v.name) { 
            v.bool_value = value;
        }
    }
}

void IdList::addFuncCharValue(const char* var, char value) {
    string strvar = string(var);

     for (IdInfoFunc& v : functions) {
        if (strvar == v.name) { 
            v.char_value = value;
        }
    }

}

void IdList::addFuncStringValue(const char* var, string value) {
    string strvar = string(var);

     for (IdInfoFunc& v : functions) {
        if (strvar == v.name) { 
            v.string_value = value;
        }
    }
}


int IdList::getVarIntValue(const char* s) {
    string strvar = string(s);
    int value;

    for (IdInfo& v : vars) {
        if (strvar == v.name) 
            value = v.intval;
    }    

    return value;
}

float IdList::getVarFloatValue(const char* s) {
    string strvar = string(s);
    float value;

    for (IdInfo& v : vars) {
        if (strvar == v.name) 
            value = v.floatval;
    }    

    return value;
}

bool IdList::getVarBoolValue(const char* s) {
    string strvar = string(s);
    bool value;

    for (IdInfo& v : vars) {
        if (strvar == v.name) 
            value = v.boolval;
    }    

    return value;
}

char IdList::getVarCharValue(const char* s) {
    string strvar = string(s);
    char value;

    for (IdInfo& v : vars) {
        if (strvar == v.name) 
            value = v.charval;
    }    

    return value;
}

string IdList::getVarStringValue(const char* s) {
    string strvar = string(s);
    string strtext;

    for (IdInfo& v : vars) {
        if (strvar == v.name) 
            strtext = v.stringval;
    }

    return strtext;
}


string IdList::getVarStringSValue(const char* var) {
    string strvar = string(var);
    string strtext;

    for (IdInfo& v: vars) {
        if (v.name == strvar)
            strtext = v.stringval;
    }

    return strtext;
}

void IdList::addFuncStringValuePlain(const char* var, const char * value) {
    string strvar1 = string(var);
    string strvar2 = string(value);


    for (IdInfoFunc& v : functions) {
        if (v.name == strvar1)
            v.string_value = strvar2;
    }
}

// int IdList::compute_int_math(int var1, const char* operation, int var2) {
//     string operatie = string(operation);

//     if (operatie == "PLUS") {
//         return (var1 + var2);
//     }else if (operatie == "MINUS") {
//         return (var1 - var2);
//     }else if (operatie == "ASTERISK") {
//         return (var1 * var2);
//     }else if (operatie == "DIV") {
//         return (var1 / var2);
//     }else if (operatie == "MOD") {
//         return (var1 % var2);
//     }

//     return 0;
// }

int IdList::compute_int_math(int var1, int operatie, int var2) {
    // string operatie = string(operation);

    if (operatie == 0) {
        return (var1 + var2);
    }else if (operatie == 1) {
        return (var1 - var2);
    }else if (operatie == 2) {
        return (var1 * var2);
    }else if (operatie == 3) {
        return (var1 / var2);
    }else if (operatie == 4) {
        return (var1 % var2);
    }

    return 0;
}

bool IdList::compute_int_cmp(int var1, int operatie, int var2) {
    // string operatie = string(operation);

    if (operatie == 8) {
        if (var1 < var2)
            return true;
        return false;
    }else if (operatie == 9) {
        if (var1 <= var2)
            return true;
        return false;
    }else if (operatie == 10) {
        if (var1 > var2)
            return true;
        return false;
    }else if (operatie == 11) {
        if (var1 >= var2)
            return true;
        return false;
    }else if (operatie == 13) {
        if (var1 == var2)
            return true;
        return false;
    }else if (operatie == 12) {
        if (var1 != var2)
            return false;
        return false;
    }

    return false;
}

float IdList::compute_float_math(float var1, int operatie, float var2) {
    // string operatie = string(operation);

    if (operatie == 0) {
        return (var1 + var2);
    }else if (operatie == 1) {
        return (var1 - var2);
    }else if (operatie == 2) {
        return (var1 * var2);
    }

    return 0.0;
}

bool IdList::compute_float_cmp(float var1, int operatie, float var2) {
    // string operatie = string(operation);

    if (operatie == 8) {
        if (var1 < var2)
            return true;
        return false;
    }else if (operatie == 9) {
        if (var1 <= var2)
            return true;
        return false;
    }else if (operatie == 10) {
        if (var1 > var2)
            return true;
        return false;
    }else if (operatie == 11) {
        if (var1 >= var2)
            return true;
        return false;
    }else if (operatie == 13) {
        if (var1 == var2)
            return true;
        return false;
    }else if (operatie == 12) {
        if (var1 != var2)
            return false;
        return false;
    }

    return false;
}

bool IdList::compute_bool_value(bool var1, int operatie, bool var2) {
    // string operatie = string(operation);

    if (operatie == 5) {
        if (var1 == true && var2 == true)
            return true;
        return false;
    }else if (operatie == 6) {
        if (var1 == true || var2 == true)
            return true;
        return false;
    }

    return false;
}

void IdList::setVarFuncName(const char* s, string functName) {
    string strvar1 = string(s);

    for (IdInfo& v : vars) {
        if (v.name == strvar1) 
            v.functionName = functName;
    }
}

void IdList::setVarClassName(const char* s, string className) {
    string strvar1 = string(s);

    for (IdInfo& v : vars) {
        if (v.name == strvar1) 
            v.className = className;
    }
}

string IdList::getClassName(const char* s) {
    string strvar = string(s);
    string result;

    for (IdInfo& v : vars) {
        if (v.name == strvar) 
            result = v.className;
    }

    return result;
}

void IdList::setfunvector(const char* s) {
    cout << "debug: " << s << endl;
    funvect var = {string(s)};

    funvector.push_back(var);
}

// void IdList::addVar(const char* type, const char*name) {
//     IdInfo var = {string(type), string(name)};
//     vars.push_back(var);
// }

string IdList::getFuncName() {
    string strvar;

    for (funvect v : funvector) {
        strvar = v.name;
    }

    return strvar;
}

void IdList::printfuncNames() {
    for (funvect& v : funvector) {
        cout << v.name << ", ";
    }

    cout << endl;

    cout << getFuncName() << endl;
}

string IdList::getFuncType(const char* s) {
    string strvar = string(s);
    string strvar2;

    for (IdInfoFunc& v : functions) {
        if (strvar == v.name) { 
            strvar2 = v.name;
        }
    }

    return strvar2;

}

int IdList::getFuncNameVar(const char* s) {
    string strvar = string(s);

    for (IdInfo& v : vars) {
        if (strvar == v.name) { 
            if (v.functionName == "none")
                return 1;
        }
    }

    return 0;
}

bool IdList::existsclsVar(const char* s) {
    string strvar = string(s);

    for (classes& v : cls) {
        if (v.className == strvar)
            return true;
    }

    return false;
}

void IdList::addclsVar(const char* name) {
    const char* type = "none";
    IdInfo var = {string(type),string(name)};
    classes clasa = {string(name)};
    cls.push_back(clasa);
    vars.push_back(var);
}

void IdList::addVarClassName(const char* s, const char* classname) {
    string strvar = string(s);
    string strvar2 = string(classname);

    for (IdInfo& v : vars) {
        if (v.name == strvar)
            v.className = strvar2;
    }
}

void IdList::setPrivacy(const char* s, const char* prv) {
    string strvar1 = string(s);
    string strvar2 = string(prv);

    for (IdInfo& v : vars) {
        if (v.name == strvar1) {
            if (strvar2 == "public")
                v.publ = 1;
            else if (strvar2 == "private")
                v.pvt = 1;
            else if (strvar2 == "protected")
                v.protect = 1;
        }
    }
}

string IdList::getPrivacy(const char* s) {
    string strvar = string(s);
    string result;

    for (IdInfo& v: vars) {
        if (v.name == strvar) {
            if (v.protect == 1)
                result = "protected";
            else if (v.pvt == 1)
                result = "private";
            else if (v.publ == 1)
                result = "public";
        }
    }

    return result;
}

string IdList::getVarClassName(const char* s) {
    string strvar = string(s);
    string result;

    for (IdInfo& v: vars) {
        if (v.name == strvar) 
            result = v.className;
    }

    return result;
}

// void IdList::addVarIntValueFunc(const char* var,int value) {
//     string strvar = string(var);
//      for (IdInfoFunc& v : functions) {
//         if (strvar == v.name) { 
//             for (params& y : v.parameters)
//                 y.intval = value;
//         }
//     }
// }
 
void IdList::addVarTypeParam(const char* var, const char* type) {
    string strvar = string(var);
    string strtype = string(type);

     for (IdInfoFunc& v : functions) {
        if (strvar == v.name) { 
            for (params& y : v.parameters) {
                y.type = strtype;
                y.name = v.name;
            }
        }
    }
}

void IdList::setFuncHasParams(const char* var, bool value) {
    string strvar = string(var);

    for (IdInfoFunc& v: functions) {
        if (strvar == v.name)
            v.hasParams = value;
    }
}

void exps::addExpType(string type) {
    exp var = {type};
    express.push_back(var);
}

exps::exps(string type) {
    addExpType(type);
}

// bool sameParams(const char* s, call_list_prm parametr) {
//     string strvar = string(s);
//     IdList variabile;
//     bool theSame = true;

//     vector<parametri>::iterator it = parametr.call_params.begin();
//     vector<parametri>::iterator end = parametr.call_params.end();

//     for (IdInfo& v : variabile.vars) {
//         if (v.className == s) {
//             if (*it.getParamType() == v.type)
//                 theSame = true;
//             else theSame = false;

//              ++it; 
//         }
//     }
// }

call_list_prm::call_list_prm(string type) {
    setParamType(type);
}

void call_list_prm::setParamType(string type) {
    parametri var = {type};
    call_params.push_back(var);
}

void call_list_prm::printParams() {
    for (parametri& v : call_params) {
        cout << "tipul parametrului la apelare: " << v.type << ' ';
    }

    cout << endl;
}

string exps::getExpType() {
    string result;

    for (exp& v : express) {
        result = v.type;
    }

    return result;
}

string call_list_prm::getParamType() {
    string res;

    for (parametri& v : call_params) 
        res = v.type;

    return res;
}

void exps::setExpIntValue(int value) {
    for (exp& v : express) {
        v.intval = value;
    }
}

void exps::setExpFloatValue(float value) {
    for (exp& v : express) {
        v.floatval = value;
    }
}

void exps::setExpBoolValue(bool value) {
    for (exp& v : express) {
        v.boolval = value;
    }
}

int exps::getExpIntValue() {
    int result;

    for (exp& v : express) {
        result = v.intval;
    }

    return result;
}

float exps::getExpFloatValue() {
    float result;

    for (exp& v : express) {
        result = v.floatval;
    }

    return result;
}

bool exps::getExpBoolValue() {
    bool result;

    for (exp& v : express) {
        result = v.boolval;
    }

    return result;
}

IdList::~IdList() {
    vars.clear();
}











