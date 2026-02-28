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
import mir.ser.ion;

class Veritas {
    VrtsEventBus eventsBus;
    VrtsEcosystem ecosystem;
    VrtsSourceCollector analyzer;
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
        analyzer = new VrtsSourceCollector(ecosystem);
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

            auto packages = ecosystem.getPackages();
            auto reports = parser.parseResultFile("../../veritas-test/bash/res.json");
            ecosystem.processReports(reports);

            ecosystem.collectTriggers();
        }

        if(commands[0] == "save database") {
            auto model = ecosystem.buildModel;
            auto serial = serializeIon(model);
            File file = File("db.vrtsdb", "rb");
            file.rawWrite(serial);
            file.close();
        }
    }

    void addProject(string path) {
        ecosystem.addPackage(absolutePath(path), path);
    }
}
