module veritas.ecosystem.event;

import std.traits;

class VrtsEvent {

}

class VrtsEventAddingPackage : VrtsEvent {
    string packageName;

    this(string name) {
        this.packageName = name;
    }
}