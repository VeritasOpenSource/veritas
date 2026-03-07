module veritas.ecosystem.functions.functionsCollector;

import veritas.ecosystem;
import veritas.ecosystem.sourceFiles;
import std.stdio;
import std.file;
import std.array;

import std.algorithm;
import std.conv;
import std.path;

import veritas.common.collector;
import veritas.ecosystem.packages;
import veritas.ipc.events;

class VrtsFunctionsCollector : VrtsCollector!VrtsFunction {
    VrtsEventBus eventBus;
    // VrtsEcosystem ecosystem;

    // VrtsSourceCollector sourceCollector;
    VrtsFunction[][VrtsSourceFile]    functionsPerFile;

    void setEventsBus(VrtsEventBus eventBus) {
        this.eventBus = eventBus;
    }

    // this(VrtsEcosystem ecosystem)

    uint getNewId() {
        return cast(uint)storage.length;
    }

    // void processFunctionsFromSourceFiles(VrtsFunction[] funcs) {
    //     funcs.each!(a => this.addFunction(a));
    // }

    bool checkFunctionEdentity(VrtsFunction func1, VrtsSourceFile sourceFile2, string name) {
        auto pathFile = func1.file.getPath.dirName;

        auto pathCheckingFile = sourceFile2.getPath().dirName;
        return  pathFile == pathCheckingFile &&
                 name == func1.name;
    }

}