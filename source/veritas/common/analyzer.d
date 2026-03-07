module veritas.common.analyzer;

import veritas.ipc.events;

class VrtsAnalyzer {
	VrtsEventBus eventBus_;

	auto eventBus() inout @property {
		return eventBus_;
	}

	// void process();
}