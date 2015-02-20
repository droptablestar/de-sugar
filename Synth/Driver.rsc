module Synth::Driver

import Synth::Synthesiser;

import IO;
import List;

str c_fun =
"
public Core::AST::Prog compile(loc l) {
    p = load(l);
    cp = Core::AST::prog(comp(p.exp));
    return cp;
}

public Core::AST::Exp comp(Fancy::AST::nat(n)) = nat(n);
public Core::AST::Exp comp(Fancy::AST::var(x)) = var(x);
";

public void drive(loc floc, loc cloc) {
    fancy_tests = floc.ls;
    core_tests = cloc.ls;
    for (i <- [0..size(fancy_tests)]) {
        c_fun += synthesise(fancy_tests[i], core_tests[i]) + "\n";
    }
    writeFile(|cwd:///Synth/CompilerSynth.rsc|, c_fun);
    println(readFile(|cwd:///Synth/CompilerSynth.rsc|));
}
