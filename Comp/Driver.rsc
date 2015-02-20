module Comp::Driver

import List;
import IO;

public void drive(loc L) {
    for (i <- L.ls) {
        println("<i>");
        try {
            i.ls;
            println("DIR!");
        }
        catch:
            println("FILE!");
        
                
        // c_fun += synthesise(fancy_tests[i], core_tests[i]) + "\n";
    }
        // writeFile(|cwd:///Synth/CompilerSynth.rsc|, c_fun);
    // println(readFile(|cwd:///Synth/CompilerSynth.rsc|));
}
