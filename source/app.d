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
import veritas.sourceVisitor;
import veritas.ecosystem.sourceAnalyzer;

class Veritas {
    VrtsEcosystem ecosystem;
    VrtsSourceAnalyzer analyzer;

    this() {
        ecosystem = new VrtsEcosystem;
        analyzer = new VrtsSourceAnalyzer(ecosystem);
    }

    void runLoop() {
        string command;
        while(command != "exit") {
            char[] _command;

            write(">>");
            readln(_command);

            command = _command[0..$-1].to!string;

            if(command[0..3] == "add") {
                string project = command[4..$];
                writeln(project);
                addProject(project);
            }

            if(command[0..4] == "info") {
                string project = command[4..$];
                // writeln(project);
                writeln(ecosystem.functions.length);
            }
        }
    }

    void addProject(string path) {
        auto sources = scanForSourceFiles(path);

        auto sourcesArray = sources.array;
        auto analyzer = new VrtsSourceAnalyzer(ecosystem);

        analyzer.analyze(sourcesArray);

        ecosystem.relinkCalls();
        ecosystem.buildRingsIerarchy();
    }
}

VrtsSourceFile createSourceFile(string path, string filename) {
	return new VrtsSourceFile(path, filename);
}

auto scanForSourceFiles(string path) {
    return dirEntries(path,"*.{h,c}",SpanMode.shallow)
		.filter!(a => a.isFile)
		.map!((return a) => baseName(a.name))
        .map!((a) => createSourceFile(path, a));
}


void main(string[] args) {
    Veritas veritas = new Veritas;

    veritas.runLoop();
}