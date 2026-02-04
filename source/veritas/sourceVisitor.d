module veritas.sourceVisitor;

import std.string;
import std.path;

import veritas.clang;
import veritas.ecosystem;


class VrtsSourceVisitor {
    VrtsEcosystem ecosystem;

    VrtsFunction funcContext;
    VrtsSourceFile sourceFile;

    void visitSourceFile(VrtsEcosystem ecosystem, VrtsSourceFile file) {
        this.ecosystem = ecosystem;
        this.sourceFile = file;
        // writeln("Extracting file: ", file.fullname);

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
            file.getPath.toStringz, 
            args.ptr, 
            cast(int)args.length,
            null,
            0,
            0x4000 | 0x400);
        // }
        CXCursor root = clang_getTranslationUnitCursor(tu);

        int[2] counts = [0, 0];
        clang_visitChildren(root, &sourceFileVisitor, cast(CXClientData)this);

        clang_disposeTranslationUnit(tu);
        clang_disposeIndex(index);
    }
    
    
    extern(C) static uint sourceFileVisitor(CXCursor cursor, CXCursor parent, CXClientData data) {
        VrtsSourceVisitor context = cast(VrtsSourceVisitor)data;
        auto sourceFile = context.sourceFile;
        
        int kind = clang_getCursorKind(cursor);

        if (kind == 8) {
            string name = cxToStr(cursor);

            auto funcDecl = context.ecosystem.addFunction(sourceFile, name);

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
        
        auto refCur = clang_getCursorReferenced(cursor);
        auto refkind = clang_getCursorKind(refCur);

        if (refkind == 8) { 
            string name = cxToStr(refCur);
            funcDecl.calls ~= new VrtsFunctionCall(0, funcDecl, name);
            
            return 1;
        }
       
        return 2; 
    }
}