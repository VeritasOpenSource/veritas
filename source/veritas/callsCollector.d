module veritas.callsCollector;

// module veritas.ecosystem.sourceAnalyzer;

import veritas.ecosystem;
import veritas.sourceCollector;
import std.stdio;
import std.file;
import std.array;

import std.algorithm;
import std.conv;

import veritas.analyzer;
import veritas.preparing;
import veritas.ipc.events;
import veritas.ecosystem.call;

class VrtsCallsCollector : VrtsAnalyzer!VrtsFunctionCall {
    VrtsEventBus eventBus;
    VrtsEcosystem ecosystem;
    VrtsSourceCollector sourceCollector;

    struct FunctionSourceAssoc {
        VrtsPackage pkg;
        VrtsSourceFile[] file;
    }

    FunctionSourceAssoc[] associatedFunctions;

    void setEventsBus(VrtsEventBus eventBus) {
        this.eventBus = eventBus;
    }

    uint getNewId() {
        return cast(uint)storage.length;
    }

    this(	VrtsEcosystem ecosystem,
			VrtsSourceCollector collector) {
        this.ecosystem = ecosystem;
		this.sourceCollector = collector; 
    }
}