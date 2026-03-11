module veritas.ecosystem.packages.packageCollector;

import veritas.ecosystem.packages.pkg;
import veritas.common.collector;

class VrtsPackagesCollector : VrtsStorage!VrtsPackage {
	void addPackage(VrtsPackage pkg) {
        storage.add(pkg);
	}
}