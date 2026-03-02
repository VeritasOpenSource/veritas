module veritas.clang;

import std.conv;
import veritas.toolkit;
// import std.complex;
import veritas.ecosystem;
import std.string;
import std.path;
import std.stdio;
import veritas.functionsCollector;
import veritas.callsCollector;


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

class ClangToolkit : VrtsToolkit {
    // CXTranslationUnit[VrtsSourceFile]   translationUnits;
    // CXCursor[VrtsFunction]              functionsCursor;

    struct Context {
        ClangToolkit toolkit;
        VrtsFunctionsCollector collector;
        VrtsSourceFile sfContext;
        VrtsFunction fContext;
        // VrtsFunction[] functions;    
    }

    // Context* context;

    override void extractFunctionsFromSourceFile(VrtsFunctionsCollector collector, VrtsSourceFile file) {
        CXIndex index = clang_createIndex(0, 0);

        CXTranslationUnit tu;
        
        const (char)*[] args;

        // args ~="-xc".toStringz;
        // args ~= "-w".toStringz;                    
        // args ~= "-Wno-everything".toStringz;       
        // args ~= "-Wno-error".toStringz;            
        // args ~= "-ferror-limit=1".toStringz;       
        // args ~= "-Wno-missing-include-dirs".toStringz;
        // args ~= "-Wno-implicit-function-declaration".toStringz;
        // args ~= "-Wno-missing-include-dirs".toStringz;

        args ~= "-nostdlib".toStringz;
        args ~= "-nostdinc".toStringz;

        tu = clang_parseTranslationUnit(index, 
            file.getPath.toStringz, 
            args.ptr, 
            cast(int)args.length,
            null,
            0,
            0x4000 | 0x400);

        // translationUnits[file] = tu;

        CXCursor root = clang_getTranslationUnitCursor(tu);

        Context* context = new Context;
        context.sfContext = file;
        // context.toolkit = this;
        context.collector = collector;

        // int[2] counts = [0, 0];
        clang_visitChildren(root, &sourceFileVisitor, cast(CXClientData)context);

        // auto funcs = context.functions;
        write(file.getPath, " ");
        // writeln(functionsCursor.length);

        // return funcs;

        // clang_disposeTranslationUnit(tu);
        // clang_disposeIndex(index);
    }

    extern(C) static uint sourceFileVisitor(CXCursor cursor, CXCursor parent, CXClientData data) {
        Context* context = cast(Context*)data;
        auto sourceFile = context.sfContext;
        auto collector = context.collector;
        
        int kind = clang_getCursorKind(cursor);

        if (kind == 8) {
            string name = cxToStr(cursor);

            auto funcDecl = collector.addFunction(sourceFile, name);
            // auto funcDecl = new VrtsFunction(0, name);
            // auto funcDecl = new VrtsFunction(context.functionCollector.getNewId(), name);
            // auto funcDecl = context.functionCollector.addFunction(sourceFile, name);

            CXSourceRange range = clang_getCursorExtent(cursor);
            CXSourceLocation start = clang_getRangeStart(range);
            CXSourceLocation end = clang_getRangeEnd(range);
            
            CXFile file;
            uint start_line, end_line;

            clang_getFileLocation(start, file, &start_line, null, null);
            clang_getFileLocation(end, file, &end_line, null, null);

            if(clang_isCursorDefinition(cursor)) {
                // context.functions ~= funcDecl;
                funcDecl.setLocation(true, parent.cxToStr().baseName, start_line, 0, end_line, 0);

                // context.fContext = funcDecl;
                // context.toolkit.functionsCursor[funcDecl] = cursor;
                // clang_visitChildren(cursor, &functionVisitor, data);
                writeln(name);
            }
            else {
                funcDecl.setLocation(false, parent.cxToStr().baseName, start_line, 0, end_line, 0);
            }
            return 1;
        }
       
        return 2; 
    }

    override void extractCallsFromFunction(VrtsCallsCollector collector, VrtsFunction func) {
        // return null;
    }

    // extern(C) static uint functionVisitor(CXCursor cursor, CXCursor parent, CXClientData data) {
    //     ClangToolkit context = cast(ClangToolkit)data;
    //     auto funcDecl = context.funcContext;
        
    //     auto refCur = clang_getCursorReferenced(cursor);
    //     auto refkind = clang_getCursorKind(refCur);

    //     if (refkind == 8) { 
    //         string name = cxToStr(refCur);
    //         auto call = new VrtsFunctionCall(context.callsCollector.getNewId, funcDecl, name);
    //         context.callsCollector.storage.add(call);
    //         // funcDecl.calls ~= call;
            
    //         return 1;
    //     }
       
    //     return 2; 
    // }
}