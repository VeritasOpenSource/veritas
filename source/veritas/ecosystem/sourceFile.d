module veritas.ecosystem.sourceFile;

import veritas.ecosystem;

class VrtsSourceFile {
    
	string path;
	string filename;
    // string reportFile;

    @property
    @trusted
    nothrow
    string fullname() const {
        return path ~ filename;
    }

	this(string path, string filename) {
		this.path = path;
		this.filename = filename;
	}

    override size_t toHash() const @trusted nothrow {
        return hashOf(this.filename); 
    }

    override bool opEquals(Object o) const {
        VrtsSourceFile b = cast(VrtsSourceFile) o;
        return this.fullname == b.fullname;
    }
}