/** 
 * Module provides source location and locations range classes
 */
module veritas.ecosystem.location;

import std.conv;

/** 
 * Source file location
 */
class VrtsSourceLocation {
protected:
    string filename_;
    uint line_;
    uint column_;

public:
    this() {}

    ///
    this(string filename, uint line, uint column) {
        this.filename_ = filename;
        this.line_ = line;
        this.column_ = column;
    }

    @property {
        ///Getters/setters for line
        uint line(uint line) => this.line_ = line;
        ///ditto
        uint line() const => this.line_;

        ///Getters/setters for column
        uint column(uint column) => this.column_ = column;
        ///ditto
        uint column() const => this.column_;

        ///Getters/setters for filename
        string filename(string filename) => this.filename_ = filename;
        ///ditto
        string filename() const => this.filename_;
    }


    /** 
     * toString class overrided function
     *
     * Returns: string represented location in source file of format 'filename[line:column]''
     */
    override string toString() const {
        return this.filename ~ "[" ~ this.line.to!string ~ ":"~ this.column.to!string ~ "]";    
    }
}

/** 
 * Source file locations range
 */
class VrtsSourceLocationRange {
protected:
    string filename_;
    VrtsSourceLocation start_;
    VrtsSourceLocation end_;

public:

    ///Constructor
    this(string filename, uint startLine, uint startColumn, uint endLine, uint endColumn) {
        this.filename = filename;
        this.start = new VrtsSourceLocation(filename, startLine, startColumn);
        this.end = new VrtsSourceLocation(filename, endLine, endColumn);
    }

    @property  {
        ///Getter/setter for file name
        string filename(string filename) => this.filename_ = filename;

        ///ditto
        string filename() const => this.filename_;

        ///Getter/setter for start location
        VrtsSourceLocation start(VrtsSourceLocation start) => this.start_ = start;
        ///ditto
        VrtsSourceLocation start() => this.start_;

        ///Getter/setter for end location
        VrtsSourceLocation end(VrtsSourceLocation end) => this.end_ = end;

        ///ditto
        VrtsSourceLocation end() => this.end_;
    }

    /** 
     * Checks is location inside range
     * Params:
     *   filename = 
     *   startLine = 
     *   endLine = 
     * Returns: 
     *   true if location placed inside location range
     */
    bool isLocationInsideRange(string filename, uint startLine, uint endLine) {
        return 
            this.filename == filename &&
            this.start.line < startLine &&
            this.end.line > endLine;
    }
}