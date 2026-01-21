import std.socket;
import std.stdio;



enum SOCKET_PATH = "/tmp/veritas.sock";

void main() {
    auto sock = new Socket(AddressFamily.UNIX, SocketType.STREAM);
    sock.connect(new UnixAddress(SOCKET_PATH));

    bool exit;

    // sock.send("analyze\n");
    while(!exit) {
	    char[] command;
	    readln(command);

        exit = command == "exit";

        sock.send(command);
	    // if(!exit) {
        // }
    }
    // ubyte[128] buf;
    // auto n = sock.receive(buf[]);
    // writeln("Reply: ", cast(string)buf[0 .. n]);

    sock.close();
}
