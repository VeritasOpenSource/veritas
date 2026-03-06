module veritas.ecosystem.packages.packageCollector;

import veritas.ecosystem.packages.pkg;
import veritas.common.collector;
import veritas.ecosystem;

class VrtsPackagesCollector : VrtsCollector!VrtsPackage {
	VrtsEcosystem ecosystem;

	this(VrtsEcosystem ecosystem) {
		super();
		this.ecosystem = ecosystem;
	}

	void addPackage(VrtsPackage pkg) {
        storage.add(pkg);
	}
}