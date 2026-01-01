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
import veritas.reportparser;

VrtsSourceFile createSourceFile(string path, string filename) {
	return new VrtsSourceFile(path, filename);
}

void main(string[] args)
{
    VrtsReportsParser reportParser = new VrtsReportsParser();

    if(args.length < 2) {
        writeln("Nothing to do.");
        return;
    }

    string path = args[1];

	auto sources = dirEntries(path,"*.{h,c}",SpanMode.shallow)
		.filter!(a => a.isFile)
		.map!((return a) => baseName(a.name))
		// .array
        .map!((a) => createSourceFile(path, a));
        
    VrtsReportsFiles reportFiles; 
	VrtsEcosystem ecosystem = new VrtsEcosystem;

    auto analyzer = new VrtsSourceAnalyzer(ecosystem);
    
    analyzer.analyze(sources.array);

    // if(args[2] == "reports") {
    //     reportParser.parseMetadata(path ~ "reports/metadata.json");
    //     auto sourcesArray = sources.array;
    //     reportFiles = reportParser.linkReportsFilesWithSources(sourcesArray);

    //     foreach(item; reportFiles.filesAndReports.byPair) {
    //         writeln(item.key.fullname, " ", item.value);
    //     }
    //     return;
    // }

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

        writeln("Position in source file: ");
        writeln("   Start line: ", func.startLine);
        writeln("   End line: ", func.endLine);

    }

    if(args[2] == "--funcs-of-first-ring") {
        ecosystem.relinkCallings();
        auto funcs = ecosystem.getFunctionsWithoutCalls();
        funcs.each!(a => writeln("      ", a.name));
        writeln("Total: ", funcs.walkLength, " funcs");
    }

    // reportParser.parseMetadata(path ~ "/reports/metadata.json");
    // auto sourcesArray = sources.array;
    // reportFiles = reportParser.linkReportsFilesWithSources(sourcesArray);

    // foreach(item; reportFiles.filesAndReports.byPair) {
    //     writeln(item.key.fullname, " ", item.value);
    // }
        // return;
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