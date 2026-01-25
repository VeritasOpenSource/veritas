module model;

struct Package {
    uint localId;
    uint veritasId;

    string name;
}

struct Ring {
    uint localId;
    uint veritasId;

    // uint level;
}

struct Function {
    uint localId;
    uint veritasId;

    string name;
}

class CoreModel {
    Package[] packages;
    Ring[] rings;
    Function[] funcs;

    void addPackage(string name, uint veritasId) {
        packages ~= Package(cast(uint)packages.length, veritasId, name);
    }

    void addRing(uint veritasId) {
        rings ~= Ring(cast(uint)rings.length, veritasId);
    }

    void addFunction(string name, uint veritasId) {
        funcs ~= Function(cast(uint)funcs.length, veritasId, name);
    }

    void parseSnapshot(string[] res) {
        
    }
}