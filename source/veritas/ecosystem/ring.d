module veritas.ecosystem.ring;

import std.algorithm;

import veritas.ecosystem;

class VrtsRing {
    uint level;
    VrtsFunction[]     functions; 

    bool isFunctionInRing(VrtsFunction func) {
        return functions.canFind!(a => a == func);
    }
} 