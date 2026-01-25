module ui;

import std.algorithm;
import std.array;
import std.stdio;
import std.conv;

import veritas.ipc;

import tb2;
import std.path;
// import core.cpuid;
import model;
import widgets;
import core.sys.posix.libgen;
// import model;

enum Mode {
    Command,
    Navigation
}

class Context {
    UIState state;
    int selectedPackage = -1;
    int showedRing = -1;
    int selectedFunction = -1;
}

enum UIState {
    Package,
    Ring,
    Func
}

class VrtsTUI {
    VrtsIPC ipc;

    Panel packagesPanel;
    Panel ringsPanel;
    Panel funcPanel;
    List packageList;
    List ringsList;
    List funcList;
    Ring[] rings;

    Context context;

    // Context context;
    // VrtsPackage[uint] packageId;
    // VrtsRing[uint] ringId;
    // Focus focus;
    string command;

    Mode mode;

    this(VrtsIPC ipc) {
        tb_init();
        this.ipc = ipc;

        ipc.connect();

        packagesPanel = new Panel(0, 0, 20, 40, "PACKAGES");
        ringsPanel = new Panel(20, 0, 20, 40, "RINGS");
        funcPanel = new Panel(40, 0, 20, 40, "FUNCTIONS");
        context = new Context;
        context.state = UIState.Package;
        packagesPanel.focused = true;

        // focus = new Focus();
        // focus.widget = packagesPanel;

        packageList = new List;
        packagesPanel.addChild(packageList);
        packageList.fillParent;

        ringsList = new List;
        ringsPanel.addChild(ringsList);
        ringsList.fillParent;

        funcList = new List;
        funcPanel.addChild(funcList);
        funcList.fillParent;


        mode = Mode.Navigation;
    }

    ~this() {
        tb_shutdown();
    }

    void update() {

        // if(context.showedRing == -1) {
        //     return;
        // }
        // funcList.items.length = 0;

        // uint showedRing = context.showedRing;

        // foreach (i, funName; rings[showedRing].funcs) {
        //     funcList.addItem(funName, cast(int)i);
        // }
    }

    void render() {
        tb_clear();

        foreach(int i; 0 .. cast(int)command.length)
            tb_change_cell(0 + i, tb_height() - 1, command[i], TB_BOLD | TB_WHITE, TB_BLACK);

        packagesPanel.draw();
        // packageList.draw(focus.widget);
        ringsPanel.draw();

        funcPanel.draw();

        tb_present();
    }

    void navMode(tb_event* event) {
        if(context.state == UIState.Package)
            packagesPanel.handleEvent(event);
    }

    void loop() {
        while (true) {
            pollEvent();
            render();

            tb_event ev;
            tb_peek_event(&ev, 10);

            if (ev.type == TB_EVENT_KEY) {
                // update();

                if (ev.key == TB_KEY_ESC && mode == Mode.Navigation)
                    break;

                if(mode == Mode.Navigation) {
                    if(ev.ch == cast(uint)'c')
                        mode = Mode.Command;

                    navMode(&ev);
                    continue;
                }

                if(mode == Mode.Command) {
                    if(ev.key == TB_KEY_ESC)
                        mode = Mode.Navigation;

                    if(ev.key == TB_KEY_ENTER) {
                        this.processCommands(command);
                        command = "";
                        continue;
                    }

                    if(ev.key == TB_KEY_BACKSPACE) {
                        if(command.length > 0)
                            command = command[0..$-1];
                    }

                    if(ev.ch != 0) {
                        command ~= cast(char)ev.ch;
                    }
                }
            }
        }
    }

    void processCommands(string command) {
        if(command.split[0] == "exit") {
            ipc.sendCommand("exit");
        }
        else if(command.split[0] == "ring") {
            switchContextRing(command.split[1].to!int);
        }
        else 
            ipc.sendCommand(command);
    }

    void pollEvent() {
        ipc.pollEvent();

        while(ipc.hasEvent) {
            parseAndDispatch(ipc.pop);
        }
    }

    void parseAndDispatch(string event) {
        string[] eventStrings = event.split;

        if(eventStrings[1] == "addedPackage") {
            string name = eventStrings[2].baseName;
            packageList.addItem(name, cast(int)packageList.items.length);
        }

        if(eventStrings[1] == "newRing") {
            int id = eventStrings[2].to!int;
            ringsList.addItem("Ring "~ eventStrings[2], id);
            rings ~= Ring(id);
        }

        if(eventStrings[1] == "addFuncToRing") {
            uint ringId = eventStrings[2].to!int;
            rings[ringId].funcs ~= eventStrings[3];

            switchContextRing(eventStrings[2].to!int);
        }

        update();
    }

    void switchContextRing(int ring) {
        funcList.items.length = 0;

        foreach(int i, func; rings[ring].funcs) {
            funcList.addItem(func, i); 
        }
    }
}