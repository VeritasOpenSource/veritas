module veritas.ipc.core;

import std.socket;
import core.stdc.errno : EAGAIN, EWOULDBLOCK;
import std.stdio;
import std.array;
import std.algorithm;
import std.string;

enum VrtsIPCType {
    Core,
    Client
}

class VrtsIPC {
    VrtsIPCType type;
    enum SOCKET_PATH = "/tmp/veritas.sock";
    Socket socket;
    string[] raws;

    bool exit;
    string inputBuffer;

    this(VrtsIPCType type) {
        this.type = type;
    }

    void connect() {
        socket = new Socket(AddressFamily.UNIX, SocketType.STREAM);
        socket.connect(new UnixAddress(SOCKET_PATH));
        socket.blocking = false;
    }

    bool needUpdae() {
        return true;
    }

    void sendCommand(string command) {
        socket.send(command);
    }

    void pollEvent() {
        char[1024] tmp;

        while (true) {
            auto n = socket.receive(tmp);
            if (n <= 0) break;

            inputBuffer ~= cast(string)tmp[0..n];

            while (true) {
                auto pos = inputBuffer.indexOf('\n');
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
}