#pragma once
#include <string>
#include <vector>
using std::string;
using std::vector;

typedef char* CharPtr;

enum Types {
    MISMATCH = 0,
    NONE,
    INT_TYPE,
    REAL_TYPE,
    CHAR_TYPE,
    BOOL_TYPE,
    LIST_OF_INT,
    LIST_OF_REAL,
    LIST_OF_CHAR
};

inline bool isNumeric(Types t) { return t == INT_TYPE || t == REAL_TYPE; }
inline bool isList(Types t)    { return t == LIST_OF_INT || t == LIST_OF_REAL || t == LIST_OF_CHAR; }
inline Types listOf(Types elem){
    if (elem == INT_TYPE)  return LIST_OF_INT;
    if (elem == REAL_TYPE) return LIST_OF_REAL;
    if (elem == CHAR_TYPE) return LIST_OF_CHAR;
    return MISMATCH;
}
inline Types elemOf(Types list){
    if (list == LIST_OF_INT)  return INT_TYPE;
    if (list == LIST_OF_REAL) return REAL_TYPE;
    if (list == LIST_OF_CHAR) return CHAR_TYPE;
    return MISMATCH;
}

void appendError(int, const string&);

void  checkAssignment(Types lValue, Types rValue, const string& message);
Types checkWhen(Types firstExpr, Types secondExpr);
void  checkSwitchExpr(Types switchType);
Types checkCases(Types left, Types right);
Types checkArithmetic(Types left, Types right);
void  checkRemainder(Types left, Types right);
void  checkRelational(Types left, Types right, const string& op);
void  checkIfChain(const vector<Types>& stmtTypes);
void  checkFoldList(Types listType);
void  checkListElements(const vector<Types>& elems);
void  checkListDecl(Types declaredListType, Types elementType);
void  checkListSubscript(Types listType, Types subscriptType);
void  checkFunctionReturn(Types declaredReturn, Types actualReturn, bool isNarrowingMsg);
