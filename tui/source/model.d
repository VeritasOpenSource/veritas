module model;

import std.algorithm;
import std.array;

struct Package {
    uint localId;
    uint veritasId;

    string name;
}

struct Ring {
    uint localId;
    uint veritasId;

    uint[] funcsId;
}

struct Function {
    string name;
    uint veritasId;

    uint ringId;
    
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

    void addFunction(string name, uint veritasId, uint ringId) {
        funcs ~= Function(name, veritasId, ringId);
    }

    Function[] getFunctionsByRing(uint ringId) {
        if(ringId == -1) {
            return funcs;
        }
        return funcs.filter!(a => a.ringId == ringId).array;
    }
}