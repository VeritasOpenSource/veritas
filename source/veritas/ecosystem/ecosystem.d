module veritas.ecosystem.ecosystem;

import std.algorithm;
import std.array;

import veritas.reportparser;
import veritas.ecosystem;

//Main DB  
class VrtsEcosystem {
    VrtsPackage[]               packages;

    VrtsRing[]                  rings;
    VrtsFunction[]              functions;
    VrtsSourceFile[]            sourceFiles;

    void addSourceFile(VrtsSourceFile file) {
        sourceFiles ~= file;
    }

    VrtsFunction addFunction(string name) {
        auto func = functions
            .find!((a) => cmp(a.name, name) == 0);

        if(func.empty) { 
            auto newDef = new VrtsFunction(name); 
            functions ~= newDef; 
            return newDef;
        }

        return func.front();
    }

    void relinkCalls() {
        foreach(func; functions) {
            relinkFunctionCall(func);
        }
    }

    void relinkFunctionCall(VrtsFunction def) {
        foreach(call; def.calls) {
            foreach(needle; functions) {
                if(!call.isDefined && call.getCallName == needle.name) {
                    call.defineTarget(needle);
                    needle.calledBy ~= call;

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

    bool isFunctionInRing(int ringLevel, VrtsFunction func) {
        return rings[ringLevel]
            .functions
            .canFind!((a) =>
                a == func
            );
    }    

    bool isAllCallingsinRing(int ringLevel, VrtsFunction[] funcs) {
        return funcs
            .all!((a) => this.isFunctionInRing(ringLevel, a));
    }

    VrtsRing getNextRing(uint level) {
        if(rings.length - 1 < level) {
            return new VrtsRing();
        }
        else if(rings.length - 1 >= level) {
            return rings[level];
        }

        assert(0);
    }

    void buildRingsIerarchy() {
        auto funcs = functions.dup;

        VrtsRing ring0;
        if(rings.length == 0)
            ring0 = new VrtsRing();
        else
            ring0 = rings[0];

        foreach(func; functions) {
            if(func.isAllCallsUndefined) {
                ring0.functions ~= func;
            }
        }

        if(rings.length == 0)
            rings ~= ring0;
        // else
            // ring0 = rings[0];

        funcs = funcs.removeElements(ring0.functions);

        uint level = 1;
        while(funcs.length > 0) {
            auto ring = this.getNextRing(level);

            foreach(func_; funcs) {
                auto calls = func_.calls.filter!(a => a.isDefined).array;

                if(checkAllCallsInRings(calls)) {
                    ring.functions ~= func_;
                }
            }

            if(ring.functions.length == 0)
                break;

            ring.level = level;

            if(rings.length - 1 < level)
                rings ~= ring;

            level++;

            funcs = funcs.removeElements(ring.functions);
        }
    }

    void processReports(VrtsReport[] reports) {
        foreach(report; reports) {
            foreach(function_; functions.filter!(a => a.definitionLocation !is null)) {
                if( report.filename == function_.definitionLocation.filename &&
                    report.line > function_.definitionLocation.start.line &&
                    report.line < function_.definitionLocation.end.line)

                    function_.reports ~= report;
            }
        }
    }

    bool checkAllCallsInRings (VrtsFunctionCall[] calls) {
        bool allCallsInRings = true;
        foreach(call; calls) {
            bool isCallInRing = false;
            foreach(ring; rings) {  
               if(ring.isFunctionInRing(call.getTargetFunction))
                    isCallInRing = true;
            }

            if(!isCallInRing)
                allCallsInRings = false;
        }

        return allCallsInRings;
    }
}

T[] removeElements(T)(ref T[] array, T[] needles) {
    T[] newArray;

    foreach(elem; array) {
        if(needles.canFind!(a => a == elem)) {
            continue;
        }

        newArray ~= elem;
    }

    return newArray;
}