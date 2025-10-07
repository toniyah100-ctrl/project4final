#include <string>
#include <vector>
using std::string;
using std::vector;

#include "types.h"
#include "listing.h"

static void semerr(const string& msg){
    appendError(SEMANTIC, msg);
}

void checkAssignment(Types lValue, Types rValue, const string& message){
    if (lValue == NONE || rValue == NONE) return;
    if (isList(lValue) || isList(rValue)){
        if (lValue != rValue) semerr(message);
        return;
    }
    if (lValue == rValue) return;
    if (lValue == REAL_TYPE && rValue == INT_TYPE) return;
    if (lValue == INT_TYPE && rValue == REAL_TYPE){
        semerr(message);
        return;
    }
    semerr(message);
}

void checkFunctionReturn(Types declaredReturn, Types actualReturn, bool /*isNarrowingMsg*/){
    if (declaredReturn == NONE) return;
    if (declaredReturn == REAL_TYPE && actualReturn == INT_TYPE) return;
    if (declaredReturn == INT_TYPE && actualReturn == REAL_TYPE){
        semerr("Illegal Narrowing Function Return");
        return;
    }
    if (declaredReturn != actualReturn){
        semerr("Type Mismatch on Function Return");
    }
}

Types checkWhen(Types firstExpr, Types secondExpr){
    if (firstExpr == secondExpr) return firstExpr;
    semerr("When Types Mismatch");
    return MISMATCH;
}

void checkSwitchExpr(Types switchType){
    if (switchType != INT_TYPE){
        semerr("Switch Expression Not Integer");
    }
}

Types checkCases(Types left, Types right){
    if (left == NONE) return right;
    if (right == NONE) return left;
    if (left == right) return left;
    semerr("Case Types Mismatch");
    return MISMATCH;
}

Types checkArithmetic(Types left, Types right){
    if (!isNumeric(left) || !isNumeric(right)){
        semerr("Arithmetic Operator Requires Numeric Types");
        return MISMATCH;
    }
    if (left == REAL_TYPE || right == REAL_TYPE) return REAL_TYPE;
    return INT_TYPE;
}

void checkRemainder(Types left, Types right){
    if (left != INT_TYPE || right != INT_TYPE){
        semerr("Remainder Operator Requires Integer Operands");
    }
}

void checkRelational(Types left, Types right, const string& /*op*/){
    if (left == CHAR_TYPE || right == CHAR_TYPE){
        if (left != CHAR_TYPE || right != CHAR_TYPE){
            semerr("Character Literals Cannot be Compared to Numeric Expressions");
            return;
        }
        return;
    }
    if (isNumeric(left) && isNumeric(right)) return;
    semerr("Type Mismatch in Relational Expression");
}

void checkIfChain(const vector<Types>& stmtTypes){
    if (stmtTypes.empty()) return;
    Types t0 = stmtTypes.front();
    for (size_t i=1;i<stmtTypes.size();++i){
        if (stmtTypes[i] != t0){
            semerr("If-Elsif-Else Type Mismatch");
            return;
        }
    }
}

void checkFoldList(Types listType){
    if (!isList(listType)){
        semerr("Fold Requires A Numeric List");
        return;
    }
    Types elem = elemOf(listType);
    if (!isNumeric(elem)){
        semerr("Fold Requires A Numeric List");
    }
}

void checkListElements(const vector<Types>& elems){
    if (elems.empty()) return;
    Types t0 = elems.front();
    for (Types t : elems){
        if (t != t0){
            semerr("List Element Types Do Not Match");
            return;
        }
    }
}

void checkListDecl(Types declaredListType, Types elementType){
    Types want = elemOf(declaredListType);
    if (want == MISMATCH || want != elementType){
        semerr("List Type Does Not Match Element Types");
    }
}

void checkListSubscript(Types listType, Types subscriptType){
    if (subscriptType != INT_TYPE){
        semerr("List Subscript Must Be Integer");
    }
}
