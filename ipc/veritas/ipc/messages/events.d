module veritas.ipc.messages.events;

import std.algorithm;
import std.conv;

import veritas.ipc.messages.msg;

class VrtsEvent : VrtsIPCMessage {
    @safe pure this() {
        super.type = MsgType.Event;
    }

    string getString() {
        return "none";
    }

    auto getType() {
        return EventType.None;
    }
}

class VrtsEventHandler {
    abstract void processEvent(VrtsEvent event);
}

class VrtsEventBus {
    VrtsEventHandler[] events;

    void publish(VrtsEvent event) {
        events.each!(a => a.processEvent(event));
    }
}

enum IPCState {
    Ready,
    Processing,
    Waiting
}

enum EventType {
    None,
    ProjectAdded,
    SourceFileAnalized,
    ProjectSourceFilesProcess
}


