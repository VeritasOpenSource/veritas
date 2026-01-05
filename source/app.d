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

    void runLoop(File inputFile = stdin) {
        string command;
        while(command != "exit") {
            char[] _command;

            write("");
            inputFile.readln(_command);

            if(_command.length == 0) {
                inputFile = stdin;
                continue;
            }

            string[] commands = _command.to!string.split;

            if(commands[0] == "exit")
                break;

            if(commands[0] == "add") {
                string project = commands[1];
                writeln(project);
                addProject(project);
            } else

            if(commands[0] == "info") {
                // string project = command[4..$];
                // writeln(project);
                writeln(ecosystem.functions.length);
            } else

            if(commands[0] == "ringsCount") {
                // string project = command[4..$];
                // writeln(project);
                writeln(ecosystem.rings.length);
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
    
    if(args.length > 1)
        veritas.runLoop(File(args[1]));
    else
        veritas.runLoop();
}