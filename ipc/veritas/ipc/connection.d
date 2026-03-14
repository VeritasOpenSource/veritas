module veritas.ipc.connection;

import std.socket;
import std.array;

class VrtsIPCConnection {
protected:

    Socket socket;

    ubyte[] readBuffer;
    ubyte[] writeBuffer;

public:

    this(Socket s) {
        socket = s;
        socket.blocking = false;
    }

    bool connected() {
        return socket !is null;
    }

    void readSocket() {
        ubyte[4096] tmp;

        try {
            auto n = socket.receive(tmp[]);

            if(n > 0)
                readBuffer ~= tmp[0 .. n];
        }
        catch(SocketException e) {
            if(wouldHaveBlocked())
                return;
        }
    }

    void flush() {
        if(writeBuffer.length == 0)
            return;

        try {
            auto sent = socket.send(writeBuffer);

            if(sent > 0)
                writeBuffer = writeBuffer[sent .. $];
        }
        catch(SocketException e) {
            if(wouldHaveBlocked())
                return;
        }
    }
}