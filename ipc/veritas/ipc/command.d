module veritas.ipc.command;

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