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

    auto getFunctionsWithoutCalls() {
        return functionsCollector.storage.data.filter!((a) => a.calls.length == 0);
    }
}