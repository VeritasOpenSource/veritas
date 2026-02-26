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

    void sendRaw(const(ubyte)[] data) {
        uint len = cast(uint)data.length;
        sendAll((cast(ubyte*)&len)[0 .. uint.sizeof]);
        sendAll(data);
    }

    void sendAll(const(ubyte)[] data) {
        size_t sent = 0;

        while (sent < data.length) {
            auto n = socket.send(data[sent .. $]);
            if (n <= 0)
                throw new Exception("Socket send failed");

            sent += n;
        }
    }

    ubyte[] receiveRaw() {
        ubyte[4] lenBuf;
        receiveAll(lenBuf[]);

        uint beLen = *cast(uint*)lenBuf.ptr;
        auto buffer = new ubyte[beLen];
        receiveAll(buffer);

        return buffer;
    }

    void receiveAll(ubyte[] buffer) {
        size_t received = 0;

        while (received < buffer.length) {
            auto n = socket.receive(buffer[received .. $]);
            if (n <= 0)
                throw new Exception("Socket receive failed");

            received += n;
        }
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