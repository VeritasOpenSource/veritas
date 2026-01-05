module veritas.ecosystem.call;

import veritas.ecosystem;

///Both-direction call entity 
class VrtsFunctionCall {
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