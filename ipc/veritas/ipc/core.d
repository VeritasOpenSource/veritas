module veritas.ipc.core;

import std.socket;
import core.stdc.errno : EAGAIN, EWOULDBLOCK;
import std.stdio;


enum VrtsIPCType {
    Core,
    Client
}

class VrtsIPC {
    VrtsIPCType type;
    enum SOCKET_PATH = "/tmp/veritas.sock";
    Socket socket;

    bool exit;

    this(VrtsIPCType type) {
        this.type = type;

        socket = new Socket(AddressFamily.UNIX, SocketType.STREAM);
        socket.connect(new UnixAddress(SOCKET_PATH));
        socket.blocking = false;
        socket.send("SUCCESSS");
    }

    bool needUpdae() {
        return true;
    }

    void sendCommand(string command) {
        socket.send(command);
    }
}