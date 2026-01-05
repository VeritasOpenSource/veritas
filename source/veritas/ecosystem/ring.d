module veritas.ecosystem.ring;

import std.algorithm;

import veritas.ecosystem;

class VrtsRing {
    uint level;
    VrtsSourceFunctionDef[]     functions; 

    bool isFunctionInRing(VrtsSourceFunctionDef func) {
        return functions.canFind!(a => a == func);
    }
} 