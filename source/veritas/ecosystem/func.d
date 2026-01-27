module veritas.ecosystem.func;

import std.algorithm;

import veritas.ecosystem;
import veritas.reportparser;
import veritas.triggering;

class VrtsFunction {
    uint id;
    //Name of function in own package
    string name;

    VrtsSourceFile file;

    VrtsSourceLocation      declarationLocation;
    VrtsSourceLocationRange definitionLocation;
    ///Reports about function
    VrtsReport[] reports;
    Triggering[] triggers;

    VrtsFunctionCall[] calls;
    VrtsFunctionCall[] calledBy;

    this(string name) {
        this.name = name;
    }

    string getTaggedName() {
        return file.getPath ~":"~name;
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

    void collectTriggers() {
        import std.stdio;
        auto ownTrigger = new Triggering(this, cast(int)reports.length);

        if(reports.length > 0) {
            triggers ~= ownTrigger;
        }

        Triggering[] externalTriggers; 
        foreach(call; calls) {
            bool defined_ = call.isDefined;
            if(defined_ == true) {
                auto triggers = call.getTargetFunction.triggers;
                foreach(exTr; triggers) {
                    if(!externalTriggers.canFind!(a => a is exTr))
                    externalTriggers ~= triggers;
                }
            }
        }

        foreach(exTr; externalTriggers) {
            exTr.count++;
        }

        triggers ~= externalTriggers;
    }

    auto reportsCount() => reports.length;
}