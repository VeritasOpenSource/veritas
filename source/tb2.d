module tb2;

version (Windows) {
    pragma(lib, "termbox2");
} else version (Posix) {
    pragma(lib, "termbox2");
}

extern (C) nothrow @nogc:

enum TB_OK = 0;
enum TB_ERR = -1;
enum TB_ERR_EOF = -2;
enum TB_ERR_NO_EVENT = -3;

enum TB_HIDE_CURSOR = -1;

enum TB_DEFAULT = 0x00;

enum TB_BLACK   = 0x01;
enum TB_RED     = 0x02;
enum TB_GREEN   = 0x03;
enum TB_YELLOW  = 0x04;
enum TB_BLUE    = 0x05;
enum TB_MAGENTA = 0x06;
enum TB_CYAN    = 0x07;
enum TB_WHITE   = 0x08;

enum TB_BOLD      = 0x0100;
enum TB_UNDERLINE = 0x0200;
enum TB_REVERSE   = 0x0400;
enum TB_ITALIC    = 0x0800;

enum TB_EVENT_KEY    = 1;
enum TB_EVENT_RESIZE = 2;
enum TB_EVENT_MOUSE  = 3;

enum TB_KEY_F1  = 0xFFFF - 0;
enum TB_KEY_F2  = 0xFFFF - 1;
enum TB_KEY_F3  = 0xFFFF - 2;
enum TB_KEY_F4  = 0xFFFF - 3;
enum TB_KEY_F5  = 0xFFFF - 4;
enum TB_KEY_F6  = 0xFFFF - 5;
enum TB_KEY_F7  = 0xFFFF - 6;
enum TB_KEY_F8  = 0xFFFF - 7;
enum TB_KEY_F9  = 0xFFFF - 8;
enum TB_KEY_F10 = 0xFFFF - 9;
enum TB_KEY_F11 = 0xFFFF - 10;
enum TB_KEY_F12 = 0xFFFF - 11;

enum TB_KEY_INSERT = 0xFFFF - 20;
enum TB_KEY_DELETE = 0xFFFF - 21;
enum TB_KEY_HOME   = 0xFFFF - 22;
enum TB_KEY_END    = 0xFFFF - 23;
enum TB_KEY_PGUP   = 0xFFFF - 24;
enum TB_KEY_PGDN   = 0xFFFF - 25;

enum TB_KEY_ARROW_UP    = 0xFFFF - 18;
enum TB_KEY_ARROW_DOWN  = 0xFFFF - 19;
enum TB_KEY_ARROW_LEFT  = 0xFFFF - 20;
enum TB_KEY_ARROW_RIGHT = 0xFFFF - 21;

enum TB_KEY_CTRL_TILDE       = 0x00;
enum TB_KEY_CTRL_2           = 0x00;
enum TB_KEY_CTRL_A           = 0x01;
enum TB_KEY_CTRL_B           = 0x02;
enum TB_KEY_CTRL_C           = 0x03;
enum TB_KEY_CTRL_D           = 0x04;
enum TB_KEY_CTRL_E           = 0x05;
enum TB_KEY_CTRL_F           = 0x06;
enum TB_KEY_CTRL_G           = 0x07;
enum TB_KEY_CTRL_BACKSPACE   = 0x08;
enum TB_KEY_CTRL_H           = 0x08;
enum TB_KEY_TAB              = 0x09;
enum TB_KEY_CTRL_I           = 0x09;
enum TB_KEY_CTRL_J           = 0x0A;
enum TB_KEY_CTRL_K           = 0x0B;
enum TB_KEY_CTRL_L           = 0x0C;
enum TB_KEY_ENTER            = 0x0D;
enum TB_KEY_CTRL_M           = 0x0D;
enum TB_KEY_CTRL_N           = 0x0E;
enum TB_KEY_CTRL_O           = 0x0F;
enum TB_KEY_CTRL_P           = 0x10;
enum TB_KEY_CTRL_Q           = 0x11;
enum TB_KEY_CTRL_R           = 0x12;
enum TB_KEY_CTRL_S           = 0x13;
enum TB_KEY_CTRL_T           = 0x14;
enum TB_KEY_CTRL_U           = 0x15;
enum TB_KEY_CTRL_V           = 0x16;
enum TB_KEY_CTRL_W           = 0x17;
enum TB_KEY_CTRL_X           = 0x18;
enum TB_KEY_CTRL_Y           = 0x19;
enum TB_KEY_CTRL_Z           = 0x1A;
enum TB_KEY_ESC              = 0x1B;
enum TB_KEY_CTRL_LSQ_BRACKET = 0x1B;
enum TB_KEY_CTRL_3           = 0x1B;
enum TB_KEY_CTRL_4           = 0x1C;
enum TB_KEY_CTRL_BACKSLASH   = 0x1C;
enum TB_KEY_CTRL_5           = 0x1D;
enum TB_KEY_CTRL_RSQ_BRACKET = 0x1D;
enum TB_KEY_CTRL_6           = 0x1E;
enum TB_KEY_CTRL_7           = 0x1F;
enum TB_KEY_CTRL_SLASH       = 0x1F;
enum TB_KEY_CTRL_UNDERSCORE  = 0x1F;
enum TB_KEY_SPACE            = 0x20;
enum TB_KEY_BACKSPACE        = 0x7F;
enum TB_KEY_CTRL_8           = 0x7F;

struct tb_cell {
    uint ch;
    ushort fg;
    ushort bg;
}

struct tb_event {
    ubyte type;
    ubyte mod;
    ushort key;
    uint ch;
    int w;
    int h;
    int x;
    int y;
}

alias tb_change_cell = tb_set_cell;

int tb_init();
int tb_init_fd(int fd);
void tb_shutdown();

int tb_width();
int tb_height();

void tb_clear();
void tb_present();

void tb_set_cursor(int cx, int cy);

void tb_put_cell(int x, int y, const tb_cell* cell);

void tb_set_cell(int x, int y, uint ch, ushort fg, ushort bg);

const(tb_cell)* tb_cell_buffer();

int tb_select_input_mode(int mode);
int tb_select_output_mode(int mode);

int tb_poll_event(tb_event* event);
int tb_peek_event(tb_event* event, int timeout);

void tb_print(int x, int y, ushort fg, ushort bg, const char* str);

enum TB_INPUT_ESC = 1;
enum TB_INPUT_ALT = 2;
enum TB_INPUT_MOUSE = 4;

enum TB_OUTPUT_CURRENT = 0;
enum TB_OUTPUT_NORMAL = 1;
enum TB_OUTPUT_256 = 2;
enum TB_OUTPUT_216 = 3;
enum TB_OUTPUT_GRAYSCALE = 4;
