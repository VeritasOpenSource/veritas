///
module veritas.ecosystem.rings.ring;

import std.algorithm;

import veritas.ecosystem;

class VrtsRing {
    uint level;
    VrtsFunction[]     functions; 

    void setId(uint id) {
        this.level = id;
    }

    bool isFunctionInRing(VrtsFunction func) {
        return functions.canFind!(a => a == func);
    }
} 