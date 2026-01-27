import veritas.veritas;
import veritas.ecosystem.ring;

import std.stdio;
import std.path;
import std.socket;
import std.file;
import std.algorithm;
import std.array;

import veritas.ipc.events;

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
            client.send(event.compileString() ~ "|"); 
    }  

    void flush() {
        string res = raws.join;
        client.send(res);
        raws = [];
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
    Veritas veritas = new Veritas(eventBus);

    eventBus.events ~= new VrtsLogger;
    
    auto clientBus = new ClientBus;
    // eventBus.events ~= clientBus;

    auto server = new Socket(AddressFamily.UNIX, SocketType.STREAM);
    server.blocking = false;

    if(exists(SOCKET_PATH))
        std.file.remove(SOCKET_PATH);

    auto addr = new UnixAddress(SOCKET_PATH);

    server.bind(addr);
    server.listen(10);
    bool exit = false;
    ClientState client;


    // veritas.processCommand("add ../../veritas-test/bash");
    // writeln("Added");
    // veritas.processCommand("analyze");

    // auto funcCount = veritas.ecosystem.functions.length;
    // // auto trigCount = veritas.ecosystem.collectTriggers;
    // int sum;
    // auto trigCount = veritas.ecosystem.triggers.each!(a => sum += a.count);

    // writeln("Func count: ", funcCount);
    // writeln("Trig count: ", sum);
    // writeln("Validity: ", funcCount / sum);
    // veritas.processCommand()

    while (!client.exit) {
        if (client.isDisconnected) {
            try {
                client.socket = server.accept();
            }
            catch(SocketException e) {}

            if (!client.isDisconnected) {
                client.socket.blocking = false;
                clientBus.client = client.socket;

                clientBus.snapshot = true;

                clientBus.processEvent(new EventSnapshotStart());

                foreach (i, pkg; veritas.ecosystem.packages) {     
                    clientBus.processEvent(new EventProjectAdded(pkg.getPath.baseName));
                }

                foreach (i, ring; veritas.ecosystem.rings) { 
                    clientBus.processEvent(new EventAddRing(ring.level));
                }

                foreach (ring; veritas.ecosystem.rings) {
                    foreach(func; ring.functions) {
                        auto e = new EventSendFunc(func.name, 0, ring.level);
                        clientBus.processEvent(new EventSendFunc(func.name, 0, ring.level));
                    }
                }

                clientBus.processEvent(new EventSnapshotEnd());

                clientBus.snapshot = false;
                clientBus.flush();
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