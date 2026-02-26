module ui;

import std.algorithm;
import std.array;
import std.stdio;
import std.conv;
import std.range;

import veritas.ipc;

import tb2;
import std.path;
import veritas.model;
import widgets;
import core.sys.posix.libgen;
import mir.deser.ion;
import std.base64;

enum Mode {
    Command,
    Navigation
}

class UIState {
    Panel current;
    int focusedPanel = 0;
    int selectedPackage = -1;

    void setPack(int i) {
        selectedPackage = i;
    }
}

class PackageInfoPanel : Panel {
    string packageName;
    uint functionsCount;
    uint calls;
    uint eCalls;

    this(uint x, uint y, uint width, uint height, string name) {
        super(x, y, width, height, name);
    }

    void changeContext(VrtsModel* model, VrtsModelPackage pkg) {
        packageName = pkg.name;
        functionsCount = cast(uint)pkg.functionsIds.length;
        auto functions = model.getById!("functions")(pkg.functionsIds);
        
        calls = 0;
        foreach(func; functions) {
            calls += func.callsIds.length;
        }

        // auto modelCalls = model.calls;
        eCalls = 0;
        auto fcids = functions.map!(a => a.callsIds).joiner.array;
        auto fids = functions.map!(a => a.id).array;


        auto pCalls = model.getById!"calls"(fcids);

        foreach(call; pCalls) {
            if(!fids.canFind(call.targetId)) {
                eCalls++;
            }
        }
    }

    override void draw() {
        if(childs.length > 0) {
            childs.each!(a => a.draw());
        }

        colorText = TB_WHITE;
        colorBack = TB_BLACK;

        // if(focused) {
        //     colorText = TB_GREEN;
        // }   
        drawText(x + 1, y + 1, "METADATA");
        drawText(x + 1, y + 2, "    Package name: " ~ packageName);
        drawText(x + 1, y + 3, "    Functions count: " ~ functionsCount.to!string);
        drawText(x + 1, y + 4, "    Internal calls count: " ~ calls.to!string);
        drawText(x + 1, y + 5, "    External calls count: " ~ eCalls.to!string);


        drawBox();
    } 

    void toMainContext() {
        packageName = "";
    }
}

class PackageScreen : Screen {

    Panel[] panels;
    Panel packagesPanel;
    PackageInfoPanel packageInfoPanel;

    List packageList;

    UIState state;

    Mode mode;

    this(VrtsIPC ipc, VrtsModel* model) {
        super(ipc, model);

        state = new UIState;

        packagesPanel = new Panel(0, 0, 20, 20, "PACKAGES");
        packageInfoPanel = new PackageInfoPanel(20, 0, 60, 20, "PACKAGE INFO");

        panels ~= packagesPanel;

        state.current = panels[0];
        panels[0].focused = true;

        packageList = new List;
        packagesPanel.addChild(packageList);
        packageList.fillParent;
        packageList.addItem("[all]", -1);
        packageList.onFocus = &state.setPack;

        mode = Mode.Navigation;
    }

    ~this() {
        tb_shutdown();
    }

    void updateInfoPanel() {
        if(state.selectedPackage != -1) {
            import std.stdio;
            auto pkg = model.packages.find!(a => a.id == state.selectedPackage).front;
            packageInfoPanel.changeContext(model, pkg);
        }
        else 
            packageInfoPanel.toMainContext();
    }

    override void update() {
        packageList.items.length = 1;

        foreach(pkg; model.packages) {
            packageList.addItem(pkg.name, pkg.id);
        }

        updateInfoPanel();
    }

    override void render() {
        packagesPanel.draw();
        packageInfoPanel.draw();
    }

    override void navMode(tb_event* event) {
        state.current.handleEvent(event);
        update();
    }
}

class VrtsTUI {
    bool isSnapshot;

    VrtsIPC ipc;

    PackageScreen packagesScreen;

    VrtsModel model;
    Mode mode;
    string command;

    Screen[] screens;
    int screenIndex;
    Screen currentScreen;

    this(VrtsIPC ipc) {
        tb_init();

        this.ipc = ipc;
        ipc.connect();

        packagesScreen = new PackageScreen(ipc, &model);

        screens ~= packagesScreen;
        mode = Mode.Navigation;
        currentScreen = packagesScreen;
    }

    void loop() {
        while(true) {
            pollEvent();
            tb_event ev;
            tb_peek_event(&ev, 10);

            if (ev.type == TB_EVENT_KEY) {
                if(mode == Mode.Navigation) {
                    if(ev.ch == cast(uint)'c') {
                        mode = Mode.Command;
                        continue;
                    }

                    if(ev.key == TB_KEY_ESC)
                        break;

                    currentScreen.navMode(&ev);
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

                if(ev.key == TB_KEY_TAB)
                    switchScreen();
            }

            currentScreen.iterate(&ev);

            tb_clear();

            foreach(int i; 0 .. cast(int)command.length)
                tb_change_cell(0 + i, tb_height() - 1, command[i], TB_BOLD | TB_WHITE, TB_BLACK);

            currentScreen.render();

            tb_present();
        }
    }

    void switchScreen() {
        screenIndex++;
        currentScreen = screens[screenIndex % 2];
    }

    void pollEvent() {
        ipc.pollEvent();

        while(ipc.hasEvent) {
            parseAndDispatch(ipc.pop);
        }
    }

     void parseAndDispatch(string event) {
        auto parts = event.split(" ");

        if(parts.length < 2)
            return;

        if(parts[1] == "snapshotStart") {

            if(parts.length < 3)
                return;

            auto data = Base64.decode(parts[2]);
            model = deserializeIon!VrtsModel(data);

            currentScreen.update();
            return;
        }

        if(parts[1] == "addedPackage") {
            currentScreen.update();
            return;
        }

        if(parts[1] == "newRing") {
            currentScreen.update();
            return;
        }

        if(parts[1] == "sendFunc") {
            currentScreen.update();
            return;
        }
    }

    void processCommands(string command) {
        if(command.split[0] == "exit") {
            ipc.sendCommand("exit");
        }
        else 
            ipc.sendCommand(command);
    }
}