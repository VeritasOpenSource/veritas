module veritas.reportparser;

import veritas.ecosystem;
import std.file;
import std.json;
import sysio = std.stdio;
import std.path;
import std.array;


class VrtsReportItem {
    string description;
    uint line;
    uint column;
    
    string filename;
}

class VrtsReportsFiles {
    string[VrtsSourceFile] filesAndReports;

    this() {
        filesAndReports = new string[VrtsSourceFile];
    }
}

class VrtsReportsParser {
    VrtsReportItem[] reports;
    // string toolName;
    // uint actionCount;
    // string[] commands;
    // string wd;
    // string outputPath;
    string[string]  filesAndReports;

    void parseMetadata(string metadataFileName) {
        string fileContent = readText(metadataFileName);

        auto jsonValue = parseJSON(fileContent); 

        auto tools = jsonValue["tools"][0];

        auto resultSourceFiles = tools["result_source_files"];

        foreach (key, value; resultSourceFiles.object) {
            filesAndReports[value.str] = key;
        }
    }

    VrtsReportsFiles linkReportsFilesWithSources(VrtsSourceFile[] sources) {
        VrtsReportsFiles files = new VrtsReportsFiles;
        foreach (ref sourceFile; sources) {
            string aPath = sourceFile.fullname.asAbsolutePath.array.buildNormalizedPath;
            if(aPath in filesAndReports) {
                // try {
                    // auto sf = sourceFile;
                    // auto name = this.filesAndReports[aPath];
                    files.filesAndReports[sourceFile] = this.filesAndReports[aPath];
                // }
                // catch(Exception e) {
                //     sysio.writeln(e);
                // }
            }
            // sysio.writeln(item.key, " ", item.value);
        }

        return files;
    }
}