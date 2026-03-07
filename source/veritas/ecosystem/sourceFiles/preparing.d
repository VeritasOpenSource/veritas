module veritas.ecosystem.sourceFiles.preparing;

import std.process;
import std.string;
import std.algorithm;
import std.path;
import std.json;
import std.file;
import std.conv;

import veritas.common.analyzer;
import veritas.ecosystem.ecosystem;
import veritas.ecosystem.sourceFiles;
import veritas.ecosystem.packages;

class VrtsSourcePreparator : VrtsAnalyzer {
	VrtsSourceCollector collector;
	VrtsPackagesCollector packageCollector;

	this(VrtsEcosystem ecosystem) {
		collector = new VrtsSourceCollector(ecosystem);
		ecosystem.sourcesCollector = this.collector; 

		this.packageCollector = ecosystem.packageCollector;
	}

	void preparePackage(VrtsMetaData data) {
		auto home = environment["HOME"];
    	auto workDir = buildPath(home, "veritas-test");
		ProcessPipes proc = pipeProcess(["bash"]);

		proc.stdin.writeln("cd ~/veritas-test/");
		proc.stdin.writeln("cd bash");
		proc.stdin.writeln("./configure");

		string file = data.getPatch().split(":")[0];
		uint line = data.getPatch().split(":")[1].to!uint;
		string patch = data.getPatch().split(":")[2];
		proc.stdin.writeln("sed -i '" ~ line.to!string~ "s/.*/ /' "~file);
		proc.stdin.flush;
		proc.stdin.close();
		
		wait(proc.pid);
	}

	void pseudoMake() {
		ProcessPipes proc = pipeProcess(["bash"]);

		proc.stdin.writeln("cd ~/veritas-test/");
		proc.stdin.writeln("cd bash");
		proc.stdin.writeln("bear -- make");
		proc.stdin.flush;
		proc.stdin.close();

		wait(proc.pid);
	}

	string[] getSourceFilesPaths(VrtsMetaData data) {
		string[] res;

		string jsonContent = readText("../../veritas-test/bash/compile_commands.json");

        JSONValue jsonFile = parseJSON(jsonContent);
        if(jsonFile.type == JSONType.array) {
			foreach(item; jsonFile.array) {
				auto file = item["file"];
				auto dir = item["directory"];
				res ~= dir.str ~ "/"~ file.str;
			}
		}

		return res;
	}

	VrtsSourceFile[] processSourceFiles(VrtsPackage pkg, string[] sources) {
        auto dirs = sources.
            map!(a => DirEntry(a));

        foreach(dir; dirs) {
            collector.filesPerPackage[pkg] ~= new VrtsSourceFile(pkg, dir);
        }
        
        return collector.filesPerPackage[pkg];
    }

    string[] preparePackageSourceFiles(VrtsPackage pkg) {
        // auto sp = new VrtsSourcePreparing();
        // sp.preparePackage(pkg.getMetadata);
        // sp.pseudoMake();
        return this.getSourceFilesPaths(pkg.getMetadata);
    }

    void analyzePackage(VrtsPackage pkg) {
        string[] filesNames = preparePackageSourceFiles(pkg);
        collector.storage.add(processSourceFiles(pkg, filesNames));
    }

    void collectAllSourceFiles() {
        foreach(pkg; packageCollector.storage.data) {
            analyzePackage(pkg);
        }
    }
}