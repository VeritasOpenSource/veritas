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
import std.range;
import veritas.reportparser;
import veritas.sourceCollector;
import veritas.sourceAnalyzer;
import std.socket;
import veritas.ipc.events;
import mir.ser.ion;

import veritas.callsCollector;
import veritas.functionsCollector;

class Veritas {
    VrtsEventBus eventsBus;
    VrtsEcosystem ecosystem;
    VrtsSourceCollector     sourceCollector;
    VrtsSourceAnalyzer      sourceAnalyzer;
    VrtsFunctionsCollector  functionsCollector;
    VrtsCallsCollector      callsCollector;
    // VrtsReportsParser parser;

    this(VrtsEventBus bus, string[] args) {
        this.eventsBus = bus;

        if(args.length > 1) {
            // ecosystem = VrtsEcosystem.loadLocalDatabase(args[1]);
        }
        else {
            ecosystem = new VrtsEcosystem;
        }
        
        ecosystem.setEventBus(eventsBus);
    }

    void initAnalyzers() {
        sourceCollector = new VrtsSourceCollector(ecosystem);
        ecosystem.sourceFileStorage = sourceCollector.storage;

        functionsCollector = new VrtsFunctionsCollector(ecosystem, sourceCollector);
        callsCollector = new VrtsCallsCollector(ecosystem, sourceCollector);

        sourceAnalyzer = new VrtsSourceAnalyzer(sourceCollector, functionsCollector, callsCollector);
    }

    void processCommand(string _command) {
        string[] commands = _command.to!string.split;

        if(commands[0] == "add") {
            string package_ = commands[1];
            addPackage(package_);
        } else

        if(commands[0] == "analyze") {
            sourceCollector.collectAllSourceFiles(ecosystem);
            sourceCollector.storage.length.to!string.writeln;
            // ecosystem.recollectData();
            
            sourceAnalyzer.collectAllFunctions();
            writeln("DONE");
            // callsCollector.relinkCalls();
            // functionsCollectoranalyzer.analyzeSourceFilesByPackages(ecosystem.packages);

            // ecosystem.relinkCalls();
            // ecosystem.collectCalls();
            // ecosystem.buildRingsIerarchy();

            // auto packages = ecosystem.getPackages();
            // auto reports = parser.parseResultFile("../../veritas-test/bash/res.json");
            // ecosystem.processReports(reports);

            // ecosystem.collectTriggers();
        }

        if(commands[0] == "save database") {
            // auto model = ecosystem.buildModel;
            // auto serial = serializeIon(model);
            // File file = File("db.vrtsdb", "rb");
            // file.rawWrite(serial);
            // file.close();
        }
    }

    void addPackage(string path) {
        ecosystem.addPackage(path);
    }
}
