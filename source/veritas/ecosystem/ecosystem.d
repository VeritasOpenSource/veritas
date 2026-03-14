///
module veritas.ecosystem.ecosystem;

import std.algorithm;
import std.array;
import std.path;
import std.file;
import std.stdio;

import veritas.ecosystem.reports;
import veritas.ecosystem;
import veritas.ipc.messages.events;
import veritas.ecosystem.packages.packageCollector;

/// 
class VrtsEcosystem {
    VrtsEventBus eventBus;
    VrtsSourceCollector     sourcesCollector;
    VrtsPackagesCollector   packageCollector;
    VrtsFunctionsCollector  functionsCollector;
    VrtsCallsCollector      callsCollector;

    void setEventBus(VrtsEventBus eventBus) {
        this.eventBus = eventBus;
    }
}

///
T[] removeElements(T)(ref T[] array, T[] needles) {
    T[] newArray;

    foreach(elem; array) {
        if(needles.canFind!(a => a == elem)) {
            continue;
        }

        newArray ~= elem;
    }

    return newArray;
}