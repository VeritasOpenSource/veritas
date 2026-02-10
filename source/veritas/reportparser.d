module veritas.reportparser;

import std.file;
import std.json;
import std.path;
import std.stdio;

import veritas.ecosystem;

class VrtsReport {
    uint id;
    VrtsSourceLocation location;
    string description;

    this(uint id) {
        this.id = id;
        location = new VrtsSourceLocation();
    }
}

class VrtsReportsParser {
    uint id;
    VrtsReport[] reports;

    VrtsReport[] parseResultFile(string path) {
        // writeln("path");
        string jsonContent = readText(path);
        // writeln("path");

        JSONValue jsonFile = parseJSON(jsonContent);
        auto jsonReports = jsonFile["reports"];
        // writeln("path");

        foreach(jsonReport; jsonReports.arrayNoRef()) {
            auto file = jsonReport["file"];
            //  writeln(file);

            VrtsReport report = new VrtsReport(id++);

            report.location.filename = file["original_path"]
                .str()
                .baseName();
            // writeln(report.location.filename);
            

            report.location.line = jsonReport["line"].get!uint;
            report.location.column = jsonReport["column"].get!uint;
            report.description = jsonReport["message"].get!string;

            reports ~= report;
        }
        // writeln("path");

        return reports;
    }
}