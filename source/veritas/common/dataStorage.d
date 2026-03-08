module veritas.common.dataStorage;

import std.algorithm;
import std.array;

class VrtsDataStorage(VrtsType) {
	VrtsType[] 	data;

	auto add(VrtsType[] element...) {
		data ~= element;
		return this;
	}

	auto remove(VrtsType[] element...) {
		foreach(e; element) {
			data = data.filter!(a => a !is e).array;
		}
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

	auto range() {
		struct Range {
			VrtsType[] data;

			void popFront() {
				data = data[1..$];
			}

			auto front() => data[0];
			bool empty() => data.length == 0;
		}

		return Range(data);
	}
}