import veritas.veritas;
import veritas.ecosystem.ring;
import veritas.ecosystem.ecosystem;


import std.stdio;
import std.path;
import std.socket;
import std.file;
import std.algorithm;
import std.array;

import veritas.ipc.events;
import veritas.model;
import mir.ser.ion;
import std.base64;

class VrtsLogger : VrtsEventHandler {
    override void processEvent(VrtsEvent event) {
        writeln(event.getString());
    }
}

class ClientBus : VrtsEventHandler {
    Socket client;
    bool snapshot = false;
    string[] raws;

    override void processEvent(VrtsEvent event) {

        if(snapshot) {
            raws ~= event.compileString ~ "|";
        }
        else
            sendAll(cast(ubyte[])(event.compileString() ~ "|")); 
    }  

    void flush() {
        string res = raws.join;
        sendAll(cast(ubyte[])res);
        raws = [];
    }

    void sendRaw(const(ubyte)[] data) {
        uint len = cast(uint)data.length;
        sendAll((cast(ubyte*)&len)[0 .. uint.sizeof]);
        sendAll(data);
    }

    void sendAll(const(ubyte)[] data) {
        size_t sent = 0;

        while (sent < data.length) {
            auto n = client.send(data[sent .. $]);
            if (n <= 0)
                throw new Exception("Socket send failed");

            sent += n;
        }
    }

    ubyte[] receiveRaw() {
        ubyte[4] lenBuf;
        receiveAll(lenBuf[]);

        uint beLen = *cast(uint*)lenBuf.ptr;

        auto buffer = new ubyte[beLen];
        receiveAll(buffer);

        return buffer;
    }

    void receiveAll(ubyte[] buffer) {
        size_t received = 0;

        while (received < buffer.length) {
            auto n = client.receive(buffer[received .. $]);
            if (n <= 0)
                throw new Exception("Socket receive failed");

            received += n;
        }
    }
}


struct ClientState {
    Socket socket;
    bool exit;

    @property bool isDisconnected() {
        return socket is null;
    }

    void disconnect() {
        socket.shutdown(SocketShutdown.BOTH);
        socket.close();
        socket = null;
    }
}

enum string SOCKET_PATH = "/tmp/veritas.sock"; 

void main(string[] args) {
    VrtsEventBus eventBus = new VrtsEventBus();
    Veritas veritas = new Veritas(eventBus, args);

    eventBus.events ~= new VrtsLogger;
    
    auto clientBus = new ClientBus;

    auto server = new Socket(AddressFamily.UNIX, SocketType.STREAM);
    server.blocking = false;

    if(exists(SOCKET_PATH))
        std.file.remove(SOCKET_PATH);

    auto addr = new UnixAddress(SOCKET_PATH);

    server.bind(addr);
    server.listen(10);
    bool exit = false;
    ClientState client;

    while (!client.exit) {
        if (client.isDisconnected) {
            try {
                client.socket = server.accept();
                writeln("client is connected");
            }
            catch(SocketException e) {}

            if (!client.isDisconnected) {
                clientBus.client = client.socket;

                clientBus.snapshot = true;

                auto model = veritas.ecosystem.buildModel;
                auto ser = serializeIon(model);
                clientBus.processEvent(new EventSnapshotStart(Base64.encode(ser)));
                clientBus.flush();
                client.socket.blocking = false;

                clientBus.snapshot = false;
            }
        }

        if (!client.isDisconnected) {
            if(handleClient(veritas, client)) {
                client.disconnect();
                clientBus.client = null;
            }
        }
    }
}

bool handleClient(Veritas veritas, ref ClientState client) {
    ubyte[1024] buf;

    while(true) {
        auto n = client.socket.receive(buf[]);
        if (n > 0) {
            string command = cast(string)buf[0 .. n];
            if(command == "exit") {
                client.exit = true;
            }
            else 
                veritas.processCommand(command);
        }
        else if(n == 0) {
            return true;
        }
    }

    return false;
}