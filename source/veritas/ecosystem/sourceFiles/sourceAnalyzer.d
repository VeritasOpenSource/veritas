module veritas.ecosystem.sourceFiles.sourceAnalyzer;

import std.string;
import std.path;

import veritas.clang;
import veritas.ecosystem;
import veritas.collector;
import veritas.dataStorage;
import veritas.ecosystem.functions;
import veritas.ecosystem.calls;
import veritas.ecosystem.sourceFiles;
import veritas.toolkit;
import veritas.clang;

class VrtsSourceAnalyzer {
    VrtsToolkit toolkit;

    VrtsSourceCollector     sourceCollector;
    VrtsFunctionsCollector  functionCollector;
    VrtsCallsCollector      callsCollector;

    // VrtsSourceFile sourceFileContext;
    // VrtsFunction funcContext;

    this(
        VrtsSourceCollector collector,
        VrtsFunctionsCollector functionCollector,
        VrtsCallsCollector callsCollector
    ) {
        this.toolkit = new ClangToolkit();
        this.sourceCollector = collector;
        this.functionCollector = functionCollector;
        this.callsCollector = callsCollector;
    }

    void collectAllFunctions() {
        foreach(sourceFile; sourceCollector.storage.data) {
            toolkit.extractFunctionsFromSourceFile(functionCollector, sourceFile);
        }
    }

    void collectAllCalls() {
        foreach(func; functionCollector.storage.data) {
            toolkit.extractCallsFromFunction(callsCollector, func);
        }
    }
}