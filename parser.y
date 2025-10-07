/* Minimal Bison grammar with semantic checks to match CMSC430 Project 4 */
%{
#include <string>
#include <vector>
#include <map>
#include <iostream>

using namespace std;

#include "types.h"
#include "listing.h"
#include "symbols.h"

// Symbol tables
Symbols<Types> scalars;
Symbols<Types> lists;

static Types lookupScalar(char* name){
    Types t;
    if (!scalars.find(name, t)){
        appendError(SEMANTIC, string("Undeclared Scalar ") + name);
        return MISMATCH;
    }
    return t;
}
static Types lookupList(char* name){
    Types t;
    if (!lists.find(name, t)){
        appendError(SEMANTIC, string("Undeclared List ") + name);
        return MISMATCH;
    }
    return t;
}

void yyerror(const char* msg){ appendError(SYNTAX, msg); }

int yylex();
%}

/* Ensure parser.tab.h has the types it needs for YYSTYPE */
%code requires {
  #include <vector>
  #include "types.h"
}

%union {
    int    ival;
    double dval;
    char   cval;
    char*  sval;
    Types  type;
    std::vector<Types>* tlist;
}

%token FUNCTION RETURNS BEGIN_ END
%token T_INTEGER T_REAL T_CHARACTER T_LIST T_OF T_IS
%token T_WHEN T_SWITCH T_CASE
%token T_IF T_THEN T_ELSIF T_ELSE T_ENDIF
%token T_FOLD T_LEFT T_RIGHT T_ENDFOLD
%token PLUS MINUS TIMES DIVIDE REM POW TILDE
%token EQ LT
%token <ival> INT_LIT
%token <dval> REAL_LIT
%token <cval> CHAR_LIT
%token <sval> IDENT

%type <type> program type expr stmt stmts case cases when_stmt switch_stmt if_stmt fold_stmt primary
%type <tlist> expr_list elsif_list

%left EQ LT
%left PLUS MINUS
%left TIMES DIVIDE REM
%right POW
%right TILDE

%%

program
  : FUNCTION IDENT RETURNS type ';' decls BEGIN_ stmts END ';'
    { lastLine(); }
  ;

type
  : T_INTEGER     { $$ = INT_TYPE; }
  | T_REAL        { $$ = REAL_TYPE; }
  | T_CHARACTER   { $$ = CHAR_TYPE; }
  ;

decls
  : /* empty */
  | decls decl
  ;

decl
  : IDENT ':' type T_IS expr ';'
    {
      string name($1);
      if (isList($3)) { appendError(SEMANTIC, "List Type Does Not Match Element Types"); }
      if (scalars.exists(name)) appendError(SEMANTIC, "Duplicate Scalar " + name);
      else scalars.insert($1, $3);

      if ($3 == INT_TYPE && $5 == REAL_TYPE)
          checkAssignment(INT_TYPE, REAL_TYPE, "Illegal Narrowing Variable Initialization");
      else
          checkAssignment($3, $5, "Type Mismatch on Variable Initialization");
    }
  | IDENT ':' T_LIST T_OF type T_IS '(' expr_list ')' ';'
    {
      string name($1);
      Types listT = listOf($5);
      checkListElements(*$8);
      Types elem = $8->empty() ? $5 : (*$8)[0];
      checkListDecl(listT, elem);
      if (lists.exists(name)) appendError(SEMANTIC, "Duplicate List " + name);
      else lists.insert($1, listT);
      delete $8;
    }
  ;

expr_list
  : /* empty */ { $$ = new vector<Types>(); }
  | expr { $$ = new vector<Types>(); $$->push_back($1); }
  | expr_list ',' expr { $$ = $1; $$->push_back($3); }
  ;

stmts
  : /* empty */           { $$ = NONE; }
  | stmts stmt            { $$ = $2; }
  ;

stmt
  : expr ';'              { $$ = $1; }
  | when_stmt             { $$ = $1; }
  | switch_stmt           { $$ = $1; }
  | if_stmt               { $$ = $1; }
  | fold_stmt             { $$ = NONE; }
  ;

when_stmt
  : T_WHEN expr ',' expr ':' expr ';'
    { $$ = checkWhen($2, $4); }
  ;

switch_stmt
  : T_SWITCH '(' expr ')' '{' cases '}' 
    { checkSwitchExpr($3); $$ = $6; }
  ;

cases
  : case                  { $$ = $1; }
  | cases case            { $$ = checkCases($1, $2); }
  ;

case
  : T_CASE expr ':' stmts { $$ = $4; }
  ;

if_stmt
  : T_IF expr T_THEN stmts elsif_list T_ELSE stmts T_ENDIF ';'
    {
      std::vector<Types> blocks;
      blocks.push_back($4);
      std::vector<Types>* elsifs = $5;
      blocks.insert(blocks.end(), elsifs->begin(), elsifs->end());
      blocks.push_back($7);
      checkIfChain(blocks);
      $$ = $4;
      delete elsifs;
    }
  ;

elsif_list
  : /* empty */                     { $$ = new std::vector<Types>(); }
  | elsif_list T_ELSIF expr T_THEN stmts
    {
      $$ = $1;
      $$->push_back($5);
    }
  ;

fold_stmt
  : T_FOLD T_LEFT PLUS '(' IDENT ')' T_ENDFOLD ';'
    { checkFoldList(lookupList($5)); }
  | T_FOLD T_RIGHT TIMES '(' IDENT ')' T_ENDFOLD ';'
    { checkFoldList(lookupList($5)); }
  ;

expr
  : expr PLUS expr        { $$ = checkArithmetic($1, $3); }
  | expr MINUS expr       { $$ = checkArithmetic($1, $3); }
  | expr TIMES expr       { $$ = checkArithmetic($1, $3); }
  | expr DIVIDE expr      { $$ = checkArithmetic($1, $3); }
  | expr REM expr         { checkRemainder($1, $3); $$ = INT_TYPE; }
  | expr POW expr         { $$ = checkArithmetic($1, $3); }
  | expr EQ expr          { checkRelational($1, $3, "="); $$ = BOOL_TYPE; }
  | expr LT expr          { checkRelational($1, $3, "<"); $$ = BOOL_TYPE; }
  | MINUS expr %prec TILDE { $$ = $2; }
  | TILDE expr            { $$ = $2; }
  | primary               { $$ = $1; }
  ;

primary
  : INT_LIT               { $$ = INT_TYPE; }
  | REAL_LIT              { $$ = REAL_TYPE; }
  | CHAR_LIT              { $$ = CHAR_TYPE; }
  | IDENT                 { $$ = lookupScalar($1); }
  | IDENT '[' expr ']'    { Types lt = lookupList($1); checkListSubscript(lt, $3); $$ = elemOf(lt); }
  | '(' expr ')'          { $$ = $2; }
  ;

%%

#include <cstdio>
#include <cstring>

extern int yylex();
extern FILE* yyin;

int main(){
    openListing();
    firstLine();
    yyparse();
    closeListing();
    return 0;
}
