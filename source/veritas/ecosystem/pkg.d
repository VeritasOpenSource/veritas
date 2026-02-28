/**
 * Module provided package class and stuff
*/
module veritas.ecosystem.pkg;

import std.path;
import std.array;
import std.algorithm;
import std.file;
import std.stdio;
import std.conv;

import veritas.ecosystem;
import veritas.model;
import std.compiler;

class VrtsMetaData {
    File file;

    string[] data;

    this(string path) {
        file = File(path);
        data = file
            .byLineCopy
            // .to!string
            .array;

        file.close();
    }

    static auto load(string path) {
        return new VrtsMetaData(path);
    }

    string getConfigCommand() {
        for(int i = 0; i < data.length; i++) {
            if(data[i] == "Configure")
                return data[i+1];
        }

        assert(0, "Config command not found!");
    }

    string getPatch() {
        for(int i = 0; i < data.length; i++) {
            if(data[i] == "Makepatch")
                return data[i+1];
        }

        assert(0, "Makepatch string not found!");
    }

    string getMakeCommand() {
        for(int i = 0; i < data.length; i++) {
            if(data[i] == "Make")
                return data[i+1];
        }

        assert(0, "Make command not found!");
    }
}

/** 
 * Class for package representation  
 */
class VrtsPackage {
private:
    uint id;
    ///name of package
    string name;

    ///absolute path to package dir
    /// Example: /home/x/project/
    DirEntry path;
    
    ///Provided lists
    VrtsFunction[]          functions;
    ///ditto
    VrtsSourceFile[]        sourceFiles;

public:
    void clear() {
        functions.length = 0;
    }
    ///
    this(uint id, string path, string name) {
        this.id = id;
        this.path = DirEntry(path.buildNormalizedPath);
        this.name = path.baseName;
    }

    auto getId() {
        return id;
    }

    /// 
    auto getSourceFiles() {
        return sourceFiles;
    }

    auto setSourceFiles(VrtsSourceFile[] files) {
        sourceFiles = files;
    }

    ///
    string getPath() const => this.path;
    ///
    string getName() const => this.name;
    
    ///
    void addFunction(VrtsFunction func) {
        functions ~= func;
    }

    ///
    void addSourceFile(VrtsSourceFile sf) {
        sourceFiles ~= sf;
    }

    ///
    void scanForSourceFiles() {
        auto res = dirEntries(path,"*.{h,c}",SpanMode.depth)
            .filter!(a => a.isFile)
            .filter!(a => !a.baseName.startsWith("tst-"))
            .filter!(a => !a.baseName.startsWith("test-"))
            .map!((a) => new VrtsSourceFile(this, a))
            .each!((a) => this.addSourceFile(a));
    }

    auto getFunctions() {
        return functions;
    }

    static VrtsPackage buildFromModel(VrtsModelPackage pkg_) {        
        auto pkg = new VrtsPackage(pkg_.id, pkg_.path, pkg_.name);
        return pkg;
    }
}