/** This file parses all scripts in the GameMaker 1.4 Library Extensions.
 * Creates one file which contains all extensions in `output/gm_extensions.gml`.
 * Creates reference file `reference.md`.
 */

import std.file : readText, dirEntries, SpanMode;
import std.stdio : File, write, writeln;
import std.string : replace, split;
import std.algorithm : canFind;

void main()
{
    File output = File("output/gm_extensions.gml", "w");
    output.writeln("#define gm_extensions\n///Game Maker 1.4 Library Extensions\n");

    File reference = File("REFERENCE.md", "w"); reference.writeln("# GameMaker 1.4 Library Extensions Reference\n## Reference\n");

    //bad, initial loop to create list of references
    foreach(script; dirEntries("scripts/", "extension_*.gml", SpanMode.shallow))
    {
        auto fileName = script.name.split("/")[$-1];
        reference.writeln("### ", fileName.split(".")[0], "\n");

        auto lines = readText(script.name).replace("\r\n", "\n").split("\n");
        foreach(line; lines)
        {
            if(line.canFind("#define ") && !line.canFind("extension_"))
            {
                auto functionName = line[8 .. $];
                reference.writeln("1. [", functionName, "](#", functionName, ")");
            }
        }

        reference.writeln();
    }

    reference.writeln("\n---\n");

    foreach(script; dirEntries("scripts/", "*.gml", SpanMode.shallow))
    {

        //write to output file
        auto lines = readText(script.name).replace("\r\n", "\n").split("\n");
        foreach(line; lines)
        {
            if(!line.canFind("extension_"))
            {
                output.writeln(line);
            }
        }

        //write to reference

        if(script.name.split("/")[$ - 1] == "_gme.gml")
        {
            continue;
        }

        auto fileName = script.name.split("/")[$-1];

        reference.writeln("## ", fileName.split(".")[0], "\n");

        for(int i = 0; i < lines.length; ++i)
        {
            if(lines[i].canFind("#define ") && !lines[i].canFind("extension_"))
            {
                reference.writeln("### [", lines[i][8 .. $], "](/scripts/", fileName, "#L", i+1, ")");

                while(lines[++i].canFind("//"))
                {
                    auto line = lines[i];

                    if(line.canFind("///"))
                    {
                        reference.writeln("\n##### ", line[3 .. $]);
                    }
                    else
                    {
                        reference.writeln(line[2 .. $], "  ");
                    }
                }

                reference.writeln();
            }
        }
    }
}
