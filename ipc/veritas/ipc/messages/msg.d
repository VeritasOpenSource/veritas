module veritas.ipc.messages.msg;

enum MsgType {
	Command,
	Event,
	Request,
	Responce
}

struct VrtsIPCHeader {
    uint length;
    uint type;
    uint subType;
}

class VrtsIPCMessage {
	MsgType type;
}