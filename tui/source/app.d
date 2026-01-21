import std.socket;
import std.stdio;

import tb2;
import ui; 
import veritas.ipc;

void main() {
    VrtsIPC ipc = new VrtsIPC(VrtsIPCType.Client);
    VrtsTUI tui = new VrtsTUI(ipc);

    tui.loop();
}
