module ui;

import std.algorithm;
import std.array;
import std.stdio;

import veritas.ipc;

import tb2;

class Widget {
    Widget[] childs;
    Widget parent;

    int x, y;
    int width, height;

    bool focused;

    void addChild(Widget widget) {
        childs ~= widget;
        widget.setParent(this);
    }

    void fillParent() {
        x = parent.x + 1;
        y = parent.y + 1;
        width = parent.width + 1;
        height = parent.height + 1;
    }

    void setParent(Widget widget) {
        parent = widget;
    }

    ushort colorText = TB_WHITE;
    ushort colorBack = TB_BLACK;

    abstract void draw();
}

class Panel : Widget {
    string title;

    this(int x, int y, int w, int h, string title) {
        this.title = title; 
        this.x = x; 
        this.y = y; 
        this.width = w; 
        this.height = h;  
    }

    void drawBox() {
        tb_change_cell(x, y, '╔', colorText, TB_BLACK);
        tb_change_cell(x, y + height, '╚', colorText, TB_BLACK);
        foreach(int i; 1 .. width) {
            tb_change_cell(x + i, y, '═', colorText, TB_BLACK);
            tb_change_cell(x + i, y + height, '═', colorText, TB_BLACK);
        }
        tb_change_cell(x + width, y, '╗', colorText, TB_BLACK);
        tb_change_cell(x + width, y + height, '╝', colorText, TB_BLACK);
        

        foreach(int i; 0 .. height - 1) {
            tb_change_cell(x, y + i + 1, '║', colorText, TB_BLACK);
            tb_change_cell(x + width, y + i + 1, '║', colorText, TB_BLACK);
        }

        foreach(int i; 0 .. cast(int)title.length)
            tb_change_cell(x + 2 + i, y, title[i], TB_BOLD | colorText, TB_BLACK);
    }

    override void draw() {
        if(childs.length > 0) {
            childs.each!(a => a.draw());
        }

        colorText = TB_WHITE;
        colorBack = TB_BLACK;

        if(focused) {
            colorText = TB_GREEN;
            // colorBack = TB_GREEN;
        }   

        drawBox();
    } 
}

class List : Widget {
    ListItem[] items;

    override void draw() {
        items.each!(a => drawItem(a));
    }

    void drawItem(ListItem item) {
        foreach(int i; 0 .. cast(int)item.text.length)
            tb_change_cell(x + 1 + i, y + item.index, item.text[i], TB_BOLD | colorText, TB_BLACK);
    }

    void addItem(string text, int libId) {
        auto item = ListItem(text, libId, cast(int)items.length);
        items ~= item;
        // addChild(item);
    }
}

struct ListItem {
    string text;
    uint libId;
    uint index;

    this(string text, int libid, int index) {
        this.text = text;
        this.libId = libid;
        this.index = index;
    }
}

enum Mode {
    Command,
    Navigation
}

class Context {
    int selectedPackage;
    int selectedFunction;
    // int selecte
}

class VrtsTUI {
    VrtsIPC ipc;

    Panel packagesPanel;
    Panel ringsPanel;
    List packageList;
    List ringsList;
    // VrtsPackage[uint] packageId;
    // VrtsRing[uint] ringId;
    // Focus focus;
    string command;

    Mode mode;

    this(VrtsIPC ipc) {
        tb_init();
        this.ipc = ipc;

        packagesPanel = new Panel(0, 0, 20, 40, "PACKAGES");
        ringsPanel = new Panel(20, 0, 20, 40, "RINGS");


        // focus = new Focus();
        // focus.widget = packagesPanel;

        packageList = new List;
        packagesPanel.addChild(packageList);
        packageList.fillParent;

        ringsList = new List;
        ringsPanel.addChild(ringsList);
        ringsList.fillParent;


        mode = Mode.Navigation;
    }

    ~this() {
        tb_shutdown();
    }

    void update() {
        // packageId.clear();
        packageList.items.length = 0;
        packageList.childs.length = 0;
        // foreach(uint i, pkg; veritas.ecosystem.packages) {
        //     // write(veritas.ecosystem.packages.length);
        //     packageId[i] = pkg;
        //     packageList.addItem(pkg.getName, i);
        // }

        // ringId.clear();
        ringsList.items.length = 0;
        ringsList.childs.length = 0;

        // foreach(uint i, ring; veritas.ecosystem.rings) {
        //     ringId[i] = ring;
        //     ringsList.addItem("Ring " ~ ring.level.to!string, i);
        // }
    }

    void render() {
        tb_clear();

        foreach(int i; 0 .. cast(int)command.length)
            tb_change_cell(0 + i, tb_height() - 1, command[i], TB_BOLD | TB_WHITE, TB_BLACK);

        packagesPanel.draw();
        // packageList.draw(focus.widget);
        ringsPanel.draw();

        tb_present();
    }

    void loop() {
        while (true) {
            update();
            render();

            tb_event ev;
            tb_poll_event(&ev);

            if (ev.type == TB_EVENT_KEY) {
                // update();

                if (ev.key == TB_KEY_ESC && mode == Mode.Navigation)
                    break;

                if(mode == Mode.Navigation) {
                    if(ev.ch == cast(uint)'c')
                        mode = Mode.Command;

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
        else 
            ipc.sendCommand(command);
    }
}