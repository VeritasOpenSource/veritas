/**
 * Module provided package class and stuff
*/
module veritas.ecosystem.pkg;

import veritas.ecosystem;

/** 
 * Class for package representation  
 */
class VrtsPackage {
private:
    ///name of package
    string name;

    ///absolute path to package dir
    string path;
    
    ///Provided lists
    VrtsFunction[]          functions;
    ///ditto
    VrtsSourceFile[]        sourceFiles;

public:
    ///
    this(string path, string name) {
        this.path = path;
        this.name = name;
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
}