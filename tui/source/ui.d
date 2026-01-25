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

class UIState {
    Panel current;
    int focusedPanel = 0;
    int selectedPackage = -1;
    int showedRing = -1;
    int selectedFunction = -1;
}

// enum UIState {
//     Package,
//     Ring,
//     Func
// }

class VrtsTUI {
    VrtsIPC ipc;

    Panel packagesPanel;
    Panel ringsPanel;
    Panel funcPanel;
    Panel[] panels;
    List packageList;
    List ringsList;
    List funcList;

    CoreModel model;

    bool isSnapshot;

    UIState state;

    string command;

    Mode mode;

    this(VrtsIPC ipc) {
        tb_init();
        this.ipc = ipc;

        ipc.connect();

        state = new UIState;

        packagesPanel = new Panel(0, 0, 20, 40, "PACKAGES");
        ringsPanel = new Panel(20, 0, 20, 40, "RINGS");
        funcPanel = new Panel(40, 0, 20, 40, "FUNCTIONS");

        panels ~= packagesPanel;
        panels ~= ringsPanel;
        panels ~= funcPanel;

        state.current = panels[0];
        panels[0].focused = true;

        packageList = new List;
        packagesPanel.addChild(packageList);
        packageList.fillParent;
        packageList.addItem("[all]", -1);

        ringsList = new List;
        ringsPanel.addChild(ringsList);
        ringsList.fillParent;
        // ringsList.startIndex = -1;
        ringsList.addItem("[all]", -1);

        funcList = new List;
        funcPanel.addChild(funcList);
        funcList.fillParent;


        mode = Mode.Navigation;
        model = new CoreModel;
    }

    ~this() {
        tb_shutdown();
    }

    void update() {
        packageList.items.length = 1;
        ringsList.items.length = 1;

        foreach(pkg; model.packages) {
            packageList.addItem(pkg.name, pkg.localId);
        }

        foreach(ring; model.rings) {
            ringsList.addItem(ring.veritasId.to!string, ring.localId);
        }

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
        if(event.key == TB_KEY_ARROW_RIGHT) {
            if(state.focusedPanel < panels.length - 1){
                state.current.switchFocus();
                state.focusedPanel++;
                state.current = panels[state.focusedPanel];
                state.current.switchFocus();
            }
        }

        if(event.key == TB_KEY_ARROW_LEFT) {
            if(state.focusedPanel > 0){
                state.current.switchFocus();
                state.focusedPanel--;
                state.current = panels[state.focusedPanel];
                state.current.switchFocus();
            }
        }

        state.current.handleEvent(event);
        // state.current.focused = true;
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
                        if(command == "analyze") {
                            model.rings.length = 0;
                        }
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
            model.addPackage(eventStrings[2].baseName, 0);
            if(!isSnapshot) {
                update();
            }
        }

        if(eventStrings[1] == "newRing") {
            int id = eventStrings[2].to!int;
            model.addRing(id);

            if(!isSnapshot) {
                update();
            }
        }

        if(eventStrings[1] == "addedFunction") {
            int id = eventStrings[2].to!int;
            model.addRing(id);

            if(!isSnapshot) {
                update();
            }
        }

        if(eventStrings[1] == "snapshotStart") {
            isSnapshot = true;
        }
        if(eventStrings[1] == "snapshotEnd") {
            isSnapshot = false;
            update();
        }

        if(!isSnapshot) {
            update();
        }
    }

    // void switchContextRing(int ring) {
    //     funcList.items.length = 0;

    //     foreach(int i, func; rings[ring].funcs) {
    //         funcList.addItem(func, i); 
    //     }
    // }
}