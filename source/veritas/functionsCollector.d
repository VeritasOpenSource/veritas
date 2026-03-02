module veritas.functionsCollector;

// module veritas.ecosystem.sourceAnalyzer;

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

    struct FunctionSourceAssoc {
        VrtsFunction function_;
        VrtsSourceFile file;
    }

    // VrtsSourceFile[]
    FunctionSourceAssoc[] associatedFunctions;

    void setEventsBus(VrtsEventBus eventBus) {
        this.eventBus = eventBus;
    }

    this(	VrtsEcosystem ecosystem,
			VrtsSourceCollector collector) {
        this.ecosystem = ecosystem;
		this.sourceCollector = collector; 
        // this.visitor = new VrtsSourceVisitor;
    }

    uint getNewId() {
        return cast(uint)storage.length;
    }

    bool checkFunctionEdentity(VrtsFunction func1, VrtsSourceFile sourceFile2, string name) {
        auto pathFile = associatedFunctions.find!(a => a.function_ is func1).front.file.getPath.dirName;
        // auto pathFile = func1.file.getPath.dirName;

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
            auto assoc = FunctionSourceAssoc(def, sourceFile);
            associatedFunctions ~= assoc;
            storage.add(def);
            // def.file = sourceFile;
            // functions ~= def; 
            // sourceFile.getPackage().addFunction(def);
        }
        else {
            def = storage.data.front();
            auto assoc = FunctionSourceAssoc(def, sourceFile);
            associatedFunctions ~= assoc;
            // def.file = sourceFile;
        }

        return def;
    }

}