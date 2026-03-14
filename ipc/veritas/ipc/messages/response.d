module veritas.ipc.messages.response;

import mir.deser.ion;
import veritas.ipc.messages.msg;

enum ResponseType {
    PackageList
}

class VrtsResponse : VrtsIPCMessage {
    ResponseType responseType;

    @safe pure this() {
        super.type = MsgType.Response;
    }

    ResponseType getType() {
        return responseType;
    }
}

class VrtsResponsePackagesList : VrtsResponse {
    string[] packagesList;
    @safe pure this() {
        this.responseType = ResponseType.PackageList;
    }
}

VrtsResponse deserializeResponse(uint subType, ubyte[] payload){
    switch (cast(ResponseType)subType)
    {
        case ResponseType.PackageList:
            return deserializeIon!VrtsResponsePackagesList(payload); break;
        default:
            break;
    }
    assert(0);
}