module veritas.clang;

import std.conv;
import veritas.common.toolkit;
// import std.complex;
import veritas.ecosystem;
import std.string;
import std.path;
import std.stdio;
import veritas.ecosystem.functions;
import veritas.ecosystem.calls;
import std.process;
import std.algorithm;


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

    // enum CXChildVisit_Break = 0;
    // enum CXChildVisit_Continue = 1;
    // enum CXChildVisit_Recurse = 2;

    enum CXCursor_FunctionDecl = 8;
    enum CXCursor_CallExpr = 103;

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
    bool clang_Cursor_isNull(CXCursor cursor);
}

string cxToStr(CXCursor cursor)
{
    auto str = clang_getCursorSpelling(cursor);
    scope(exit) clang_disposeString(str);

    auto c = clang_getCString(str);
    return c ? c.to!string : "";
}

class ClangToolkit : VrtsToolkit {
    CXIndex index;
    CXTranslationUnit[VrtsSourceFile] tus;
    CXCursor[VrtsFunction] functionCursors;

    this() {
        index = clang_createIndex(0, 0);
    }

    ~this() {
        foreach (tu; tus)
            clang_disposeTranslationUnit(tu);
        clang_disposeIndex(index);
    }

    struct Context {
            ClangToolkit toolkit;
            VrtsFunctionsAnalyzer analyzer;
            VrtsSourceFile file;
    }

    override void extractFunctionsFromSourceFile(
        VrtsFunctionsAnalyzer analyzer,
        VrtsSourceFile file) {
        const(char)*[] args;

        auto tu = clang_parseTranslationUnit(
            index,
            file.getPath.toStringz,
            args.ptr,
            cast(int)args.length,
            null,
            0,
            0);

        tus[file] = tu;

        auto root = clang_getTranslationUnitCursor(tu);

        struct Context {
            ClangToolkit toolkit;
            VrtsFunctionsAnalyzer funcsAnalyzer;
            VrtsSourceFile file;
        }

        auto ctx = new Context(this, analyzer, file);

        clang_visitChildren(root, &functionVisitor, cast(void*)ctx);
    }

    extern(C) static uint functionVisitor(
        CXCursor cursor,
        CXCursor parent,
        CXClientData data) {
        auto ctx = cast(Context*)data;

        if (clang_getCursorKind(cursor) == CXCursor_FunctionDecl &&
            clang_isCursorDefinition(cursor)) {
            string name = cxToStr(cursor);

            auto func = ctx.analyzer.addFunction(ctx.file, name);
            ctx.toolkit.functionCursors[func] = cursor;

            // writeln("FUNCTION: ", name);
        }

        return 2;
    }

    override void extractCallsFromFunction(
        VrtsCallsAnalyzer analyzer,
        VrtsFunction func) {
        if (func !in functionCursors)
            return;

        auto cursor = functionCursors[func];

        struct CallContext {
            VrtsFunction func;
            VrtsCallsAnalyzer analyzer;
        }

        auto ctx = new CallContext(func, analyzer);

        clang_visitChildren(cursor, &callVisitor, cast(void*)ctx);
    }

    extern(C) static uint callVisitor(
    CXCursor cursor,
    CXCursor parent,
    CXClientData data)
{
    struct CallContext {
        VrtsFunction func;
        VrtsCallsAnalyzer analyzer;
    }

    // auto ctx = cast(CallContext*)data;

    // if(ctx.func.name == "realloc_line") {
    //     writeln("realloc_line");
    // }

    // auto kind = clang_getCursorKind(cursor);

    // if (kind == CXCursor_CallExpr)
    // {
    //     auto ref_ = clang_getCursorReferenced(cursor);

    //     string name;

    //     if (!clang_Cursor_isNull(ref_))
    //         name = cxToStr(ref_);
    //     else
    //         name = cxToStr(cursor);

    //     ctx.analyzer.addCall(ctx.func, name);

    //     if (ctx.func.name == "realloc_line")
    //         writeln("CALL: ", name);
    // }

        auto context = cast(CallContext*)data;
        auto funcDecl = context.func;
        
        auto refCur = clang_getCursorReferenced(cursor);
        auto refkind = clang_getCursorKind(refCur);

        if (refkind == 8) { 
            string name = cxToStr(refCur);
            context.analyzer.addCall(context.func, name);
            
            return 1;
        }
        // else 
        // if (refkind == CXCursor_CallExpr)
        // {
        //     auto ref_ = clang_getCursorReferenced(cursor);

        //     string name;

        //     if (!clang_Cursor_isNull(ref_))
        //         name = cxToStr(ref_);
        //     else
        //         name = cxToStr(cursor);

        //     context.analyzer.addCall(context.func, name);

        //     // if (ctx.func.name == "realloc_line")
        //         // writeln("CALL: ", name);
        // }

    return 2;
}

    override void startStaticAnalyze(VrtsPackage pkg) {
        auto meta = pkg.getMetadata;
        ProcessPipes proc = pipeProcess(["bash"]);

        proc.stdin.writeln("cd ~/veritas-test/");
		proc.stdin.writeln("cd bash");
		proc.stdin.writeln("Codechecker analyze ./compile_commands.json --output ./reports");
        proc.stdin.flush;
        proc.stdin.writeln("CodeChecker parse --export html --output ../reports_html ../reports_bash");
        proc.stdin.flush;
        proc.stdin.writeln("CodeChecker parse --export json --output ../reports.json ../reports_bash");
        proc.stdin.flush;

        proc
			.stdout
			.byLine
			.each!(a => a.writeln);

		proc.stdin.close();
    }
}