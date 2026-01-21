import veritas.veritas;

import std.socket;
import std.file;

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