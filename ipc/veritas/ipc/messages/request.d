module veritas.ipc.messages.request;

import veritas.ipc.messages.msg;

enum VrtsRequestType {
    getPackagesList
}

class VrtsRequest : VrtsIPCMessage {
    VrtsRequestType type;
    this(VrtsRequestType type) { 
        this.type = VrtsRequestType.getPackagesList;
        super.type = MsgType.Request;
    }
}

class VrtsRequestGetPackageList {
    this() {
        limit = 10;
    }
    uint limit;
}

VrtsRequest deserializeRequest(uint subType, ubyte[] payload){
    return null;
    // final switch (cast(RequestType)subType)
    // {
    //     case RequestType.GetFunctions:
    //         return deserializeIon!RequestGetFunctions(payload);
    // }
}