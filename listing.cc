// listing.cc - simple listing and error reporting
#include "listing.h"
#include <iostream>
#include <vector>
#include <string>

using namespace std;

static int lineNumber = 0;
static int lexicalErrors = 0;
static int syntaxErrors = 0;
static int semanticErrors = 0;
static vector<string> pendingErrors;

void openListing() {}
void closeListing() {}

void firstLine() {
    lineNumber = 1;
    cout << " " << lineNumber << " ";
}

void nextLine() {
    ++lineNumber;
    cout << " " << lineNumber << " ";
}

void lastLine() {
    cout << "Lexical Errors " << lexicalErrors << "\n";
    cout << "Syntax Errors " << syntaxErrors << "\n";
    cout << "Semantic Errors " << semanticErrors << "\n";
}

void appendSource(const string& line) {
    cout << line << "\n";
    for (auto& e : pendingErrors) {
        cout << "Semantic Error, " << e << "\n";
    }
    pendingErrors.clear();
}

void appendError(ErrorCategory category, const string& message) {
    if (category == LEXICAL) {
        ++lexicalErrors;
        cout << "Error: " << message << "\n";
    } else if (category == SYNTAX) {
        ++syntaxErrors;
        cout << "Error: " << message << "\n";
    } else if (category == SEMANTIC) {
        ++semanticErrors;
        // buffer semantic errors to print after the source line
        pendingErrors.push_back(message);
    }
}

void appendError(ErrorCategory category, const string& message, int /*lineNumber*/) {
    appendError(category, message);
}

int getLexicalCount() { return lexicalErrors; }
int getSyntaxCount() { return syntaxErrors; }
int getSemanticCount() { return semanticErrors; }
