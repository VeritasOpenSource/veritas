module veritas.app;

import std.stdio;

import std.process;
import std.algorithm;
import std.array;
import std.file;
import std.path;
import core.sys.linux.fs;
import std.string;
import std.conv;
import veritas.ecosystem;
import veritas.clang;
import veritas.sourceVisitor;
import std.range;
import veritas.reportparser;
import veritas.sourceVisitor;
import veritas.ecosystem.sourceAnalyzer;
import veritas.ecosystem.journal;
import std.socket;

class Veritas {
    VrtsEcosystem ecosystem;
    VrtsSourceAnalyzer analyzer;

    this() {
        ecosystem = new VrtsEcosystem;
        analyzer = new VrtsSourceAnalyzer(ecosystem);
    }

    void processCommand(string _command) {
        string[] commands = _command.to!string.split;

        if(commands[0] == "add") {
            string project = commands[1];
            writeln(project);
            addProject(project);
        } else

        if(commands[0] == "analyze") {
            ecosystem.recollectData();

            analyzer.analyzeSourceFilesByPackages(ecosystem.packages);

            writeln(("Linking functions..."));
            ecosystem.relinkCalls();
            writeln(("Building rings ierarchy..."));
            ecosystem.buildRingsIerarchy();
        }else

        if(commands[0] == "info") {
            writeln("Funcitons count: ", ecosystem.functions.length);
        } else

        if(commands[0] == "ringsCount") {
            writeln("Call rings detected: ", ecosystem.rings.length);
        }
    }

    void addProject(string path) {
        VrtsPackage pkg = new VrtsPackage(absolutePath(path), path);
        ecosystem.addPackage(pkg);
    }
}

enum string SOCKET_PATH = "/tmp/veritas.sock"; 

void main(string[] args) {
    Veritas veritas = new Veritas;

    auto server = new Socket(AddressFamily.UNIX, SocketType.STREAM);

    if(exists(SOCKET_PATH))
        std.file.remove(SOCKET_PATH);

    auto addr = new UnixAddress(SOCKET_PATH);

    server.bind(addr);
    server.listen(10);

    bool exit = false;

    auto client = server.accept();
    while (!exit) {
        exit = handleClient(veritas, client);
    }

    server.close();
}

bool handleClient(Veritas veritas, Socket client) {
    ubyte[1024] buf;

    while (true) {
        auto n = client.receive(buf[]);
        if (n > 0) {
            string command = cast(string)buf[0 .. n-1];

            if(command == "exit") {
                client.send("Shutdown...\n");
                return true;
            }
            else 
                veritas.processCommand(command);
        }
            
    }

    return false;
    // client.close();
}