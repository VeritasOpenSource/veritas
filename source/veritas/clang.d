module veritas.clang;

import std.conv;

extern(C) {
    alias CXIndex = void*;
    alias CXTranslationUnit = void*;
    alias CXClientData = void*;
    alias CXFile = void*;

    struct CXString { 
        const(char)* data; 
        void* private_flags; 
    
    }

    struct CXCursor { 
        int kind; 
        int xdata; 
        void*[3] data; 
    }

    struct CXSourceLocation { 
        void*[2] data; 
        uint int_data; 
    }

    struct CXSourceRange {
        void*[2] 	ptr_data;
        uint 	begin_int_data;
        uint 	end_int_data;
    }
    
    alias CXCursorVisitor = uint function(CXCursor, CXCursor, CXClientData);
    
    CXIndex clang_createIndex(int, int);
    CXString clang_getFileName(CXFile);
    void clang_disposeIndex(CXIndex);
    CXTranslationUnit clang_createTranslationUnitFromSourceFile(CXIndex, const(char)*, int, const(char)**, uint, void*);
    CXTranslationUnit clang_parseTranslationUnit(
        CXIndex CIdx, const (char )*source_filename,
        const (char** )command_line_args, int num_command_line_args,
        void *unsaved_files, uint num_unsaved_files,
        uint options);
    void clang_disposeTranslationUnit(CXTranslationUnit);
    CXCursor clang_getTranslationUnitCursor(CXTranslationUnit);
    int clang_getCursorKind(CXCursor);
    CXString clang_getCursorSpelling(CXCursor);
    const(char)* clang_getCString(CXString);
    void clang_disposeString(CXString);
    CXSourceRange clang_getCursorExtent(CXCursor);
    uint clang_isCursorDefinition(CXCursor);
    void clang_getSpellingLocation(CXSourceLocation, CXFile, uint*, uint*, uint*);
    void clang_getFileLocation(CXSourceLocation, CXFile, uint*, uint*, uint*);
    CXSourceLocation clang_getRangeStart(CXSourceRange);
    CXSourceLocation clang_getRangeEnd(CXSourceRange);
    void clang_getExpansionLocation(CXSourceLocation, void*, uint* start, uint* start_col, void*);
    uint clang_visitChildren(CXCursor, CXCursorVisitor, CXClientData);
    int clang_Location_isInSystemHeader(CXSourceLocation location);
    CXSourceLocation clang_getCursorLocation(CXCursor cursor);
    CXSourceLocation clang_getCursorLocation(CXCursor cursor);
    CXCursor clang_getCursorReferenced(CXCursor cursor);
}

string cxToStr(CXCursor cursor) {
    CXString str = clang_getCursorSpelling(cursor);
    const(char)* cstr = clang_getCString(str);
    return cstr.to!string ? cstr.to!string : "";
}
