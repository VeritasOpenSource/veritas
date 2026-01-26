module widgets;

import std.algorithm;

import tb2;

class Widget {
    Widget[] childs;
    Widget parent;

    int x, y;
    int width, height;

    bool focused;

    void delegate(int) onFocus; 

    void focus(bool focused) {
        if(this.focused != focused)
            swap(colorText, colorBack);

        this.focused = focused;
    }

    void switchFocus() {
        this.focused = !this.focused;

        swap(colorText, colorBack);
    }

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

    abstract bool processEvent(tb_event* event);

    bool handleEvent(tb_event* event) {
        bool handled = childs.map!(a => a.handleEvent(event)).any; 

        if(!handled)
            handled = processEvent(event);

        return handled;
    }
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

    override bool processEvent(tb_event* event) {
        return false;
    }
}

class List : Widget {
    ListItem[] items;

    bool hasCommonItem;
    uint selected = -1;


    override void draw() {
        int i = 0;
        items.each!((a) => drawItem(a, i++ == selected));
    }

    void drawItem(ListItem item, bool selected) {

        if(selected) 
            invertColor;

        foreach(int i; 0 .. cast(int)item.text.length)
            tb_change_cell(x + 1 + i, y + item.index, item.text[i], TB_BOLD | colorText, colorBack);

        if(selected)
            invertColor;
    }

    void setCommonItem(bool has) {
        hasCommonItem = has;
    }

    void addItem(string text, int libId) {
        auto item = ListItem(text, libId, cast(int)items.length);
        items ~= item;
    }

    void invertColor() {
        swap(colorText, colorBack);
    }

    override bool processEvent(tb_event* event) {
        if(event.key != TB_KEY_ARROW_UP && event.key != TB_KEY_ARROW_DOWN)
            return false;

        if(items.length == 0)
            return false;

        if (event.key == TB_KEY_ARROW_UP) {
            if(selected > 0)
                selected--;
        }
        if(event.key == TB_KEY_ARROW_DOWN) {
            selected++;
            if(selected >= items.length)
                selected = cast(uint)items.length - 1;
        }

        onFocus(items[selected].libId);

        return true;
    }

    // void 
}

struct ListItem {
    string text;
    uint libId;
    int index;

    this(string text, int libid, int index) {
        this.text = text;
        this.libId = libid;
        this.index = index;
    }
}