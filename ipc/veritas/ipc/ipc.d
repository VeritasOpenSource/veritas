module veritas.ipc.ipc;

import mir.ser.ion;
import mir.deser.ion;
import std.stdio;

import std.socket;
import veritas.ipc.messages;
import veritas.ipc.connection;

abstract class VrtsIPC : VrtsIPCConnection {
    VrtsIPCMessage[] messages;

    this(Socket s) {
        super(s);
    }

    void update()
    {
        readSocket();

        while(true) {
            if(readBuffer.length < VrtsIPCHeader.sizeof)
                break;

            auto header = *cast(VrtsIPCHeader*)readBuffer.ptr;

            auto total = VrtsIPCHeader.sizeof + header.length;

            if(readBuffer.length < total)
                break;

            auto payload = readBuffer[
                VrtsIPCHeader.sizeof .. total
            ];

            auto msg = deserializeMessage(
                header.type,
                header.subType,
                payload
            );

            messages ~= msg;

            readBuffer = readBuffer[total .. $];
        }

        flush();
    }
    
    void buildAndSendMsg(VrtsIPCMessage msg, inout ubyte[] payload) {
        VrtsIPCHeader header;

        header.length  = cast(uint)payload.length;
        header.type    = cast(ushort)msg.type;

        switch(msg.type) {
            case MsgType.Command:
                header.subType =
                    (cast(VrtsCommand)msg).getType(); break;
            default: break;

            // case MsgType.Request:
            //     header.subType =
            //         (cast(VrtsRequest)msg).getType();

            // case MsgType.Response:
            //     header.subType =
            //         (cast(VrtsResponse)msg).getType();

            // case MsgType.Event:
            //     header.subType =
                    // (cast(VrtsEvent)msg).getType();
        }

        writeBuffer ~= (cast(ubyte*)&header)[0 .. VrtsIPCHeader.sizeof];
        writeBuffer ~= payload;
    }
    void sendMessage(T)(T msg) {
        auto payload = serializeIon(msg);

        buildAndSendMsg(msg, payload);
    }

    protected abstract VrtsIPCMessage deserializeMessage(
        uint type,
        uint subType,
        ubyte[] payload
    );

    bool empty() {
        return messages.length == 0;
    }

    VrtsIPCMessage front() {
        return messages[0];
    }

    void popFront() {
        messages = messages[1..$];
    }
}