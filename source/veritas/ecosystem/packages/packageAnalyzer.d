module veritas.ecosystem.packages.packageAnalyzer;

import std.string;
import std.path;

import veritas.ipc;
import veritas.clang;
import veritas.ecosystem;
import veritas.common.collector;
import veritas.common.dataStorage;
import veritas.ecosystem.functions;
import veritas.ecosystem.calls;
import veritas.ecosystem.sourceFiles;
import veritas.common.toolkit;
import veritas.clang;
import veritas.ecosystem.packages;


class VrtsPackageAnalyzer {
	VrtsEventBus eventBus;

	VrtsPackagesCollector	collector;

	ref auto packages() inout @property {
		return collector.storage.data;
	}

	this(VrtsEcosystem ecosystem) {
        //No need ecosystem data here
		collector = new VrtsPackagesCollector(null);
	}

	void setEventBus(VrtsEventBus eventBus) {
		this.eventBus = eventBus;
	}

    void addPackage(string metadataPath) {
		auto md = VrtsMetaData.load(metadataPath);
		auto pkg = new VrtsPackage(cast(uint)collector.length, md);
        collector.addPackage(pkg);
	}
}