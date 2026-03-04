/**
 * Module provided package class and stuff
*/
module veritas.ecosystem.packages.pkg;

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

    string name() @property {
        for(int i = 0; i < data.length; i++) {
            if(data[i] == "Name")
                return data[i+1];
        }

        assert(0, "Name string not found!");
    }

    string path() @property {
        for(int i = 0; i < data.length; i++) {
            if(data[i] == "Path")
                return data[i+1];
        }

        assert(0, "Path string not found!");
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

    VrtsMetaData metadata;

    ///absolute path to package dir
    /// Example: /home/x/project/
    DirEntry path;
    
    ///Provided lists
    VrtsFunction[]          functions;
    ///ditto

public:
    void clear() {
        functions.length = 0;
    }
    ///
    this(uint id, VrtsMetaData data) {
        this.id = id;
        this.metadata = data;
    }

    auto getId() {
        return id;
    }

    auto getMetadata() {
        return metadata;
    }

    ///
    string getPath()  => this.metadata.path;
    ///
    string getName()  => this.metadata.name;
    
    ///
    void addFunction(VrtsFunction func) {
        functions ~= func;
    }
    
    auto getFunctions() {
        return functions;
    }

    // static VrtsPackage buildFromModel(VrtsModelPackage pkg_) {        
    //     auto pkg = new VrtsPackage(pkg_.id, pkg_.path, pkg_.name);
    //     return pkg;
    // }
}