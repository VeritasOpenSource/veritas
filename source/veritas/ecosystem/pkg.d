/**
 * Module provided package class and stuff
*/
module veritas.ecosystem.pkg;

import std.path;
import std.array;
import std.algorithm;
import std.file;

import veritas.ecosystem;
import veritas.model;
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