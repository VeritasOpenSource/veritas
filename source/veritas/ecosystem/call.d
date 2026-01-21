///Module for call representation
module veritas.ecosystem.call;

import veritas.ecosystem;

///Both-direction call class 
class VrtsFunctionCall {
private:    
    ///is called function already defined before?
    bool defined = false;

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

public:
    ///
    this(VrtsFunction source, string name) {
        this.call.name = name;
    }

    ///
    bool isDefined() => defined;
    ///
    void defineTarget(VrtsFunction func) {
        defined = true;
        this.target = func;
    }

    ///
    string getCallName() {
        if(isDefined)
            return target.name;

        return call.name;
    }

    ///
    VrtsFunction    getSourceFunction() {
        return this.source;
    }

    ///
    VrtsFunction    getTargetFunction() {
        return this.target;
    }
}