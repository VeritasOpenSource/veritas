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
import veritas.sourceVisitor;

VrtsSourceFile createSourceFile(string path, string filename) {
	return new VrtsSourceFile(path, filename);
}

// VrtsFunction initFunction(string name) {
// 	return new VrtsFunction(name);
// }

void main()
{
	Ecosystem ecosystem = new Ecosystem;
    VrtsSourceVisitor visitor;
	// VrtsPackage bash = new VrtsPackage();
	auto sources = dirEntries("../bash-5.3/","*.{h,c}",SpanMode.shallow)
		.filter!(a => a.isFile)
		.map!((return a) => baseName(a.name))
		// .array
        .map!((a) => createSourceFile("../bash-5.3/", a));

	
    auto analyzer = new VrtsSourceAnalyzer(ecosystem);
    // auto eco = new Ecosystem;
    // analyzer.ecosystem = eco;
	// auto source = new VrtsSourceFile("../bash-5.3/", "execute_cmd.c");
	// writeln(analyzer.extractFunctions(null));
	// auto srange = sources.each!((a) => extractFunctions(a).initFunction());

    analyzer.analyze(sources.array);
	// foreach(source; sources) {
	// 	analyzer.extractFunctions(source);
	// }

	writeln(ecosystem.functions.length);

}



class VrtsSourceAnalyzer {
    Ecosystem ecosystem;
    VrtsSourceVisitor visitor;

    this(Ecosystem ecosystem) {
        this.ecosystem = ecosystem;
        this.visitor = new VrtsSourceVisitor;
    }

    void analyze(VrtsSourceFile[] sources) {
        foreach(source; sources) {
		    visitor.visitSourceFile(ecosystem, source);
	    }
    }
}