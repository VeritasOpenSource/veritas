/**
 * Module provided package class and stuff
*/
module veritas.ecosystem.pkg;

import std.path;
import std.array;
import std.algorithm;
import std.file;

import veritas.ecosystem;
/** 
 * Class for package representation  
 */
class VrtsPackage {
private:
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
    ///
    this(string path, string name) {
        this.path = DirEntry(path);
        this.name = path.baseName;
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
}