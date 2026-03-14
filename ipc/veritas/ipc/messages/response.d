module veritas.ipc.messages.response;

enum Response {
    PackageList
}

class VrtsResponse {
    Response responseType;
    Response getType() {
        return responseType;
    }
}

class VrtsResponcePackageList : VrtsResponse {
    string[] packagesList;
    uint[] ids;
}

VrtsResponse deserializeResponse(ushort subType, ubyte[] payload){
    return null;
    // final switch (cast(ResponseType)subType)
    // {
    //     case ResponseType.Functions:
    //         return deserializeIon!ResponseFunctions(payload);
    // }
}