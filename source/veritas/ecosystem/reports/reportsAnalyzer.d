module veritas.ecosystem.reports.reportsAnalyzer;

import std.json;
import std.file;
import std.path;
import std.algorithm;
import std.string;

import veritas.common.analyzer;
import veritas.ecosystem.ecosystem;
import veritas.ecosystem.reports;
import veritas.ecosystem.packages;
import veritas.ecosystem.functions;

class VrtsReportsAnalyzer : VrtsAnalyzer {
    uint id;

	VrtsReportsCollector collector;
	VrtsFunctionsCollector functionsCollector;
	VrtsPackagesCollector 	packageCollector;

	this(VrtsEcosystem ecosystem) {
		collector = new VrtsReportsCollector;

		functionsCollector = ecosystem.functionsCollector;
		packageCollector = ecosystem.packageCollector;
	}

	void parseReports() {
		foreach(pkg; packageCollector.storage.range) {
			// string pkgPath = pkg.getPath().absolutePath();
			string reportsPath = "../../veritas-test/" ~ pkg.getPath() ~ "/reports.json";
			parseResultFile(reportsPath);
		}
		processReports();
	}

    void parseResultFile(string path) {
        string jsonContent = readText(path);

        JSONValue jsonFile = parseJSON(jsonContent);
        auto jsonReports = jsonFile["reports"];

        foreach(jsonReport; jsonReports.arrayNoRef()) {
			if(jsonReport["analyzer_name"].get!string == "cppcheck") {
				continue;
			}
			if(jsonReport["checker_name"].get!string == "deadcode.DeadStores") {
				continue;
			}
            auto file = jsonReport["file"];

            VrtsReport report = new VrtsReport(id++);

            report.location.filename = file["original_path"]
                .str()
                .baseName();

            report.location.line = jsonReport["line"].get!uint;
            report.location.column = jsonReport["column"].get!uint;
            report.description = jsonReport["message"].get!string;

            collector.addReport(report);
        }

        // return reports;
    }

	    ///
    void processReports() {
        // this.reports = reports;
        foreach(report; collector.storage.range) {
            foreach(function_; functionsCollector.storage.range.filter!(a => a.definitionLocation !is null)) {
                if( report.location.filename == function_.definitionLocation.filename &&
                    report.location.line > function_.definitionLocation.start.line &&
                    report.location.line < function_.definitionLocation.end.line)

                    collector.reportsPerFunction[function_] ~= report;
            }
        }
    }
}