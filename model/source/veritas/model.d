module veritas.model;

import std.file;
// import veritas.ecosystem;
import std.concurrency;
import std.string;
import std.conv;

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

    union CallImpl {
        string name;
        uint targetId;
    }

    CallImpl call;
}

struct VrtsModelRing {
    uint id;
    uint[] functionsIds;
}

struct VrtsModel {
    // string homePath;
    VrtsModelPackage[] packages;
    VrtsModelFunction[] functions;
    VrtsModelRing[] rings;
    VrtsModelCall[] calls;
    VrtsModelTriggering[] triggerings;
    VrtsModelSourceFile[] files;
    VrtsModelReport[]   reports;
}

string serialize(VrtsModel model) {
    string result;

    string[] entitiesString;
    entitiesString ~= "S M start|";

    foreach(pkg; model.packages) {

    }

    entitiesString ~= "S M end|";

    return result;
}

string[] serializePackage(VrtsModelPackage pkg) {
    string[] result;
    result ~= "S P";
    result ~= pkg.id.to!string;
    result ~= pkg.name;
    result ~= pkg.path;

    result ~= pkg.functionsIds.length.to!string;

    foreach(id; 0..pkg.functionsIds.length) {
        result ~= id.to!string;
    }

    result ~= pkg.sourceFilesIds.length.to!string;

    foreach(id; 0..pkg.sourceFilesIds.length) {
        result ~= id.to!string;
    }

    // result ~= " END ";

    // result ~= "|";

    return result;
}

string serializeFunc(VrtsModelFunction func) {
    string result;
    result ~= "S P " ~
        func.id.to!string~
        func.name ~ " " ~
        func.sourceFileId.to!string;

    // result ~= " FIDs ";

    // foreach(id; func.functionsIds) {
    //     result ~= id.to!string;
    // }

    // result ~= " END ";

    // result ~= " SFIDs ";

    // foreach(id; func.sourceFilesIds) {
    //     result ~= id.to!string;
    // }

    // result ~= " END ";

    // result ~= "|";

    return result;
}

auto serializeSourceLocation(VrtsModelSourceLocation loc) {
    string[] result;

    result ~= "LOC";
    result ~= loc.filename;
    result ~= loc.line.to!string;
    result ~= loc.column.to!string;
    
    return result;
}

auto serializeSourceLocationRange(VrtsModelSourceLocationRange locr) {
    string[] result;

    result ~= locr.start.serializeSourceLocation;
    result ~= locr.end.serializeSourceLocation;
    

    return result;
}

import std.stdio;

unittest {
    // VrtsModelSourceLocation loc1 = VrtsModelSourceLocation("file", 100, 5);
    // writeln(loc1.serializeSourceLocation);
    // VrtsModelSourceLocation loc2 = VrtsModelSourceLocation("file2", 123, 77);
    // writeln(loc1.serializeSourceLocation);

    // auto range = VrtsModelSourceLocationRange(loc1, loc2);
    // writeln(range.serializeSourceLocationRange);
}