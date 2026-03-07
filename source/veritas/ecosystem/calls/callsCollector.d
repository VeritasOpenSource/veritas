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
import std.array;

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

    bool isOutgoingCallsIsUndefined(VrtsFunction func) {
        return getOutgoingCalls(func).all!(a => !a.isDefined);
    }

    VrtsFunctionCall[] getOutgoingCalls(VrtsFunction func) {
        // writeln(func.name);
        if(func !in callsPerFunctions)
            return [];

        return callsPerFunctions[func].outgoing;
        // try {
        // }
        // catch(Exception e) {
        //     writeln(func.name);
        //     return [];
        // }
    }

    auto getFunctionsWithoutCalls() {
        return callsPerFunctions.byKeyValue().filter!(a => a.value.outgoing.length == 0);
        // return functionsCollector.storage.data.filter!((a) => a.calls.length == 0);
    }
}