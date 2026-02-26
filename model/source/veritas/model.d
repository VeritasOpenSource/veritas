module veritas.model;

import std.file;
// import veritas.ecosystem;
import std.concurrency;
import std.string;
import std.conv;

import mir.ser.ion: serializeIon;
import mir.deser.ion: deserializeIon;
import std.algorithm;

struct VrtsModelPackage {
    ///Internal id
    uint id;
    ///Name of Package
    string name;
    ///Internal functions ids
    uint[] functionsIds;

    uint[] sourceFilesIds;

    string path;
}

struct VrtsModelSourceFile {
    uint id;

    string path;
    uint    packageId;
}

struct VrtsModelSourceLocation {
    string filename;
    uint line;
    uint column;

    this(string filename, uint line, uint column) {
        this.filename = filename;
        this.line = line;
        this.column = column;
    }
}

struct VrtsModelSourceLocationRange {
    VrtsModelSourceLocation start;
    VrtsModelSourceLocation end;

    this(VrtsModelSourceLocation start, VrtsModelSourceLocation end) {
        this.start = start;
        this.end = end;
    }
}

struct VrtsModelReport {
    uint id;
    VrtsModelSourceLocation location;
    string description;
}

struct VrtsModelTriggering {
    uint id;
    uint functionId;
    int count;
}

struct VrtsModelFunction {
    uint id;
    string name;
    uint sourceFileId;
    VrtsModelSourceLocation declarationLocation;
    VrtsModelSourceLocationRange definitionLocation;

    uint[] triggersId;
    uint[] reportsIds;
    uint[] callsIds;
    uint[] calledByIds;
}

struct VrtsModelCall {
    uint id;

    bool isDefined;
    uint sourceId;
    string name;
    uint targetId;
}

struct VrtsModelRing {
    uint id;
    uint[] functionsIds;
}

struct VrtsModel {
    VrtsModelPackage[] packages;
    VrtsModelFunction[] functions;
    VrtsModelRing[] rings;
    VrtsModelCall[] calls;
    VrtsModelTriggering[] triggerings;
    VrtsModelSourceFile[] files;
    VrtsModelReport[]   reports;

    struct Range(T) {
        T[] array;
        uint[] ids;

        this(T[] array, uint[] ids) {
            this.ids = ids;
            this.array = array;
        }

        void popFront() {
            ids = ids[1..$];
        }

        bool empty() {
            return ids.length == 0;
        }

        T front() {
            return array[ids[0]];
        }

    }

    auto getById(alias source)(uint[] ids) {
        auto array = mixin(source);
        alias ET = typeof(array[0]);
        auto range = Range!ET(array, ids);
        return range;
    }
}

auto serialize(VrtsModel model) {
    return serializeIon(model);
}

auto deserialize(inout ubyte[] bytes) {
    return deserializeIon!VrtsModel(bytes);
}