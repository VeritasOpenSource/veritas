module veritas.ecosystem.functions.functionsCollector;

// import std.stdio;
import std.file;
// import std.array;
// import std.algorithm;
// import std.conv;
import std.path;

import veritas.ecosystem.functions;
import veritas.ecosystem.sourceFiles;
import veritas.common.collector;
// import veritas.ecosystem.packages;
// import veritas.ipc.events;

class VrtsFunctionsCollector : VrtsCollector!VrtsFunction {

    VrtsFunction[][VrtsSourceFile]    functionsPerFile;

    uint getNewId() {
        return cast(uint)storage.length;
    }

    bool checkFunctionEdentity(VrtsFunction func1, VrtsSourceFile sourceFile2, string name) {
        auto pathFile = func1.file.getPath.dirName;

        auto pathCheckingFile = sourceFile2.getPath().dirName;
        return  pathFile == pathCheckingFile &&
                 name == func1.name;
    }

}