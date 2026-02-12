///
module veritas.ecosystem.ecosystem;

import std.algorithm;
import std.array;
import std.path;
import std.file;

import veritas.reportparser;
import veritas.ecosystem;
import veritas.ipc.events;
import veritas.triggering;
import veritas.model;

/// 
class VrtsEcosystem {
    VrtsEventBus eventBus;

    VrtsPackage[]               packages;

    VrtsRing[]                  rings;
    
    VrtsFunction[]              functions;
    VrtsSourceFile[]            sourceFiles;
    VrtsFunctionCall[]          calls;
    VrtsReport[]                reports;

    Triggering[] triggers;

    void setEventBus(VrtsEventBus eventBus) {
        this.eventBus = eventBus;
    }

    auto collectCalls() {
        uint i;
        foreach(func; functions) {
            func.calls.each!((a) => (a.setId(i++)));
            calls ~= func.calls;
        }

        return calls.length;
    }

    /// 
    void addPackage(VrtsPackage pkg) {
        packages ~= pkg;

        eventBus.publish(new EventProjectAdded(pkg.getPath));
        pkg.scanForSourceFiles();
    }

    void addPackage(string name, string path) {
        auto pkg = new VrtsPackage(cast(uint)packages.length, name, path);
        packages ~= pkg;

        eventBus.publish(new EventProjectAdded(pkg.getPath));
        pkg.scanForSourceFiles();
    }

    ///
    void recollectData() {
        int i = 0;

        sourceFiles = packages.map!(a => a.getSourceFiles).join.array;

        sourceFiles.each!((ref a) => a.setId(i++));
    }

    ///
    void addSourceFile(VrtsSourceFile file) {
        sourceFiles ~= file;
    }

    ///
    bool checkFunctionEdentity(VrtsFunction func1, VrtsSourceFile sourceFile2, string name) {
        auto pathFile = func1.file.getPath.dirName;

        auto pathCheckingFile = sourceFile2.getPath().dirName;
        return  pathFile == pathCheckingFile &&
                 name == func1.name;
    }

    ///
    VrtsFunction addFunction(VrtsSourceFile sourceFile, string name) {
        auto func = functions
            .find!((a) => checkFunctionEdentity(a, sourceFile, name));

        VrtsFunction def;

        if(func.empty) { 
            def = new VrtsFunction(cast(uint) functions.length, name); 
            def.file = sourceFile;
            functions ~= def; 
            sourceFile.getPackage().addFunction(def);
        }
        else {
            def = func.front();
            def.file = sourceFile;
        }

        return def;
    }

    ///
    void relinkCalls() {
        foreach(func; functions) {
            relinkFunctionCall(func);
        }
    }

    ///
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

    ///
    auto getFunctionsWithoutCalls() {
        return functions.filter!((a) => a.calls.length == 0);
    }

    ///
    void createFirstRing() {
        VrtsRing ring0 = new VrtsRing();

        ring0.functions = functions.filter!((a) => a.calls.length == 0).array;
    }

    ///
    bool isFunctionInRing(int ringLevel, VrtsFunction func) {
        return rings[ringLevel]
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

    ///
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

        foreach(func; rings[0].functions) {
            eventBus.publish(new EventFuncToRing(0, func.getTaggedName.baseName));
        }

        funcs = funcs.removeElements(ring0.functions);

        uint level = 1;
        while(funcs.length > 0) {
            auto ring = this.getNextRing(level);

            foreach(func_; funcs) {
                auto calls = func_.calls.filter!(a => a.isDefined).array;

                if(checkAllCallsInRings(calls)) {
                    ring.functions ~= func_;
                    // writeln(func_.getTaggedName);
                    eventBus.publish(new EventFuncToRing(level, func_.getTaggedName.baseName));
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

    ///
    void processReports(VrtsReport[] reports) {
        this.reports = reports;
        foreach(report; reports) {
            foreach(function_; functions.filter!(a => a.definitionLocation !is null)) {
                if( report.location.filename == function_.definitionLocation.filename &&
                    report.location.line > function_.definitionLocation.start.line &&
                    report.location.line < function_.definitionLocation.end.line)

                    function_.reports ~= report;
            }
        }
    }

    ///
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

    auto getPackages() {
        return packages;
    }

    auto collectTriggers() {
        import std.stdio;
        foreach(ring; rings) {
            foreach(func; ring.functions) {
                func.collectTriggers(cast(uint)triggers.length);

                if(func.reportsCount > 0)
                    triggers ~= func.triggers[0];

            }
        }

        auto trig = triggers.sort!((a, b) => a.count < b.count);
        
        trig.each!(a => writeln(a.func.name, " ", a.count));

        return trig.length;
    }

    auto buildModel() {
        VrtsModel model;

        foreach(pkg; packages) {
            auto modelPackage = VrtsModelPackage();
            modelPackage.id = pkg.getId();
            modelPackage.name = pkg.getName;
            modelPackage.path = pkg.getPath;

            foreach(func; pkg.getFunctions)
                modelPackage.functionsIds ~= func.id;

            foreach(sourceFile; pkg.getSourceFiles)
                modelPackage.sourceFilesIds ~= sourceFile.getId;

            model.packages ~= modelPackage;

        }

        foreach(sourceFile; sourceFiles) {
            auto modelSourceFile = VrtsModelSourceFile();
            modelSourceFile.id = sourceFile.getId();
            modelSourceFile.path = sourceFile.getFileEntry;
            modelSourceFile.packageId = sourceFile.getPackage.getId();

            model.files ~= modelSourceFile;
        }

        foreach(ring; rings) {
            auto modelRing = VrtsModelRing();
            modelRing.id = ring.level;
            // modelRing.path = ring.getFileEntry;
            foreach(func; ring.functions)
                modelRing.functionsIds ~= func.id;

            model.rings ~= modelRing;
        }

        foreach(func; functions) {
            auto modelFunc = VrtsModelFunction();
            modelFunc.id = func.id;
            modelFunc.name = func.name;
            modelFunc.sourceFileId = func.file.getId;

            if(func.declarationLocation !is null) {
                modelFunc.declarationLocation = VrtsModelSourceLocation(
                    func.declarationLocation.filename,
                    func.declarationLocation.line,
                    func.declarationLocation.column
                );
            }
            if(func.definitionLocation !is null) {
                modelFunc.definitionLocation = 
                    VrtsModelSourceLocationRange(
                        VrtsModelSourceLocation(
                            func.definitionLocation.start.filename,
                            func.definitionLocation.start.line,
                            func.definitionLocation.start.column
                        ),
                        VrtsModelSourceLocation(
                            func.definitionLocation.end.filename,
                            func.definitionLocation.end.line,
                            func.definitionLocation.end.column
                        )
                    );
            }

            foreach(report; func.reports)
                modelFunc.reportsIds ~= report.id;
            foreach(trigger; func.triggers)
                modelFunc.triggersId ~= trigger.id;
            foreach(call; func.calls)
                modelFunc.callsIds ~= call.getId;
            foreach(called; func.calledBy)
                modelFunc.calledByIds ~= called.getId;

            model.functions ~= modelFunc;
        }

        foreach(call; calls) {
            auto modelCall = VrtsModelCall();
            modelCall.id = call.getId;
            modelCall.isDefined = call.isDefined;
            modelCall.sourceId = call.getSourceFunction.id;
            // modelCall.path = call.getFileEntry;
            if(!call.isDefined) {
                modelCall.name = call.getCallName; 
            }
            else {
                modelCall.targetId = call.getTargetFunction.id;
            }
            // modelCall.call = call.call;

            model.calls ~= modelCall;
        }

        foreach(trigger; triggers) {
            auto modelTrigger = VrtsModelTriggering();
            modelTrigger.id = trigger.id;
            modelTrigger.functionId = trigger.func.id;
            modelTrigger.count = trigger.count;
            // modelTrigger.path = trigger.getFileEntry;
            // modelTrigger.trigger = trigger.call;

            model.triggerings ~= modelTrigger;
        }

        foreach(report; reports) {
            auto modelReport = VrtsModelReport();
            modelReport.id = report.id;
            modelReport.location = VrtsModelSourceLocation(
                report.location.filename,
                report.location.line,
                report.location.column
            );
            modelReport.description = report.description;
            // modelReport.path = report.getFileEntry;
            // modelReport.report = report.call;

            model.reports ~= modelReport;
        }

        return model;
    }

    static VrtsEcosystem buildFromModel(VrtsModel model) {
        auto result = new VrtsEcosystem();

        VrtsPackage[uint]      packageById;
        VrtsSourceFile[uint]   fileById;
        VrtsFunction[uint]     functionById;
        VrtsFunctionCall[uint] callById;
        VrtsReport[uint]       reportById;
        Triggering[uint]       triggerById;

        foreach (pkgModel; model.packages) {
            auto pkg = VrtsPackage.buildFromModel(pkgModel);
            result.packages ~= pkg;
            packageById[pkg.getId()] = pkg;
        }

        foreach (fileModel; model.files) {
            auto pkg = packageById[fileModel.packageId];

            auto entry = DirEntry(fileModel.path);
            auto file = new VrtsSourceFile(pkg, entry);
            file.setId(fileModel.id);

            pkg.addSourceFile(file);
            result.sourceFiles ~= file;
            fileById[file.getId()] = file;
        }

        foreach (funcModel; model.functions) {
            auto file = fileById[funcModel.sourceFileId];

            auto func = new VrtsFunction(funcModel.id, funcModel.name);
            func.file = file;
            file.getPackage().addFunction(func);

            if (funcModel.declarationLocation.filename.length > 0) {
                func.declarationLocation = new VrtsSourceLocation(
                    funcModel.declarationLocation.filename,
                    funcModel.declarationLocation.line,
                    funcModel.declarationLocation.column
                );
            }

            if (funcModel.definitionLocation.start.filename.length > 0) {
                func.definitionLocation = new VrtsSourceLocationRange(
                    funcModel.definitionLocation.start.filename,
                    funcModel.definitionLocation.start.line,
                    funcModel.definitionLocation.start.column,
                    funcModel.definitionLocation.end.line,
                    funcModel.definitionLocation.end.column
                );
            }

            result.functions ~= func;
            functionById[func.id] = func;
        }

        foreach (reportModel; model.reports) {
            auto report = new VrtsReport(reportModel.id);

            report.location = new VrtsSourceLocation(
                reportModel.location.filename,
                reportModel.location.line,
                reportModel.location.column
            );

            report.description = reportModel.description;

            result.reports ~= report;
            reportById[report.id] = report;
        }

        foreach (callModel; model.calls) {
            auto sourceFunc = functionById[callModel.sourceId];

            auto call = new VrtsFunctionCall(callModel.id, sourceFunc, "");
            call.isDefined = callModel.isDefined;

            if (!callModel.isDefined)
                call.setCallName(callModel.name);

            result.calls ~= call;
            callById[call.getId()] = call;
        }

        foreach (funcModel; model.functions) {
            auto func = functionById[funcModel.id];

            foreach (callId; funcModel.callsIds) {
                auto call = callById[callId];
                func.calls ~= call;
            }

        }

        foreach (callModel; model.calls) {
            if (!callModel.isDefined)
                continue;

            auto call = callById[callModel.id];
            auto target = functionById[callModel.targetId];

            call.defineTarget(target);
            target.calledBy ~= call;
        }

        foreach (trModel; model.triggerings) {
            auto func = functionById[trModel.functionId];

            auto trigger = new Triggering(trModel.id, func, trModel.count);

            result.triggers ~= trigger;
            triggerById[trigger.id] = trigger;
        }

        foreach (funcModel; model.functions) {
            auto func = functionById[funcModel.id];

            foreach (triggerId; funcModel.triggersId) {
                auto trigger = triggerById[triggerId];
                func.triggers ~= trigger;
            }
        }

        foreach (funcModel; model.functions) {
            auto func = functionById[funcModel.id];

            foreach (reportId; funcModel.reportsIds) {
                func.reports ~= reportById[reportId];
            }
        }

        foreach (ringModel; model.rings) {
            auto ring = new VrtsRing();
            ring.level = ringModel.id;

            foreach (funcId; ringModel.functionsIds) {
                ring.functions ~= functionById[funcId];
            }

            result.rings ~= ring;
        }

        return result;
    }

}



///
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