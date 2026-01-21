module veritas.ecosystem.sourceFile;

import std.file;

import veritas.ecosystem;

/** 
 * Class for represenation source file of package
 */
class VrtsSourceFile {
private:
	DirEntry         fileEntry;
    VrtsPackage     pkg;

public:
 
    ///
	this(VrtsPackage pkg, DirEntry fileEntry) {
        this.pkg = pkg;
		this.fileEntry = fileEntry;
	}
    
    ///
    string getPath() const {
        return fileEntry.name;
    }

    ///
    @trusted
    override size_t toHash() const {
        return 0;
    }

    ///
    override bool opEquals(Object o) const {
        VrtsSourceFile b = cast(VrtsSourceFile) o;
        return this.getPath == b.getPath;
    }
}