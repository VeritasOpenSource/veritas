import std.stdio;

import veritas.veritas;
import veritas.ipc.messages;
import veritas.ipc.ipc;
import veritas.ipc.server;

class VrtsLogger : VrtsEventHandler {
    override void processEvent(VrtsEvent event) {
        writeln(event.getString());
    }
}

class EventHandlerForClient : VrtsEventHandler {
    VrtsIPC ipc;

    this(VrtsIPC ipc) {
        this.ipc = ipc;
    }

    override void processEvent(VrtsEvent event) {
        ipc.sendMessage(event);
    }
}

void main(string[] args) {
    VrtsEventBus eventBus = new VrtsEventBus();
    eventBus.events ~= new VrtsLogger();

    VrtsIPCServer server = new VrtsIPCServer("/tmp/veritas.sock");
    eventBus.events ~= new EventHandlerForClient(server);

    Veritas veritas = new Veritas(eventBus, args);
    veritas.initAnalyzers();
    
    bool running = true;
    veritas.processCommand("add ../../veritas-test/bash.vmd");
    veritas.processCommand("analyze");

    while (running) {
        server.update();

        foreach(msg; server) {
            if(msg.type == MsgType.Command) {
                if(auto command = cast(VrtsCommand)msg) {
                    if(command.getType() == CommandType.Exit) {
                        running = false;
                    }
                    else if(command.getType == CommandType.Write) {
                        writeln((cast(CommandWrite)command).text);
                    }
                }
            }
            if(msg.type == MsgType.Request) {
                if(auto req = cast(VrtsRequest)msg) {
                    if(req.getType() == RequestType.GetPackagesList) {
                        auto res = veritas.getPackagesList;
                        server.sendMessage(res);
                    }
                }
            }
        }
    }


    // readln();
}