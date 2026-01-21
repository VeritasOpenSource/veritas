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
// import veritas.ipc;
import veritas.ipc;

// import tb2;

// import ui;

class CommandInterpretator {
    void processCommand(string line) {
        
    }
}

class Veritas {
    VrtsEvent[] fifo;
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

            ecosystem.relinkCalls();
            ecosystem.buildRingsIerarchy();
        }else
    }

    void addProject(string path) {
        VrtsPackage pkg = new VrtsPackage(absolutePath(path), path);
        ecosystem.addPackage(pkg);
    }
}

enum string SOCKET_PATH = "/tmp/veritas.sock"; 

enum IPCState {
    Ready,
    Processing,
    Waiting
}

struct VrtsClient {
    Socket socket;
    ClientState state;
}

struct VrtsCore {
    Socket socket;

    void init() {

    }
}

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
}