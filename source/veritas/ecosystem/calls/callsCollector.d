module veritas.ecosystem.calls.callsCollector;

import std.file;
import std.array;
import std.algorithm;
import std.conv;

import veritas.ecosystem.calls.call;
import veritas.ecosystem.ecosystem;
import veritas.common.collector;
import veritas.ecosystem.functions;

class VrtsCallsCollector : VrtsStorage!VrtsFunctionCall {
    VrtsFunctionsCollector functionsCollector;
    struct FunctionCalls {
		VrtsFunctionCall[] ongoing;
		VrtsFunctionCall[] outgoing;	
	}
    FunctionCalls[VrtsFunction] callsPerFunctions;

    uint getNewId() {
        return cast(uint)storage.length;
    }

    this(	VrtsEcosystem ecosystem) {
        this.functionsCollector = ecosystem.functionsCollector;
    }

    bool isOutgoingCallsIsUndefined(VrtsFunction func) {
        return getOutgoingCalls(func).all!(a => !a.isDefined);
    }

    VrtsFunctionCall[] getOutgoingCalls(VrtsFunction func) {
        if(func !in callsPerFunctions)
            return [];

        return callsPerFunctions[func].outgoing;
    }

    auto getFunctionsWithoutCalls() {
        return callsPerFunctions.byKeyValue().filter!(a => a.value.outgoing.length == 0);
    }
}