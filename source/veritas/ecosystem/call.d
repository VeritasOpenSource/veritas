///Module for call representation
module veritas.ecosystem.call;

import veritas.ecosystem;

///Both-direction call class 
class VrtsFunctionCall {
    ///is called function already defined before?
    bool isDefined = false;

    VrtsFunction    source;

    ///Name used if its appered by caller to called
    ///Called can be used like a caller of function and called function
    union CallImpl {
        ///if not defined
        string name;
        ///if defined and in ecosystem
        VrtsFunction   target;
    }

    CallImpl call;
    alias call this;

    this(string name) {
        this.call.name = name;
    }

    string getCallName() {
        if(isDefined)
            return target.name;

        return call.name;
    }

    VrtsFunction    getSourceFunctionName() {
        return this.source;
    }
}