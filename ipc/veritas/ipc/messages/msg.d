module veritas.ipc.messages.msg;

enum MsgType {
	Command,
	Event,
	Request,
	Response
}

struct VrtsIPCHeader {
    uint length;
    uint type;
    uint subType;
}

class VrtsIPCMessage {
	MsgType type;
}