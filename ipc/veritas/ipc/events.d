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
        return "E addedPackage " ~ path ~ "\n";
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
        return "File analyzed: " ~ path ~ "\n";
    }

    override string compileString() {
        return "E fileAnalyzed " ~ path ~ "\n";
    }
}

class EventProjectSourceFilesProcess : VrtsEvent {
    uint percentage;

    override EventType getType() {
        return EventType.ProjectSourceFilesProcess;
    } 

    override string getString() {
        return "Processed: " ~ percentage.to!string ~ "\n";
    }

    override string compileString() {
        return "E percentage " ~ percentage.to!string ~ "\n";
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
        return "New ring: " ~ id.to!string ~ "\n";
    }

    override string compileString() {
        return "E newRing " ~ id.to!string ~ "\n";
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
        return "E addFuncToRing " ~ ringId.to!string ~ " " ~ funcName ~ "\n";
    }
}

class EventAddFunc : VrtsEvent {
    // uint ringId;
    string funcName;
    string packageName;
    uint ringId;

    this(uint id, string funcName, string packageName) {
        this.ringId = id;
        this.funcName = funcName;
        this.packageName = packageName;
    }

    override EventType getType() {
        return EventType.ProjectSourceFilesProcess;
    } 

    override string getString() {
        return "";
    }

    override string compileString() {
        return "E addFunc " ~ ringId.to!string ~ " " ~ funcName ~ " " ~ packageName ~ "\n";
    }
}