module veritas.ecosystem;

import std.compiler;
import std.algorithm;
import std.array;
import std.stdio;
import veritas.plist;
import std.string;

class VrtsProblem {
    string desc;
    // uint line;
    // strib
}

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
    // string reportFile;

    @property
    @trusted
    nothrow
    string fullname() const {
        return path ~ filename;
    }

	this(string path, string filename) {
		this.path = path;
		this.filename = filename;
	}

    override size_t toHash() const @trusted nothrow {
        return hashOf(this.filename); 
    }

    override bool opEquals(Object o) const {
        VrtsSourceFile b = cast(VrtsSourceFile) o;
        return this.fullname == b.fullname;
    }
}

class VrtsRing {
    uint level;
    VrtsSourceFunctionDef[]     functions; 
} 

//Main DB  
class VrtsEcosystem {
    VrtsRing[]                  rings;
    VrtsSourceFunctionDef[]     functions;
    VrtsSourceFile[]            sourceFiles;
    // VrtsSourceFunctionDef[]     
    // VrtsFunction[]  undefined;

    void addSourceFile(VrtsSourceFile file) {
        sourceFiles ~= file;
    }

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

    void createFirstRing() {
        VrtsRing ring0 = new VrtsRing();

        ring0.functions = functions.filter!((a) => a.calls.length == 0).array;
    }

    bool isFunctionInRing(int ringLevel, VrtsSourceFunctionDef func) {
        return rings[ringLevel]
            .functions
            .canFind!((a) =>
                a == func
            );
    }    

    bool isAllCallingsinRing(int ringLevel, VrtsSourceFunctionDef[] funcs) {
        return funcs
            .all!((a) => this.isFunctionInRing(ringLevel, a));
    }
}