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
        return pkg.path ~ filename;
    }

    ///
    string getTaggedName() const nothrow {
        return pkg.name ~ "." ~ filename;
    }

    ///

    ///
    @trusted
    override size_t toHash() const {
        return hashOf(this.getTaggedName); 
    }

    ///
    override bool opEquals(Object o) const {
        VrtsSourceFile b = cast(VrtsSourceFile) o;
        return this.getTaggedName == b.getTaggedName;
    }
}