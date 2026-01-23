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
    }

    bool needUpdae() {
        return true;
    }

    void sendCommand(string command) {
        socket.send(command);
    }

    bool pollEvent(ref string event){
        char[1024] buff;
        auto n = socket.receive(buff);
        if (n <= 0)
            return false; 


        event = cast(string)buff[0..n].idup;
        return true;
    }
}