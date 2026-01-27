module veritas.triggering;

import veritas.ecosystem.func;

class Triggering {
    uint id;
    VrtsFunction func;
    int count;

    this(VrtsFunction func, int count) {
        this.func = func;
        this.count = count;
    }
}