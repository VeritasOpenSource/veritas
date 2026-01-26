module veritas.ipc.events;

import std.algorithm;
import std.conv;

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
    ProjectAdded,
    SourceFileAnalized,
    ProjectSourceFilesProcess
}


class EventSnapshotStart : VrtsEvent {
    // string name;

    override EventType getType() {
        return EventType.ProjectAdded;
    }

    string getString() {return "";}

    string compileString() {
        return "E snapshotStart";
    }
}

class EventSnapshotEnd : VrtsEvent {
    // string name;

    override EventType getType() {
        return EventType.ProjectAdded;
    }

    string getString() {return "";}

    string compileString() {
        return "E snapshotEnd";
    }
}
interface VrtsEvent {
    EventType getType();

    string getString();

    string compileString();
}

class EventProjectAdded : VrtsEvent {
    this(string path) {
        this.path = path;
    }

    string path;

    override EventType getType() {
        return EventType.ProjectAdded;
    } 

    override string getString() {
        return "Added project: " ~ path;
    }

    override string compileString() {
        return "E addedPackage " ~ path;
    }
}

class EventSourceFileAnalized : VrtsEvent {
    string path;

    this(string path) {
        this.path = path;
    }

    override EventType getType() {
        return EventType.SourceFileAnalized;
    } 

    override string getString() {
        return "File analyzed: " ~ path;
    }

    override string compileString() {
        return "E fileAnalyzed " ~ path;
    }
}

class EventProjectSourceFilesProcess : VrtsEvent {
    uint percentage;

    override EventType getType() {
        return EventType.ProjectSourceFilesProcess;
    } 

    override string getString() {
        return "Processed: " ~ percentage.to!string;
    }

    override string compileString() {
        return "E percentage " ~ percentage.to!string;
    }
}

class EventAddRing : VrtsEvent {
    uint id;

    this(uint id) {
        this.id = id;
    }

    override EventType getType() {
        return EventType.ProjectSourceFilesProcess;
    } 

    override string getString() {
        return "New ring: " ~ id.to!string;
    }

    override string compileString() {
        return "E newRing " ~ id.to!string;
    }
}

class EventFuncToRing : VrtsEvent {
    uint ringId;
    string funcName;

    this(uint id, string funcName) {
        this.ringId = id;
        this.funcName = funcName;
    }

    override EventType getType() {
        return EventType.ProjectSourceFilesProcess;
    } 

    override string getString() {
        return "";
    }

    override string compileString() {
        return "E addFuncToRing " ~ ringId.to!string ~ " " ~ funcName;
    }
}

class EventSendFunc : VrtsEvent {
    // uint ringId;
    string funcName;
    uint localId;
    // string packageName;
    uint ringId;

    this(string funcName, uint id, uint ringId) {
        this.ringId = ringId;
        this.localId = id;
        this.funcName = funcName;
        // this.packageName = packageName;
    }

    override EventType getType() {
        return EventType.ProjectSourceFilesProcess;
    } 

    override string getString() {
        return "";
    }

    override string compileString() {
        return "E sendFunc " ~ funcName ~ " "~ localId.to!string ~" " ~ ringId.to!string;
    }
}