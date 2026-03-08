module veritas.ecosystem.reports.report;

import std.algorithm;

import veritas.ecosystem;
import veritas.reportparser;
import veritas.triggering;

class VrtsReport {
    uint id;
    VrtsSourceLocation location;
    string description;

    void setId(uint id) {
        this.id = id;
    }

    this(uint id) {
        this.id = id;
        location = new VrtsSourceLocation();
    }
}