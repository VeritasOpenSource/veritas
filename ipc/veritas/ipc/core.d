module veritas.ipc.core;

import std.socket;
import core.stdc.errno : EAGAIN, EWOULDBLOCK;
import std.stdio;
import std.array;
import std.algorithm;
import std.string;
import std.conv;

enum VrtsIPCType {
    Core,
    Client
}

class VrtsIPC {
    VrtsIPCType type;
    enum SOCKET_PATH = "/tmp/veritas.sock";
    Socket socket;
    bool socketConnected;
    string[] raws;

    bool exit;
    string inputBuffer;

    this(VrtsIPCType type) {
        this.type = type;
    }

    void connect() {
        socket = new Socket(AddressFamily.UNIX, SocketType.STREAM);
        try {
            socket.connect(new UnixAddress(SOCKET_PATH));
            socketConnected = true;
        }
        catch (SocketException e) {
            e.writeln(e);
        }
        socket.blocking = false;
    }

    bool needUpdae() {
        return true;
    }

    void sendCommand(string command) {
        socket.send(command);
    }

    void pollEvent() {
        while (true && socketConnected) {
            char[1024] tmp;
            auto n = socket.receive(tmp);
            if (n <= 0) break;

            inputBuffer ~= cast(string)tmp[0..n];

            while (true) {
                auto pos = inputBuffer.indexOf('|');
                if (pos == -1) break;

                auto raw = inputBuffer[0..pos];
                inputBuffer = inputBuffer[pos+1..$];

                raws ~= raw;
            }
        }
    }

    bool hasEvent() { return raws.length > 0; }

    string pop() {
        auto e = raws[0];
        raws = raws[1..$];
        return e;
    }

    void disconnect() {
        socket.close();
        socket = null;
    }
}