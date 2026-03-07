module veritas.ecosystem.sourceFiles.sourceCollector;

import veritas.ecosystem;
// import veritas.source;
import std.stdio;
import std.file;
import std.array;

import std.algorithm;
import std.conv;

import veritas.common.collector;
import veritas.ecosystem.packages;
import veritas.ipc.events;

class VrtsSourceCollector : VrtsCollector!VrtsSourceFile {

    VrtsPackagesCollector packages;
    // VrtsSourceAnalyzer visitor;

    struct PkgSourceAssoc {
        VrtsPackage pkg;
        VrtsSourceFile[] file;
    }

    PkgSourceAssoc[] associatedFiles;

    this(VrtsEcosystem ecosystem) {
        this.packages = ecosystem.packageCollector;
    }
}