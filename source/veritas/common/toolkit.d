module veritas.common.toolkit;

import veritas.ecosystem.sourceFiles;
import veritas.ecosystem.functions;
import veritas.ecosystem.calls;
// import veritas.callsCollector;
// import veritas.functionsCollector;
import veritas.ecosystem.packages;


abstract class VrtsToolkit {
	abstract void extractFunctionsFromSourceFile(VrtsFunctionsAnalyzer funcsAnalyzer, VrtsSourceFile sourceFile);
	abstract void extractCallsFromFunction(VrtsCallsCollector collector, VrtsFunction func);
	abstract void startStaticAnalyze(VrtsPackage pkg);
}