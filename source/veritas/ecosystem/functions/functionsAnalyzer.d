module veritas.ecosystem.functions.functionsAnalyzer;

import std.string;
import std.path;
import std.algorithm;
import std.range;
import std.array;

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


class VrtsFunctionsAnalyzer {
	VrtsEventBus eventBus;

	VrtsFunctionsCollector	collector;

	// ref auto packages() inout @property {
	// 	return collector.storage.data;
	// }

	this(VrtsEcosystem ecosystem) {
        //No need ecosystem data here
		collector = new VrtsFunctionsCollector();
	}

	void setEventBus(VrtsEventBus eventBus) {
		this.eventBus = eventBus;
	}

	VrtsFunction addFunction(VrtsSourceFile sourceFile, string name) {
		auto func = collector.storage.data
			.find!((a) => collector.checkFunctionEdentity(a, sourceFile, name));

		VrtsFunction def;

		if(func.empty) { 
			def = new VrtsFunction(collector.getNewId(), name); 
			def.file = sourceFile;
			collector.functionsPerFile[sourceFile] ~= def;
			collector.storage.add(def);
		}
		else {
			def = collector.storage.data.front();
			def.file = sourceFile;
			collector.functionsPerFile[sourceFile] ~= def;
		}

		return def;
	}
}