module veritas.ipc.server;

import std.socket;
import std.file;

import std.stdio;

import veritas.ipc.ipc;
import veritas.ipc.messages;

class VrtsIPCServer : VrtsIPC {
    private Socket server;
    Socket client;

    this(string path) {   
        if (exists(path))
            remove(path);

        server = new Socket(
            AddressFamily.UNIX,
            SocketType.STREAM
        );

        super(server);

        server.bind(new UnixAddress(path));
        server.listen(1);

        server.blocking = false;
    }

    void acceptClient() {
        if (client !is null)
            return;

        try {
            client = server.accept();

            client.blocking = false;

            socket = client;
        }
        catch(SocketException) {
            if (wouldHaveBlocked())
                return;

        }
    }

    override void update() {
        acceptClient();

        if (socket is null)
            return;

        super.update();
    }

    protected override VrtsIPCMessage deserializeMessage(
        uint type,
        uint subType,
        ubyte[] payload
    ) {
        import veritas.ipc.messages.command;
        import veritas.ipc.messages.request;

        switch(cast(MsgType)type)
        {
            case MsgType.Command:
                return deserializeCommand(subType, payload); break;
            default:
                
                break;

            // case MsgType.Request:
            //     return deserializeRequest(subType, payload);

            // default:
            //     throw new Exception("Invalid message for server");
        }

        assert(0);
    }
}