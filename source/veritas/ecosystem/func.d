module veritas.ecosystem.func;

import veritas.ecosystem.ecosystem;
import veritas.reportparser;
import veritas.ecosystem.location;

class VrtsSourceFunctionDef {
    //Name of function
    string name;
    //Source filename
    // VrtsSourceFile file;

    VrtsSourceLocation      declarationLocation;
    VrtsSourceLocationRange definitionLocation;

    // uint startColumn;
    // uint endColumn;
    ///Reports about function
    VrtsReport[] reports;


    VrtsSourceFunctionCall[] calls;
    VrtsSourceFunctionCall[] callers;

    this(string name) {
        this.name = name;
    }

    void setLocation(bool isDefinition, string filename,  uint startLine, uint endLine , uint startColumn, uint endColumn) {
        if(isDefinition) {
            definitionLocation = new VrtsSourceLocationRange(filename, startLine, startColumn, endLine, endColumn);
        }
        else {
            declarationLocation = new VrtsSourceLocation(filename, startLine, startColumn);
        }
    }
}