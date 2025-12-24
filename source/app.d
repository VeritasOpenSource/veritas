import std.stdio;

// import veritas.pkg;
// import veritas.db;
// import veritas.analyzer.language;
// import veritas.analyzer.funcdecomposer;
import std.process;
import std.algorithm;
import std.array;
import std.file;
import std.path;
import core.sys.linux.fs;
import std.string;
import std.conv;
import veritas.ecosystem;
import veritas.clang;
// import ecosystem;

string cxToStr(CXCursor cursor) {
    CXString str = clang_getCursorSpelling(cursor);
    const(char)* cstr = clang_getCString(str);
    return cstr.to!string ? cstr.to!string : "";
}

class VrtsSourceFile {
	string path;
	string filename;

	this(string path, string filename) {
		this.path = path;
		this.filename = filename;
	}
}

VrtsSourceFile createSourceFile(string path, string filename) {
	return new VrtsSourceFile(path, filename);
}

// VrtsFunction initFunction(string name) {
// 	return new VrtsFunction(name);
// }

void main()
{
	Ecosystem ecosystem = new Ecosystem;
	// VrtsPackage bash = new VrtsPackage();
	auto sources = dirEntries("../bash-5.3/","*.{h,c}",SpanMode.shallow)
		.filter!(a => a.isFile)
		.map!((return a) => baseName(a.name))
		// .array
        .map!((a) => createSourceFile("../bash-5.3/", a));

	
    auto analyzer = new VrtsSourceAnalyzer;
    auto eco = new Ecosystem;
    analyzer.ecosystem = eco;
	// auto source = new VrtsSourceFile("../bash-5.3/", "execute_cmd.c");
	// writeln(analyzer.extractFunctions(null));
	// auto srange = sources.each!((a) => extractFunctions(a).initFunction());

	foreach(source; sources) {
		analyzer.extractFunctions(source);
	}

	writeln(ecosystem.functions.length);

}

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

class VrtsSourceAnalyzer {
    Ecosystem ecosystem;

    void extractFunctions(VrtsSourceFile file) {
        // Strings strings;
        writeln("Extracting file ", file.filename);

        CXIndex index = clang_createIndex(0, 1);

        CXTranslationUnit tu;
        
        if (tu is null) {
            const char* arg1 = "-nostdinc".toStringz;
            const char* arg2 = "-nostdlib".toStringz;
            const(char)*[2] args = [arg1, arg2];

            tu = clang_createTranslationUnitFromSourceFile(index, (file.path ~ file.filename).toStringz, 2, args.ptr, 0, null);
        }
        CXCursor root = clang_getTranslationUnitCursor(tu);

        int[2] counts = [0, 0];
        writeln(cxToStr(root));
        clang_visitChildren(root, &sourceFileVisitor, cast(CXClientData)this);
        
        writeln("Functions found: ", this.ecosystem.functions.length);

        clang_disposeTranslationUnit(tu);
        clang_disposeIndex(index);


        // return strings.strings;
    }


    extern(C) static uint sourceFileVisitor(CXCursor cursor, CXCursor parent, CXClientData data) {
        VrtsSourceAnalyzer context = cast(VrtsSourceAnalyzer)data;
        
        int kind = clang_getCursorKind(cursor);

        if (kind == 8) { // FunctionDecl
            string name = cxToStr(cursor);
			context.ecosystem.functions ~= new VrtsSourceFunctionDef(name);
            clang_visitChildren(cursor, &functionVisitor, cast(CXClientData)context);
            return 1;
        }
       
        return 1; // Continue
    }

    extern(C) static uint functionVisitor(CXCursor cursor, CXCursor parent, CXClientData data) {
        VrtsSourceAnalyzer context = cast(VrtsSourceAnalyzer)data;
        
        auto refCur = clang_getCursorReferenced(cursor);
        auto refkind = clang_getCursorKind(refCur);

        if (refkind == 8) { // CallExpr;
            // CXCursor curRef = clang_getCursorReferenced(cursor);
            // int refkind = clang_getCursorKind(curRef);
            string name = cxToStr(refCur);
            writeln(name);
			// context.ecosystem.functions ~= new VrtsSourceFunctionDef(name);
            
            return 2;
        }
       
        return 1; // Continue
    }
}