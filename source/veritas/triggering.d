module veritas.triggering;

import veritas.ecosystem.func;

class Triggering {
    uint id;
    VrtsFunction func;
    int count;

    this(uint id, VrtsFunction func, int count) {
        this.id = id;
        this.func = func;
        this.count = count;
    }
}