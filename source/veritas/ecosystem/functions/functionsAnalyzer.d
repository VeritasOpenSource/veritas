module veritas.ecosystem.functions.functionsAnalyzer;

import std.algorithm;
import std.range;

import veritas.common.analyzer;
import veritas.ecosystem.ecosystem;
import veritas.ecosystem.functions;
import veritas.ecosystem.sourceFiles;

class VrtsFunctionsAnalyzer : VrtsAnalyzer {

	VrtsFunctionsCollector	collector;

	this(VrtsEcosystem ecosystem) {
		collector = new VrtsFunctionsCollector();
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