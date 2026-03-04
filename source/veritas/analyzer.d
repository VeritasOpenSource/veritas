module veritas.analyzer;

import veritas.dataStorage;


abstract class VrtsAnalyzer(VrtsEntity) {
	VrtsDataStorage!VrtsEntity storage;

	this() {
		storage = new VrtsDataStorage!VrtsEntity;
	}

	auto getStorage() {
		return storage;
	}
}