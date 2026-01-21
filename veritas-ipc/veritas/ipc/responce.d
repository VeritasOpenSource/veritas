module veritas.ipc.responce;

enum Responce {
    AddProject
}

interface VrtsResponce {
    Responce getType();
}