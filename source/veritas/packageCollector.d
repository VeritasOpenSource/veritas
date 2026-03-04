module veritas.packageCollector;

import veritas.ecosystem.pkg;
import veritas.collector;
import veritas.ecosystem;

class VrtsPackageCollector : VrtsCollector!VrtsPackage {
	VrtsEcosystem ecosystem;

	this(VrtsEcosystem ecosystem) {
		this.ecosystem = ecosystem;
	}

	void addPackage(string metadataPath) {
		auto md = VrtsMetaData.load(metadataPath);
		auto pkg = new VrtsPackage(cast(uint)storage.length, md);
        storage.add(pkg);
        // packages ~= pkg;

        // eventBus.publish(new EventProjectAdded(pkg.getPath));
	}
}