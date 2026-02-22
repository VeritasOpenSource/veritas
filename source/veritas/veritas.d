module veritas.mainCore;

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
import veritas.ipc.events;

class Veritas {
    VrtsEventBus eventsBus;
    VrtsEcosystem ecosystem;
    VrtsSourceAnalyzer analyzer;
    VrtsReportsParser parser;

    this(VrtsEventBus bus, string[] args) {
        this.eventsBus = bus;

        if(args.length > 1) {
            ecosystem = VrtsEcosystem.loadLocalDatabase(args[1]);
        }
        else {
            ecosystem = new VrtsEcosystem;
        }
        
        ecosystem.setEventBus(eventsBus);
        analyzer = new VrtsSourceAnalyzer(ecosystem);
        analyzer.setEventsBus(eventsBus);

        parser = new VrtsReportsParser;
    }

    void processCommand(string _command) {
        string[] commands = _command.to!string.split;

        if(commands[0] == "add") {
            string project = commands[1];
            addProject(project);
        } else

        if(commands[0] == "analyze") {
            ecosystem.recollectData();

            analyzer.analyzeSourceFilesByPackages(ecosystem.packages);

            ecosystem.relinkCalls();
            ecosystem.collectCalls();
            ecosystem.buildRingsIerarchy();

            // ecosystem.processReports();

            auto packages = ecosystem.getPackages();
            auto reports = parser.parseResultFile("../../veritas-test/bash/res.json");
            // writeln("Parsed");
            ecosystem.processReports(reports);

            // foreach(report; reports) {
            //     writeln(report.location);
            //     writeln(report.description);
            // }

            ecosystem.collectTriggers();
        }


    }

    void addProject(string path) {
        ecosystem.addPackage(absolutePath(path), path);
    }
}
