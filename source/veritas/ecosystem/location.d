module veritas.ecosystem.location;

class VrtsSourceLocation {
    string filename;
    uint line;
    uint column;

    this(string filename, uint line, uint column) {
        this.line = column;
        this.line = column;
    }
}

class VrtsSourceLocationRange {
    string filename;
    VrtsSourceLocation start;
    VrtsSourceLocation end;

    this(string filename, uint startLine, uint startColumn, uint endLine, uint endColumn) {
        this.filename = filename;
        this.start = new VrtsSourceLocation(filename, startLine, startColumn);
        this.end = new VrtsSourceLocation(filename, endLine, endColumn);
    }
}