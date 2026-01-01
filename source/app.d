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
import std.range;

VrtsSourceFile createSourceFile(string path, string filename) {
	return new VrtsSourceFile(path, filename);
}

void main(string[] args)
{
    if(args.length < 2) {
        writeln("Nothing to do.");
        return;
    }
    string path = args[1];
	VrtsEcosystem ecosystem = new VrtsEcosystem;

	auto sources = dirEntries(path,"*.{h,c}",SpanMode.shallow)
		.filter!(a => a.isFile)
		.map!((return a) => baseName(a.name))
		// .array
        .map!((a) => createSourceFile(path, a));

	
    auto analyzer = new VrtsSourceAnalyzer(ecosystem);
    analyzer.analyze(sources.array);

    if(args[2] == "--find-calls-inside"){

        auto func = ecosystem.functions.find!(a => a.name == args[3])[].front;

        func
            .calls
            .each!(a => writeln(a.calling.name));
    }

    
    if(args[2] == "--info-func") {
        ecosystem.relinkCallings();
        auto func = ecosystem.functions.find!(a => a.name == args[3])[].front;

        writeln("Calls: ");
        func
            .calls
            .each!(a => writeln("   ", a.getCallName));

        writeln("Called by: ");
        func
            .callers
            .each!(a => writeln("   ", a.getCallName));
    }

    if(args[2] == "--funcs-of-first-ring") {
        ecosystem.relinkCallings();
        auto funcs = ecosystem.getFunctionsWithoutCalls();
        funcs.each!(a => writeln("      ", a.name));
        writeln("Total: ", funcs.walkLength, " funcs");
    }
}

class VrtsSourceAnalyzer {
    VrtsEcosystem ecosystem;
    VrtsSourceVisitor visitor;

    this(VrtsEcosystem ecosystem) {
        this.ecosystem = ecosystem;
        this.visitor = new VrtsSourceVisitor;
    }

    void analyze(VrtsSourceFile[] sources) {
        foreach(ref source; sources) {
		    visitor.visitSourceFile(ecosystem, source);
	    }
    }
}