module veritas.ecosystem.calls.callsAnalyzer;

import veritas.common.analyzer;
import veritas.ecosystem.ecosystem;
import veritas.ecosystem.calls;
import veritas.ecosystem.functions.func;

class VrtsCallsAnalyzer : VrtsAnalyzer {

	VrtsCallsCollector	collector;

	this(VrtsEcosystem ecosystem) {
        //No need ecosystem data here
		collector = new VrtsCallsCollector(ecosystem);
	}

	void addCall(VrtsFunction source, string name) {
		if(source !in collector.callsPerFunctions) {
			collector.callsPerFunctions[source] = collector.FunctionCalls();
		}

		auto call = new VrtsFunctionCall(cast(uint)collector.storage.length, source, name);
		collector.storage.add(call);
		collector.callsPerFunctions[source].outgoing ~= call;
	}

	void relinkFunctionsCalls() {
        foreach(call; this.collector.storage.data) {
            foreach(func; collector.functionsCollector.storage.data) {
                if(!call.isDefined && call.getCallName == func.name) {
                    call.defineTarget(func);
					if(func !in collector.callsPerFunctions) {
						collector.callsPerFunctions[func] = collector.FunctionCalls();
					}
						
					collector.callsPerFunctions[func].ongoing ~= call;

                    break;
                }
            }
        }
    }
}