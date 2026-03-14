module veritas.ipc.messages.request;

import veritas.ipc.messages.msg;

import mir.deser.ion;

enum RequestType {
    GetPackagesList
}

class VrtsRequest : VrtsIPCMessage {
    RequestType type;
    @safe pure this(RequestType type) { 
        this.type = RequestType.GetPackagesList;
        super.type = MsgType.Request;
    }

    auto getType() {
        return type;
    }
}

class VrtsRequestGetPackageList : VrtsRequest {
    // RequestType type = 

    @safe pure this() {
        super(RequestType.GetPackagesList);
        // this.type = RequestType.GetPackagesList;
        // this.reqType = RequestType.GetPackagesList;
        limit = 10;
    }
    uint limit;
}

VrtsRequest deserializeRequest(uint subType, ubyte[] payload){
    // return null;
    switch (cast(RequestType)subType)
    {
        case RequestType.GetPackagesList:
            return deserializeIon!VrtsRequestGetPackageList(payload); break;
            default:
                
                break;
    }
    assert(0);
}