module veritas.ipc.responce;

enum Responce {
    ProjectList
}

interface VrtsResponce {
    Responce getType();
}