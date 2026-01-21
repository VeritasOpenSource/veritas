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
import veritas.ecosystem.journal;
import std.socket;
// import veritas.ipc;
import veritas.ipc;

import tb2;

import ui;

class CommandInterpretator {
    void processCommand(string line) {
        
    }
}

class Veritas {
    VrtsEcosystem ecosystem;
    VrtsSourceAnalyzer analyzer;

    this() {
        ecosystem = new VrtsEcosystem;
        analyzer = new VrtsSourceAnalyzer(ecosystem);
    }

    void processCommand(string _command) {
        string[] commands = _command.to!string.split;

        if(commands[0] == "add") {
            string project = commands[1];
            writeln(project);
            addProject(project);
        } else

        if(commands[0] == "analyze") {
            ecosystem.recollectData();

            analyzer.analyzeSourceFilesByPackages(ecosystem.packages);

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

    void addProject(string path) {
        VrtsPackage pkg = new VrtsPackage(absolutePath(path), path);
        ecosystem.addPackage(pkg);
    }
}

enum string SOCKET_PATH = "/tmp/veritas.sock"; 

void main(string[] args) {
    Veritas veritas = new Veritas;

    CommandInterpretator ci = new CommandInterpretator();
    
    if(args.length > 1)
        veritas.runLoop(File(args[1]));
    else
        veritas.runLoop();
}