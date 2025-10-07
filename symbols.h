// symbols.h — Project 4
#pragma once
#include <map>
#include <string>

using std::map;
using std::string;

// To distinguish between scalar and list identifiers
enum IdKind { SCALAR_ID, LIST_ID };

template <typename T>
class Symbols {
public:
    bool find(char* lexeme, T& entry);
    void insert(char* lexeme, const T& entry);
    bool exists(const string& name) const;

private:
    map<string, T> symbols;
};

// ---- Implementation ----
template <typename T>
void Symbols<T>::insert(char* lexeme, const T& entry)
{
    string name(lexeme);
    symbols[name] = entry;
}

template <typename T>
bool Symbols<T>::find(char* lexeme, T& entry)
{
    string name(lexeme);
    typedef typename map<string, T>::iterator Iterator;
    Iterator iterator = symbols.find(name);
    bool found = iterator != symbols.end();
    if (found)
        entry = iterator->second;
    return found;
}

template <typename T>
bool Symbols<T>::exists(const string& name) const {
    return symbols.find(name) != symbols.end();
}
