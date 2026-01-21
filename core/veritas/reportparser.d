module veritas.reportparser;

import std.file;
import std.json;
import std.path;

import veritas.ecosystem;

class VrtsReport {
    string filename;
    string description;

    uint line;
    uint column;
}

class VrtsReportsParser {
    VrtsReport[] reports;

    VrtsReport[] parseResultFile(string path) {
        string jsonContent = readText(path);
        JSONValue jsonFile = parseJSON(jsonContent);
        auto jsonReports = jsonFile["reports"];

        foreach(jsonReport; jsonReports.arrayNoRef()) {
            auto file = jsonReport["file"];

            VrtsReport report = new VrtsReport();

            report.filename = file["original_path"]
                .str()
                .baseName();

            report.line = jsonReport["line"].get!uint;
            report.column = jsonReport["column"].get!uint;
            report.description = jsonReport["message"].get!string;

            reports ~= report;
        }

        return reports;
    }
}