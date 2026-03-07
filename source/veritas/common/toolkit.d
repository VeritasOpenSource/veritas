module veritas.common.toolkit;

import veritas.ecosystem.sourceFiles : VrtsSourceFile;
import veritas.ecosystem.functions :
	VrtsFunctionsAnalyzer,
	VrtsFunction;
import veritas.ecosystem.calls : VrtsCallsAnalyzer;
import veritas.ecosystem.packages : VrtsPackage;

abstract class VrtsToolkit {
	abstract void extractFunctionsFromSourceFile(VrtsFunctionsAnalyzer funcsAnalyzer, VrtsSourceFile sourceFile);
	abstract void extractCallsFromFunction(VrtsCallsAnalyzer analyzer, VrtsFunction func);
	abstract void startStaticAnalyze(VrtsPackage pkg);
}