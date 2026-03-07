module veritas.ecosystem.calls.callsCollector;

// module veritas.ecosystem.sourceAnalyzer;

import veritas.ecosystem;
import veritas.ecosystem.sourceFiles;
import std.stdio;
import std.file;
import std.array;

import std.algorithm;
import std.conv;

import veritas.common.collector;
import veritas.ecosystem.packages;
import veritas.ipc.events;
import veritas.ecosystem.calls;
import veritas.ecosystem.functions;

class VrtsCallsCollector : VrtsCollector!VrtsFunctionCall {
    VrtsEventBus eventBus;
    // VrtsEcosystem ecosystem;
    // VrtsSourceCollector sourceCollector;

    VrtsFunctionsCollector functionsCollector;
    struct FunctionCalls {
		VrtsFunctionCall[] ongoing;
		VrtsFunctionCall[] outgoing;	
	}
    FunctionCalls[VrtsFunction] callsPerFunctions;

    // struct FunctionSourceAssoc {
    //     VrtsPackage pkg;
    //     VrtsSourceFile[] file;
    // }

    // FunctionSourceAssoc[] associatedFunctions;

    void setEventsBus(VrtsEventBus eventBus) {
        this.eventBus = eventBus;
    }

    uint getNewId() {
        return cast(uint)storage.length;
    }

    this(	VrtsEcosystem ecosystem) {
        // this.ecosystem = ecosystem;
		// this.sourceCollector = collector; 
        this.functionsCollector = ecosystem.functionsCollector;
    }



    auto getFunctionsWithoutCalls() {
        return functionsCollector.storage.data.filter!((a) => a.calls.length == 0);
    }
}