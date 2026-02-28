module veritas.ecosystem.sourceAnalyzer;

import veritas.ecosystem;
import veritas.sourceVisitor;
import std.stdio;
import std.file;
import std.array;

import std.algorithm;
import std.conv;

import veritas.ipc.events;

class VrtsSourceAnalyzer {
    VrtsEventBus eventBus;
    VrtsEcosystem ecosystem;
    VrtsSourceVisitor visitor;

    struct PkgSourceAssoc {
        VrtsPackage pkg;
        VrtsSourceFile[] file;
    }

    PkgSourceAssoc[] sourceFiles;

    void setEventsBus(VrtsEventBus eventBus) {
        this.eventBus = eventBus;
    }

    this(VrtsEcosystem ecosystem) {
        this.ecosystem = ecosystem;
        this.visitor = new VrtsSourceVisitor;
    }

    VrtsSourceFile[] processSourceFiles(VrtsPackage pkg, string[] sources) {
        auto assoc = PkgSourceAssoc(pkg);

        auto dirs = sources.
            map!(a => DirEntry(a));

        foreach(dir; dirs) {
            assoc.file ~= new VrtsSourceFile(pkg, dir);
        }
        
        return assoc.file;
    }

    void analyzeSourceFiles(ref VrtsSourceFile[] sources) {
        foreach(ref source; sources) {
		    visitor.visitSourceFile(ecosystem, source);
	    }
    }

    void analyzeSourceFilesByPackages(ref VrtsPackage[] packages) {
        foreach(package_; packages) {
            int i = 0;
            foreach(ref source; package_.getSourceFiles) {
                visitor.visitSourceFile(ecosystem, source);
                eventBus.publish(new EventSourceFileAnalized(source.getPath));
            }
        }
    }
}