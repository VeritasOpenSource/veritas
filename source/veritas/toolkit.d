module veritas.toolkit;

import veritas.ecosystem.sourceFile;
import veritas.ecosystem.func;
import veritas.ecosystem.call;
import veritas.callsCollector;
import veritas.functionsCollector;
import veritas.ecosystem.pkg;


abstract class VrtsToolkit {
	abstract void extractFunctionsFromSourceFile(VrtsFunctionsCollector collector, VrtsSourceFile sourceFile);
	abstract void extractCallsFromFunction(VrtsCallsCollector collector, VrtsFunction func);
	abstract void startStaticAnalyze(VrtsPackage pkg);
}