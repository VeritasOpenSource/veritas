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
import veritas.ecosystem.sourceFiles;
import veritas.ecosystem.sourceFiles;
import std.socket;
import veritas.ipc.events;
import mir.ser.ion;

import veritas.ecosystem;
import veritas.ecosystem.rings.ringsAnalyzer;
// import veritas.calls;
// import veritas.functionsCollector;
// import veritas.ecosystem.packages;

class Veritas {
    VrtsEventBus eventsBus;
    VrtsEcosystem ecosystem;

    VrtsPackageAnalyzer     packageAnalyzer;
    VrtsSourcePreparator    sourcePreparator;
    VrtsFunctionsAnalyzer   functionsAnalyzer;
    // VrtsPackagesCollector    packageCollector;
    // VrtsSourceCollector     sourceCollector;
    // VrtsFunctionsCollector  functionsCollector;
    // VrtsCallsCollector      callsCollector;
    // VrtsRingsCollector      ringsCollector;
    // VrtsRingsAnalyzer       ringsAnalyzers;


    // VrtsPackageAnalyzer     packageAnalyzer;
    VrtsSourceAnalyzer      sourceAnalyzer;
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
        packageAnalyzer = new VrtsPackageAnalyzer(ecosystem);
        ecosystem.packageCollector = packageAnalyzer.collector;

        sourcePreparator = new VrtsSourcePreparator(ecosystem);

        functionsAnalyzer = new VrtsFunctionsAnalyzer(ecosystem);

        // sourceCollector = new VrtsSourceCollector(ecosystem);
        // ecosystem.sourcesCollector = sourceCollector;

        // functionsCollector = new VrtsFunctionsCollector(ecosystem, sourceCollector);
        // callsCollector = new VrtsCallsCollector(ecosystem, sourceCollector, functionsCollector);

        sourceAnalyzer = new VrtsSourceAnalyzer(sourcePreparator.collector, functionsAnalyzer, null);


        // ringsCollector = new VrtsRingsCollector();
        // ringsAnalyzers = new VrtsRingsAnalyzer(ecosystem);


        // ecosystem.initCollectors(
        //     packageAnalyzer.collector,
        //     // functionsCollector,
        //     // callsCollector
        // );
    }

    void processCommand(string _command) {
        string[] commands = _command.to!string.split;

        if(commands[0] == "add") {
            string package_ = commands[1];
            packageAnalyzer.addPackage(package_);
        } else

        if(commands[0] == "analyze") {

            sourcePreparator.collectAllSourceFiles();
            sourcePreparator.collector.storage.length.to!string.writeln();


            // packageAnalyzer.addPackage
            // sourceCollector.collectAllSourceFiles();
            // sourceCollector.storage.length.to!string.writeln;
            
            sourceAnalyzer.collectAllFunctions();
            // sourceAnalyzer.collectAllCalls();
            // callsCollector.relinkFunctionsCalls();
            // ringsAnalyzers.buildRingsIerarchy();

            // callsCollector.storage.data.length.to!string.writeln;
            writeln("DONE");
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
}
