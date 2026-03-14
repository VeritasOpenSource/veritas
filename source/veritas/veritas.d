module veritas.mainCore;

import std.stdio;
import std.string;
import std.conv;

import veritas.ipc;
import veritas.ecosystem.ecosystem;
import veritas.ecosystem.packages;
import veritas.ecosystem.sourceFiles;
import veritas.ecosystem.functions;
import veritas.ecosystem.calls;
import veritas.ecosystem.rings;
import veritas.ecosystem.reports;


class Veritas {
    VrtsEventBus eventsBus;
    VrtsEcosystem ecosystem;

    VrtsPackageAnalyzer     packageAnalyzer;
    VrtsSourcePreparator    sourcePreparator;
    VrtsFunctionsAnalyzer   functionsAnalyzer;
    VrtsCallsAnalyzer       callsAnalyzer;
    VrtsRingsAnalyzer       ringsAnalyzers;
    VrtsReportsAnalyzer     reportsAnalyzer;

    VrtsSourceAnalyzer      sourceAnalyzer;

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
        ecosystem.sourcesCollector = sourcePreparator.collector;

        functionsAnalyzer = new VrtsFunctionsAnalyzer(ecosystem);
        ecosystem.functionsCollector = functionsAnalyzer.collector;

        callsAnalyzer = new VrtsCallsAnalyzer(ecosystem);
        ecosystem.callsCollector = callsAnalyzer.collector;

        sourceAnalyzer = new VrtsSourceAnalyzer(sourcePreparator.collector, functionsAnalyzer, callsAnalyzer);

        ringsAnalyzers = new VrtsRingsAnalyzer(ecosystem);

        reportsAnalyzer = new VrtsReportsAnalyzer(ecosystem);
    }

    void processCommand(string _command) {
        string[] commands = _command.to!string.split;

        if(commands[0] == "add") {
            string package_ = commands[1];
            packageAnalyzer.addPackage(package_);
        } else

        if(commands[0] == "analyze") {

            sourcePreparator.collectAllSourceFiles();

            sourceAnalyzer.collectAllFunctions();
            sourceAnalyzer.collectAllCalls();
            callsAnalyzer.relinkFunctionsCalls();
            ringsAnalyzers.buildRingsIerarchy();
            reportsAnalyzer.parseReports();
            reportsAnalyzer.collector.length.to!string.writeln();

            
            writeln("DONE");
        }

        if(commands[0] == "save database") {
            // auto model = ecosystem.buildModel;
            // auto serial = serializeIon(model);
            // File file = File("db.vrtsdb", "rb");
            // file.rawWrite(serial);
            // file.close();
        }
    }

    import veritas.ipc.messages;
    import std.algorithm;
    import std.array;

    VrtsResponsePackagesList getPackagesList() {
        auto names = packageAnalyzer.collector.storage.data.map!(a => a.getName()).array;
        auto res = new VrtsResponsePackagesList();
        res.packagesList = names;
        return res;
    }
}

