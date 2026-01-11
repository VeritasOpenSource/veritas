module veritas.ecosystem.func;

import std.algorithm;

import veritas.ecosystem;
import veritas.reportparser;

class VrtsFunction {
    //Name of function in own package
    string name;

    VrtsSourceFile file;

    VrtsSourceLocation      declarationLocation;
    VrtsSourceLocationRange definitionLocation;
    ///Reports about function
    VrtsReport[] reports;


    VrtsFunctionCall[] calls;
    VrtsFunctionCall[] calledBy;

    this(string name) {
        this.name = name;
    }

    string getTaggedName() {
        return file.getTaggedName ~"."~name;
    }

    void setLocation(bool isDefinition, string filename,  uint startLine, uint startColumn, uint endLine, uint endColumn) {
        if(isDefinition) {
            definitionLocation = new VrtsSourceLocationRange(filename, startLine, startColumn, endLine, endColumn);
        }
        else {
            declarationLocation = new VrtsSourceLocation(filename, startLine, startColumn);
        }
    }

    bool isAllCallsUndefined() {
        return calls.all!(a => !a.isDefined);
    }
}