module veritas.ecosystem.rings.ringsAnalyzer;

import veritas.ecosystem.rings;
import veritas.ecosystem.calls;
import veritas.ecosystem.functions;
import veritas.ecosystem.ecosystem;
import std.array;
import std.algorithm;
import veritas.ipc;
import std.stdio;


class VrtsRingsAnalyzer {
	
	VrtsEventBus eventBus;
	VrtsRingsCollector	collector;

	VrtsCallsCollector callsCollector;
	VrtsFunctionsCollector functionsCollector;

	ref auto rings() inout @property {
		return collector.storage.data;
	}

	ref auto calls() inout @property {
		return callsCollector.storage.data;
	}

	ref auto functions() inout @property {
		return functionsCollector.storage.data;
	}

	// this(VrtsEcosystem ecosystem) {
	// 	callsCollector = ecosystem.
	// }

    // ///
	this(VrtsEcosystem ecosystem) {
		collector = new VrtsRingsCollector;

		callsCollector = ecosystem.callsCollector;
		functionsCollector = ecosystem.funtionsCollector;
	}

	void setEventBus(VrtsEventBus eventBus) {
		this.eventBus = eventBus;
	}
    void createFirstRing() {
        VrtsRing ring0 = new VrtsRing();

        ring0.functions = callsCollector.getFunctionsWithoutCalls().array;
    }

    // ///
    bool isFunctionInRing(int ringLevel, VrtsFunction func) {
        return collector.storage[ringLevel]
            .functions
            .canFind!((a) =>
                a == func
            );
    }    

    ///
    bool isAllCallingsinRing(int ringLevel, VrtsFunction[] funcs) {
        return funcs
            .all!((a) => this.isFunctionInRing(ringLevel, a));
    }

    // ///
    VrtsRing getNextRing(uint level) {
        if(rings.length - 1 < level) {
            eventBus.publish(new EventAddRing(level));
            return new VrtsRing();
        }
        else if(rings.length - 1 >= level) {
            return rings[level];
        }

        assert(0);
    }

    ///
    void buildRingsIerarchy() {
        auto funcs = functions.dup;

        rings.length = 0;

        VrtsRing ring0;
        if(rings.length == 0)
            ring0 = new VrtsRing();
        else
            ring0 = rings[0];

        foreach(func; functions) {
            if(func.isAllCallsUndefined) {
                ring0.functions ~= func;
                // eventBus.publish(new EventFuncToRing(0, func.getTaggedName.baseName));
            }
        }

        if(rings.length == 0) {
            rings ~= ring0;
            eventBus.publish(new EventAddRing(0));
        }

        // foreach(func; rings[0].functions) {
        //     eventBus.publish(new EventFuncToRing(0, func.getTaggedName.baseName));
        // }

        funcs = funcs.removeElements(ring0.functions);

        uint level = 1;
        while(funcs.length > 0) {
            auto ring = this.getNextRing(level);

            foreach(func_; funcs) {
                auto calls = func_.calls.filter!(a => a.isDefined).array;

                if(checkAllCallsInRings(calls)) {
                    ring.functions ~= func_;
                    writeln(func_.getTaggedName);
                    // eventBus.publish(new EventFuncToRing(level, func_.getTaggedName.baseName));
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

    // /
    // void processReports(VrtsReport[] reports) {
    //     this.reports = reports;
    //     foreach(report; reports) {
    //         foreach(function_; functions.filter!(a => a.definitionLocation !is null)) {
    //             if( report.location.filename == function_.definitionLocation.filename &&
    //                 report.location.line > function_.definitionLocation.start.line &&
    //                 report.location.line < function_.definitionLocation.end.line)

    //                 function_.reports ~= report;
    //         }
    //     }
    // }

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