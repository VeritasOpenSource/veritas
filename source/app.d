import std.stdio;

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

void main(string[] args)
{
	Ecosystem ecosystem = new Ecosystem;

	auto sources = dirEntries("../bash-5.3/","*.{h,c}",SpanMode.shallow)
		.filter!(a => a.isFile)
		.map!((return a) => baseName(a.name))
		// .array
        .map!((a) => createSourceFile("../bash-5.3/", a));

	
    auto analyzer = new VrtsSourceAnalyzer(ecosystem);
    analyzer.analyze(sources.array);

    if(args[1] == "findCallingFor"){

        auto func = ecosystem.functions.find!(a => a.name == args[2])[].front;

        func
            .calls
            .each!(a => writeln(a.calling.name));
    }

}

class VrtsSourceAnalyzer {
    Ecosystem ecosystem;
    VrtsSourceVisitor visitor;

    this(Ecosystem ecosystem) {
        this.ecosystem = ecosystem;
        this.visitor = new VrtsSourceVisitor;
    }

    void analyze(VrtsSourceFile[] sources) {
        foreach(ref source; sources) {
		    visitor.visitSourceFile(ecosystem, source);
	    }

    
    }
}