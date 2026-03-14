module veritas.ipc.messages.command;

import veritas.ipc.messages.msg;

import mir.deser.ion;

enum CommandType {
    Exit,
    Write
}

class VrtsCommand : VrtsIPCMessage {
    // CommandType type;
    @safe pure this() {
        super.type = MsgType.Command;
    }
    abstract CommandType getType();
}

class CommandWrite : VrtsCommand {
    string text;

    @safe pure this() {}

    void setText(string text) {
        this.text = text;
    }

    override CommandType getType() {
        return CommandType.Write;
    }
}

class CommandExit : VrtsCommand {
    @safe pure this() {}

    override CommandType getType() {
        return CommandType.Exit;
    }
}

VrtsCommand deserializeCommand(uint subType, ubyte[] payload)
{
    switch (cast(CommandType)subType)
    {
        case CommandType.Exit:
            return deserializeIon!CommandExit(payload); break;
        case CommandType.Write:
            return deserializeIon!CommandWrite(payload); break;
        default: break;
    }

    assert(0);
}