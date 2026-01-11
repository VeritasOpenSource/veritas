module veritas.ecosystem.logger;

import arsd.terminal;

static this() {
    logger = new Logger();
}

class Logger {
    Terminal* terminal;

    this() {}

    void setTerminal(Terminal* terminal) {
        this.terminal = terminal;
    }

    void log(string data) {
        terminal.writeln(data);
        terminal.flush();
    }

    void rewriteLine() {
        
    }
}

Logger logger;