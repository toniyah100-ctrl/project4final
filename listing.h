// listing.h - simple listing and error reporting
#pragma once
#include <string>

enum ErrorCategory { LEXICAL = 0, SYNTAX = 1, SEMANTIC = 2 };

void openListing();
void closeListing();
void firstLine();
void nextLine();
void lastLine();
void appendError(ErrorCategory category, const std::string& message);
void appendError(ErrorCategory category, const std::string& message, int lineNumber);
void appendSource(const std::string& line);

int getLexicalCount();
int getSyntaxCount();
int getSemanticCount();
