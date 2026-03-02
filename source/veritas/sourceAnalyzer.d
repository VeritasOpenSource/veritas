module veritas.sourceAnalyzer;

import std.string;
import std.path;

import veritas.clang;
import veritas.ecosystem;
import veritas.analyzer;
import veritas.dataProvider;
import veritas.functionsCollector;
import veritas.callsCollector;
import veritas.sourceCollector;
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