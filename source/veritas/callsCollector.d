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
import veritas.functionsCollector;

class VrtsCallsCollector : VrtsAnalyzer!VrtsFunctionCall {
    VrtsEventBus eventBus;
    VrtsEcosystem ecosystem;
    VrtsSourceCollector sourceCollector;
    VrtsFunctionsCollector functionsCollector;

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
			VrtsSourceCollector collector,
            VrtsFunctionsCollector functionsCollector) {
        this.ecosystem = ecosystem;
		this.sourceCollector = collector; 
        this.functionsCollector = functionsCollector;
    }

    void relinkFunctionsCalls() {
        foreach(call; this.storage.data) {
            foreach(func; functionsCollector.storage.data) {
                if(!call.isDefined && call.getCallName == func.name) {
                    call.defineTarget(func);
                    func.calledBy ~= call;

                    break;
                }
            }
        }
    }
}