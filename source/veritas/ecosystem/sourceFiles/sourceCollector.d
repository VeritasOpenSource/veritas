module veritas.ecosystem.sourceFiles.sourceCollector;

import veritas.common.collector;
import veritas.ecosystem.ecosystem;
import veritas.ecosystem.sourceFiles;
import veritas.ecosystem.packages;

class VrtsSourceCollector : VrtsCollector!VrtsSourceFile {

    VrtsPackagesCollector packages;

    VrtsSourceFile[][VrtsPackage] filesPerPackage;

    this(VrtsEcosystem ecosystem) {
        this.packages = ecosystem.packageCollector;
    }
}