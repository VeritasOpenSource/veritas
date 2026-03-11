module veritas.common.collector;

import veritas.common.dataStorage;

abstract class VrtsStorage(VrtsEntity) {
	VrtsDataStorage!VrtsEntity storage;

	this() {
		storage = new VrtsDataStorage!VrtsEntity;
	}

	auto getStorage() {
		return storage;
	}

	auto length() inout @property {
		return storage.length;
	}
}