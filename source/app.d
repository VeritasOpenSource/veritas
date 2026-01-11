module veritas.app;

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
        if(inputFile != stdin) {
            writeln("Using script mode...");
        }
        string command;
        while(command != "exit") {
            char[] _command;

            write(">>");
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

            if(commands[0] == "analyze") {
                ecosystem.recollectData();

                writeln("Analyzing source files...");
                analyzer.analyzeSourceFiles(ecosystem.sourceFiles);

                writeln(("Linking functions..."));
                ecosystem.relinkCalls();
                writeln(("Building rings ierarchy..."));
                ecosystem.buildRingsIerarchy();
            }else

            if(commands[0] == "info") {
                writeln("Funcitons count: ", ecosystem.functions.length);
            } else

            if(commands[0] == "ringsCount") {
                writeln("Call rings detected: ", ecosystem.rings.length);
            }
        }
    }

    void addProject(string path) {
        VrtsPackage pkg = new VrtsPackage(path, path);
        ecosystem.addPackage(pkg);
    }
}

void main(string[] args) {
    Veritas veritas = new Veritas;
    
    if(args.length > 1)
        veritas.runLoop(File(args[1]));
    else
        veritas.runLoop();
}