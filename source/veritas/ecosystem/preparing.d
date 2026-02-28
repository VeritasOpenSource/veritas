module veritas.ecosystem.preparing;

import std.process;
import veritas.ecosystem.pkg;
import std.string;
import std.stdio;
import std.algorithm;
import std.path;
import std.json;
import std.file;
import std.conv;

class VrtsSourcePreparing {

	void preparePackage(VrtsMetaData data) {
		auto home = environment["HOME"];
    	auto workDir = buildPath(home, "veritas-test");
		ProcessPipes proc = pipeProcess(["bash"]);

		proc.stdin.writeln("cd ~/veritas-test/");
		proc.stdin.writeln("cd bash");
		proc.stdin.writeln("./configure");

		// auto 
		string file = data.getPatch().split(":")[0];
		uint line = data.getPatch().split(":")[1].to!uint;
		string patch = data.getPatch().split(":")[2];
		proc.stdin.writeln("sed -i '" ~ line.to!string~ "s/.*/ /' "~file);
		proc.stdin.flush;
		proc.stdin.close();
		proc
			.stdout
			.byLine
			.each!(a => a.writeln);
		
		wait(proc.pid);
		writeln("DONE");
	}

	void pseudoMake() {
		ProcessPipes proc = pipeProcess(["bash"]);

		proc.stdin.writeln("cd ~/veritas-test/");
		proc.stdin.writeln("cd bash");
		proc.stdin.writeln("bear -- make");
		proc.stdin.flush;
		proc.stdin.close();
		proc
			.stdout
			.byLine
			.each!(a => a.writeln);

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
}