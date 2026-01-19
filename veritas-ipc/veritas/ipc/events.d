module veritas.ipc.events;

enum CommandType {
    AddProject
}

interface VrtsCommand {
    CommandType getType();
}

class ComAddProject : VrtsCommand {
    string path;

    override CommandType getType() {
        return CommandType.AddProject;
    }
}

enum EventType {
    ProjectAdded
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

