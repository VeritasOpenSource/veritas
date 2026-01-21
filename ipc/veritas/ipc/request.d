module veritas.ipc.request;

enum Request {
    AddProject
}

interface VrtsRequest {
    Request getType();
}