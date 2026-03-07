module veritas.ecosystem.packages.packageAnalyzer;

import veritas.ecosystem.ecosystem;
import veritas.ecosystem.packages;
import veritas.common.collector;
import veritas.common.analyzer;


class VrtsPackageAnalyzer : VrtsAnalyzer {

	VrtsPackagesCollector	collector;

	ref auto packages() inout @property {
		return collector.storage;
	}

	this(VrtsEcosystem ecosystem) {
        //No need ecosystem data here
		collector = new VrtsPackagesCollector();
	}

    void addPackage(string metadataPath) {
		auto md = VrtsMetaData.load(metadataPath);
		auto pkg = new VrtsPackage(cast(uint)collector.length, md);
        collector.addPackage(pkg);
	}
}