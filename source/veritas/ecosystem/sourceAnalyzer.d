module veritas.ecosystem.sourceAnalyzer;

import veritas.ecosystem;
import veritas.sourceVisitor;
import std.stdio;


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

    void analyzeSourceFilesByPackages(ref VrtsPackage[] packages) {
        foreach(package_; packages) {
            // writeln("Scanning package:", package_.getName);
            // ulong size = package_.getSourceFiles.length;
            // writeln("Sources count:", package_.getSourceFiles.length);

            int i = 0;
            foreach(ref source; package_.getSourceFiles) {
                // writeln(" (", i, "/", size, ")      Scanning source file: ", source.getPath);
                visitor.visitSourceFile(ecosystem, source);
                // stdout.flush();

                // write("\033[1A");   
                // write("\033[2K");   
                // i++;
            }
        }
    }
}