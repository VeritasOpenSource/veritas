module veritas.ecosystem.reports.reportsCollector;

import std.file;
import std.path;

import veritas.common.collector;
import veritas.ecosystem.reports;
import veritas.ecosystem.sourceFiles;
import veritas.common.collector;
import veritas.ecosystem.functions;

class VrtsReportsCollector : VrtsStorage!VrtsReport {

    VrtsReport[][VrtsFunction]    reportsPerFunction;

    uint getNewId() {
        return cast(uint)storage.length;
    }

    void addReport(VrtsReport report) {
        storage.add(report);

    }
}