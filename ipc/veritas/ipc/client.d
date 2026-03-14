module veritas.ipc.client;

import std.socket;

import veritas.ipc.ipc;
import veritas.ipc.messages;

class VrtsIPCClient : VrtsIPC {
    this(string path) {
        auto s = new Socket(
            AddressFamily.UNIX,
            SocketType.STREAM
        );

        s.connect(new UnixAddress(path));

        super(s);
    }

    protected override VrtsIPCMessage deserializeMessage(
        uint type,
        uint subType,
        ubyte[] payload
    ) {
        import veritas.ipc.messages.events;
        import veritas.ipc.messages.response;

        switch(cast(MsgType)type) {
            // case MsgType.Event:
            //     return deserializeEvent(subType, payload);

            // case MsgType.Response:
            //     return deserializeResponse(subType, payload);

            default:
                throw new Exception("Invalid message for client");
        }
    }
}