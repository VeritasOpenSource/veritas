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
        VrtsSourceFunctionDef   called;
    }

    Calling calling;

    this(string name) {
        this.calling.name = name;
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

        // VrtsSourceFunctionDef newDef; 
        if(func.empty) { 
            auto newDef = new VrtsSourceFunctionDef(name); 
            functions ~= newDef; 
            return newDef;
        }

        return func.front();
    }
}