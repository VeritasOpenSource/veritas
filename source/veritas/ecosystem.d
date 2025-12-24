module veritas.ecosystem;

import std.compiler;
import std.algorithm;
import std.array;
import std.stdio;

class VrtsSourceFunctionDef {
    //Name of function
    string name;
    //Source filename
    string filename;

    VrtsSourceFunctionCall[] calls;
    VrtsSourceFunctionCall[] callers;

    this(string name) {
        this.name = name;
    }
}

///Both-direction call entity 
class VrtsSourceFunctionCall {
    ///is called function already defined before?
    bool isDefined = false;

    ///Name used if its appered by caller to called
    ///Called can be used like a caller of function and called function
    union Calling {
        ///if not defined
        string name;
        ///if defined and is in ecosystem
        VrtsSourceFunctionDef   target;
    }

    Calling calling;
    alias calling this;

    this(string name) {
        this.calling.name = name;
    }

    string getCallName() {
        if(isDefined)
            return target.name;

        return calling.name;
    }
}


class VrtsSourceFile {
	string path;
	string filename;

	this(string path, string filename) {
		this.path = path;
		this.filename = filename;
	}
}

//Main DB  
class VrtsEcosystem {
    VrtsSourceFunctionDef[]  functions;
    // VrtsFunction[]  undefined;

    VrtsSourceFunctionDef addFunction(string name) {
        auto func = functions
            .find!((a) => cmp(a.name, name) == 0);

        if(func.empty) { 
            auto newDef = new VrtsSourceFunctionDef(name); 
            functions ~= newDef; 
            return newDef;
        }

        return func.front();
    }

    void relinkCallings() {
        foreach(func; functions) {
            relinkFunctionCall(func);
        }
    }

    void relinkFunctionCall(VrtsSourceFunctionDef def) {
        foreach(call; def.calls) {
            foreach(needle; functions) {
                if(!call.isDefined && call.name == needle.name) {
                    call.isDefined = true;
                    call.target = needle;

                    auto caller = new VrtsSourceFunctionCall(def.name);
                    caller.isDefined = true;
                    caller.target = def;
                    needle.callers ~= caller;

                    break;
                }
            }
        }
    }

    auto getFunctionsWithoutCalls() {
        return functions.filter!((a) => a.calls.length == 0);
    }    
}