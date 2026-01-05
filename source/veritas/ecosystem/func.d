module veritas.ecosystem.func;

import veritas.ecosystem.ecosystem;
import veritas.reportparser;

class VrtsSourceFunctionDef {
    //Name of function
    string name;
    //Source filename
    string filename;
    // VrtsSourceFile file;

    uint startLine;
    uint endLine;
    // uint startColumn;
    // uint endColumn;
    ///Reports about function
    VrtsReport[] reports;


    VrtsSourceFunctionCall[] calls;
    VrtsSourceFunctionCall[] callers;

    this(string name) {
        this.name = name;
    }

    void setLocation(string filename, uint startLine, uint endLine /*, uint startColumn, uint endColumn*/) {
        this.filename = filename;
        this.startLine = startLine;
        this.endLine = endLine;
        // this.startColumn = startColumn;
        // this.endColumn = endColumn;
    }
}