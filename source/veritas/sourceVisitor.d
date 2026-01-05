module veritas.sourceVisitor;

import std.stdio;
import std.string;

import veritas.clang;
import veritas.ecosystem;
import std.algorithm;
import std.range;
import std.array;
import std.path;


class VrtsSourceVisitor {
    VrtsEcosystem ecosystem;

    VrtsSourceFunctionDef funcContext;

    void visitSourceFile(VrtsEcosystem ecosystem, VrtsSourceFile file) {
        this.ecosystem = ecosystem;
        // writeln("Extracting file: ", file.filename);

        CXIndex index = clang_createIndex(0, 0);

        CXTranslationUnit tu;
        
        const (char)*[] args;

        // args ~="-xc".toStringz;
        // args ~= "-w".toStringz;                    
        // args ~= "-Wno-everything".toStringz;       
        // args ~= "-Wno-error".toStringz;            
        // args ~= "-ferror-limit=1".toStringz;       
        // args ~= "-Wno-missing-include-dirs".toStringz;
        // args ~= "-Wno-implicit-function-declaration".toStringz;
        // args ~= "-Wno-missing-include-dirs".toStringz;

        args ~= "-nostdlib".toStringz;
        args ~= "-nostdinc".toStringz;

        tu = clang_parseTranslationUnit(index, 
            (file.path ~ file.filename).toStringz, 
            args.ptr, 
            cast(int)args.length,
            null,
            0,
            0x4000);
        // }
        CXCursor root = clang_getTranslationUnitCursor(tu);

        int[2] counts = [0, 0];
        clang_visitChildren(root, &sourceFileVisitor, cast(CXClientData)this);

        clang_disposeTranslationUnit(tu);
        clang_disposeIndex(index);
    }
    
    
    extern(C) static uint sourceFileVisitor(CXCursor cursor, CXCursor parent, CXClientData data) {
        VrtsSourceVisitor context = cast(VrtsSourceVisitor)data;
        
        int kind = clang_getCursorKind(cursor);

        if (kind == 8) {
            string name = cxToStr(cursor);

            auto funcDecl = context.ecosystem.addFunction(name);

            CXSourceRange range = clang_getCursorExtent(cursor);
            CXSourceLocation start = clang_getRangeStart(range);
            CXSourceLocation end = clang_getRangeEnd(range);
            
            CXFile file;
            uint start_line, end_line;

            clang_getFileLocation(start, file, &start_line, null, null);
            clang_getFileLocation(end, file, &end_line, null, null);

            if(clang_isCursorDefinition(cursor)) {
                funcDecl.setLocation(true, parent.cxToStr().baseName, start_line, 0, end_line, 0);

                context.funcContext = funcDecl;
                clang_visitChildren(cursor, &functionVisitor, data);
            }
            else {
                funcDecl.setLocation(false, parent.cxToStr().baseName, start_line, 0, end_line, 0);
            }
            return 1;
        }
       
        return 2; 
    }

    extern(C) static uint functionVisitor(CXCursor cursor, CXCursor parent, CXClientData data) {
        VrtsSourceVisitor context = cast(VrtsSourceVisitor)data;
        auto funcDecl = context.funcContext;
        // string nameCursor = cxToStr(cursor);
        
        auto refCur = clang_getCursorReferenced(cursor);
        auto refkind = clang_getCursorKind(refCur);

        if (refkind == 8) { 
            string name = cxToStr(refCur);
            funcDecl.calls ~= new VrtsSourceFunctionCall(name);
            
            return 1;
        }
       
        return 2; 
    }
}