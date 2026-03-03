module veritas.functionsCollector;

import veritas.ecosystem;
import veritas.sourceCollector;
import std.stdio;
import std.file;
import std.array;

import std.algorithm;
import std.conv;
import std.path;

import veritas.analyzer;
import veritas.preparing;
import veritas.ipc.events;

class VrtsFunctionsCollector : VrtsAnalyzer!VrtsFunction {
    VrtsEventBus eventBus;
    VrtsEcosystem ecosystem;
    VrtsSourceCollector sourceCollector;

    VrtsSourceFile[VrtsFunction]    associatedFunctions;

    void setEventsBus(VrtsEventBus eventBus) {
        this.eventBus = eventBus;
    }

    this(	VrtsEcosystem ecosystem,
			VrtsSourceCollector collector) {
        this.ecosystem = ecosystem;
		this.sourceCollector = collector; 
    }

    uint getNewId() {
        return cast(uint)storage.length;
    }

    // void processFunctionsFromSourceFiles(VrtsFunction[] funcs) {
    //     funcs.each!(a => this.addFunction(a));
    // }

    bool checkFunctionEdentity(VrtsFunction func1, VrtsSourceFile sourceFile2, string name) {
        auto pathFile = associatedFunctions[func1].getPath.dirName;

        auto pathCheckingFile = sourceFile2.getPath().dirName;
        return  pathFile == pathCheckingFile &&
                 name == func1.name;
    }

    VrtsFunction addFunction(VrtsSourceFile sourceFile, string name) {
        auto func = storage.data
            .find!((a) => checkFunctionEdentity(a, sourceFile, name));

        VrtsFunction def;

        if(func.empty) { 
            def = new VrtsFunction(getNewId(), name); 
            associatedFunctions[def] = sourceFile;
            storage.add(def);
        }
        else {
            def = storage.data.front();
            associatedFunctions[def] = sourceFile;
        }

        return def;
    }

}