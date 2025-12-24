module veritas.clang;

import std.conv;

extern(C) {
    alias CXIndex = void*;
    alias CXTranslationUnit = void*;
    alias CXClientData = void*;
    alias CXSourceLocation = void*;
    
    struct CXString { const(char)* data; void* private_flags; }
    struct CXCursor { int kind; int xdata; void*[3] data; }
    
    alias CXCursorVisitor = uint function(CXCursor, CXCursor, CXClientData);
    
    CXIndex clang_createIndex(int, int);
    void clang_disposeIndex(CXIndex);
    CXTranslationUnit clang_createTranslationUnitFromSourceFile(CXIndex, const(char)*, int, const(char)**, uint, void*);
    void clang_disposeTranslationUnit(CXTranslationUnit);
    CXCursor clang_getTranslationUnitCursor(CXTranslationUnit);
    int clang_getCursorKind(CXCursor);
    CXString clang_getCursorSpelling(CXCursor);
    const(char)* clang_getCString(CXString);
    void clang_disposeString(CXString);
    uint clang_visitChildren(CXCursor, CXCursorVisitor, CXClientData);
    int clang_Location_isInSystemHeader(CXSourceLocation location);
    CXSourceLocation clang_getCursorLocation(CXCursor cursor);
    CXCursor clang_getCursorReferenced(CXCursor cursor);
}

string cxToStr(CXCursor cursor) {
    CXString str = clang_getCursorSpelling(cursor);
    const(char)* cstr = clang_getCString(str);
    return cstr.to!string ? cstr.to!string : "";
}
