module veritas.common.dataStorage;

import std.algorithm;
import std.functional;
import std.array;

class VrtsDataStorage(VrtsType) {
	VrtsType[] 	data;

	auto add(VrtsType[] element...) {
		data ~= element;
		return this;
	}

	auto remove(VrtsType element) {
		data = data.filter!(a => a !is element).array;
		return this;
	}

	auto rebuildIds() {
		uint id = 0;
		data.each!((ref a) => a.setId(id++));
		return this;
	}

	ref auto opIndex(size_t index) {
		return data[index];
	}

	auto length() const @property {
		return data.length;
	}
}