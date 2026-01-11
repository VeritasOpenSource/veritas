module veritas.ecosystem.sourceFile;

import veritas.ecosystem;

/** 
 * Class for represenation source file of package
 */
class VrtsSourceFile {
private:
	string filename;
    VrtsPackage     pkg;

public:
 
	this(VrtsPackage pkg, string filename) {
        this.pkg = pkg;
		this.filename = filename;
	}
    
    ///
    string getPathName() const {
        return filename;
    }

    ///
    string getTaggedName() const {
        return pkg.getName ~ "." ~ filename;
    }

    ///
    @trusted
    override size_t toHash() const {
        return 0;
    }

    ///
    override bool opEquals(Object o) const {
        VrtsSourceFile b = cast(VrtsSourceFile) o;
        return this.getTaggedName == b.getTaggedName;
    }
}