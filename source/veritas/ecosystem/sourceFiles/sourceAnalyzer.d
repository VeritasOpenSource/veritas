module veritas.ecosystem.sourceFiles.sourceAnalyzer;

import std.string;
import std.path;

import veritas.clang;
import veritas.ecosystem;
import veritas.common.collector;
import veritas.common.dataStorage;
import veritas.ecosystem.functions;
import veritas.ecosystem.calls;
import veritas.ecosystem.sourceFiles;
import veritas.common.toolkit;
import veritas.clang;

class VrtsSourceAnalyzer {
    VrtsToolkit toolkit;

    VrtsSourceCollector     sourceCollector;

    VrtsFunctionsAnalyzer  functionsAnalyzer;
    VrtsCallsCollector      callsCollector;

    // VrtsSourceFile sourceFileContext;
    // VrtsFunction funcContext;

    this(
        VrtsSourceCollector collector,
        VrtsFunctionsAnalyzer functionsAnalyzer,
        VrtsCallsCollector callsCollector
    ) {
        this.toolkit = new ClangToolkit();
        this.sourceCollector = collector;
        this.functionsAnalyzer = functionsAnalyzer;
        this.callsCollector = callsCollector;
    }

    void collectAllFunctions() {
        foreach(sourceFile; sourceCollector.storage.data) {
            toolkit.extractFunctionsFromSourceFile(functionsAnalyzer, sourceFile);
        }
    }

    void collectAllCalls() {
        foreach(func; functionsAnalyzer.collector.storage.data) {
            toolkit.extractCallsFromFunction(callsCollector, func);
        }
    }
}