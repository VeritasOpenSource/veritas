module veritas.ecosystem;

import std.compiler;

class VrtsSourceFunctionDef {
    //Name of function
    string name;
    //Source filename
    string filename;

    string[] calls;

    this(string name) {
        this.name = name;
    }
}

class VrtsSourceFunctionCall {
    string name;
}


//Main DB  
class Ecosystem {
    VrtsSourceFunctionDef[]  functions;
    // VrtsFunction[]  undefined;

    void addFunction(string name) {
        functions ~= new VrtsSourceFunctionDef(name);
    }
}