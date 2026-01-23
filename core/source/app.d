import veritas.veritas;

import std.stdio;
import std.socket;
import std.file;

import veritas.ipc.events;

class VrtsLogger : VrtsEventHandler {
    override void processEvent(VrtsEvent event) {
        writeln(event.getString());
    }
}

class ClientBus : VrtsEventHandler {
    Socket client;

    override void processEvent(VrtsEvent event) {
        client.send(event.compileString);
    }   
}

enum string SOCKET_PATH = "/tmp/veritas.sock"; 


void main(string[] args) {
    VrtsEventBus eventBus = new VrtsEventBus();
    Veritas veritas = new Veritas(eventBus);

    eventBus.events ~= new VrtsLogger;
    
    auto clientBus = new ClientBus;
    eventBus.events ~= clientBus;

    auto server = new Socket(AddressFamily.UNIX, SocketType.STREAM);

    if(exists(SOCKET_PATH))
        std.file.remove(SOCKET_PATH);

    auto addr = new UnixAddress(SOCKET_PATH);

    server.bind(addr);
    server.listen(10);
    bool exit = false;
    Socket client;

    while (!exit) {
        if (client is null) {
            client = server.accept();
            if (client !is null) {
                client.blocking = false;
            }

            clientBus.client = client;
        }

        if (client !is null) {
            exit = handleClient(veritas, client);
            if (exit)
                break;

            if (!client.isAlive) {
                client.close();
                client = null;
            }
        }
    }
}

bool handleClient(Veritas veritas, Socket client) {
    ubyte[1024] buf;

    while (true) {
        auto n = client.receive(buf[]);
        if (n > 0) {
            string command = cast(string)buf[0 .. n];
            if(command == "exit") {
                client.send("Shutdown...\n");
                return true;
            }
            // else(command == "getPackage")
            else 
                veritas.processCommand(command);
        }
            
    }

    return false;
}