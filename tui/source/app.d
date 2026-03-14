import std.socket;
import std.stdio;

import tb2;
import ui; 
import veritas.ipc;

void main() {
    VrtsIPCClient ipc = new VrtsIPCClient("/tmp/veritas.sock");
    VrtsTUI tui = new VrtsTUI(ipc);

    tui.loop();
}
