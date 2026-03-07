module veritas.ecosystem.calls.callsAnalyzer;

import std.string;
import std.path;
import std.algorithm;
import std.range;

import veritas.ipc;
import veritas.clang;
import veritas.ecosystem;
import veritas.common.collector;
import veritas.common.dataStorage;
import veritas.ecosystem.functions;
import veritas.ecosystem.calls;
import veritas.ecosystem.sourceFiles;
import veritas.common.toolkit;
import veritas.clang;
import veritas.ecosystem.packages;


class VrtsCallsAnalyzer {
	VrtsEventBus eventBus;

	VrtsCallsCollector	collector;

	// ref auto packages() inout @property {
	// 	return collector.storage.data;
	// }

	this(VrtsEcosystem ecosystem) {
        //No need ecosystem data here
		collector = new VrtsCallsCollector(ecosystem);
	}

	void setEventBus(VrtsEventBus eventBus) {
		this.eventBus = eventBus;
	}

	void relinkFunctionsCalls() {
        foreach(call; this.collector.storage.data) {
            foreach(func; collector.functionsCollector.storage.data) {
                if(!call.isDefined && call.getCallName == func.name) {
                    call.defineTarget(func);
                    func.calledBy ~= call;

                    break;
                }
            }
        }
    }
}