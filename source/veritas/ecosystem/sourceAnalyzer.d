module veritas.ecosystem.sourceAnalyzer;

import veritas.ecosystem;
import veritas.sourceVisitor;

class VrtsSourceAnalyzer {
    VrtsEcosystem ecosystem;
    VrtsSourceVisitor visitor;

    this(VrtsEcosystem ecosystem) {
        this.ecosystem = ecosystem;
        this.visitor = new VrtsSourceVisitor;
    }

    void analyzeSourceFiles(ref VrtsSourceFile[] sources) {
        foreach(ref source; sources) {
		    visitor.visitSourceFile(ecosystem, source);
	    }
    }
}