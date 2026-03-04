module veritas.ecosystem.sourceFiles.sourceCollector;

import veritas.ecosystem;
// import veritas.source;
import std.stdio;
import std.file;
import std.array;

import std.algorithm;
import std.conv;

import veritas.collector;
import veritas.ecosystem.packages;
import veritas.ipc.events;

class VrtsSourceCollector : VrtsCollector!VrtsSourceFile {
    VrtsEventBus eventBus;
    VrtsEcosystem ecosystem;
    VrtsSourceAnalyzer visitor;

    struct PkgSourceAssoc {
        VrtsPackage pkg;
        VrtsSourceFile[] file;
    }

    PkgSourceAssoc[] associatedFiles;

    void setEventsBus(VrtsEventBus eventBus) {
        this.eventBus = eventBus;
    }

    this(VrtsEcosystem ecosystem) {
        this.ecosystem = ecosystem;
        // this.visitor = new VrtsSourceVisito;
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

    string[] preparePackageSourceFiles(VrtsPackage pkg) {
        auto sp = new VrtsSourcePreparing();
        // sp.preparePackage(pkg.getMetadata);
        // sp.pseudoMake();
        return sp.getSourceFilesPaths(pkg.getMetadata);
    }

    void analyzePackage(VrtsPackage pkg) {
        string[] filesNames = preparePackageSourceFiles(pkg);
        this.storage.add(processSourceFiles(pkg, filesNames));
    }

    void collectAllSourceFiles() {
        foreach(pkg; ecosystem.packagesStorage.data) {
            analyzePackage(pkg);
        }
    }
}