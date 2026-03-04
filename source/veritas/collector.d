module veritas.collector;

import veritas.dataStorage;


abstract class VrtsCollector(VrtsEntity) {
	VrtsDataStorage!VrtsEntity storage;

	this() {
		storage = new VrtsDataStorage!VrtsEntity;
	}

	auto getStorage() {
		return storage;
	}
}