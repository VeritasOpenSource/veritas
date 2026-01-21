module veritas.ipc.events;

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

interface VrtsEvent {
    EventType getType();
}

class EventProjectAdded : VrtsEvent {
    string path;

    override EventType getType() {
        return EventType.ProjectAdded;
    } 
}

class EventSourceFileAnalized : VrtsEvent {
    string path;

    override EventType getType() {
        return EventType.SourceFileAnalized;
    } 
}

class EventProjectSourceFilesProcess : VrtsEvent {
    uint percentage;

    override EventType getType() {
        return EventType.ProjectSourceFilesProcess;
    } 
}