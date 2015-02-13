module Synth::Synthesiser
// imports for the 'sugared' language
import Fancy::AST;
// import Fancy::Eval;
import Fancy::Load;

// imports for the 'de-sugared' language
import Core::AST;
import Core::Load;
// import Core::Eval;

import IO;
import Type;
import List;
import String;
import Node;

str CORE_EXP_TYPE = "Core::AST::Exp";
str FANCY_EXP_TYPE = "Fancy::AST::Exp";
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

str fun_template = "public <CORE_EXP_TYPE> comp(";

private tuple[str,int] generate_exp_p(&T e, int count) {
    println("e: <e> typeOf(e): <typeOf(e)>");
    switch (e) {
        // TODO: Would REALLY like to not have to match on each type...
        // Is that possible?
        case list[&T] L: {
            println("L: <L>");
            if (size(L) == 0) return <"[]",count>;
            else if (size(L) == 1) {
                <t,count> = generate_exp_p(L[0],count);
                return <"[<t>]",count>;
            }
            else {
                <t0,count> = generate_exp_p(L[0],count);
                <t1,count> = generate_exp_p(L[1],count);
                return <"[<t0>, *<t1>]",count>;
            }
        }
        case tuple[&T, &T] T: {
            println("T: <T>");
            <t0,count> = generate_exp_p(T[0],count);
            <t1,count> = generate_exp_p(T[1],count);
            return <"\<<t0>, <t1>\>",count>;
        }
        // This isn't really &T...
        case &T n(*&T _): {
            println("MATCHED \\adt(\"Exp\")");
            return <"<FANCY_EXP_TYPE> e<count>", count+1>;
        }
        case \str: {
            println("MATCHED \\str");
            return <"str e<count>",count+1>;
        }
        default: { println("DEFAULT. SOMETHING FAILED IN GENERATE."); return <"",count>; }
    }
}

private tuple[str,int] synthesise_p(Fancy::AST::Exp exp, int count) {
    ret = "";
    // println("EXP: <exp>\n<typeOf(exp)>");
    switch (exp) {
        case &T n(&T e0): {
            println("NODE WITH ONE CHILD. WHAT IS THIS?: <n>\n");
            return <"",0>;
        }
        case &T n(&T e0, &T e1): {
            println("e0: <e0> typeOf(e0)\ne1: <e1>\n");
            <tmp0,count> = generate_exp_p(e0,count);
            <tmp1,count> = generate_exp_p(e1,count);
            ret += "<FANCY_EXP_TYPE> <n>(<tmp0>, <tmp1>)";
        }
        case &T n(&T e0, &T e1, &T e2): {
            println("n: <n>");
            println("e0: <e0> typeOf(e0)\ne1: <e1>\ne2: <e2>\n");
            <tmp0,count> = generate_exp_p(e0,count);
            <tmp1,count> = generate_exp_p(e1,count);
            <tmp2,count> = generate_exp_p(e2,count);
            ret += "<FANCY_EXP_TYPE> <n>(<tmp0>, <tmp1>, <tmp2>)";
        }
        case &T n(&T e0, &T e1, &T e2, &T e3): {
            println("e0: <e0> typeOf(e0)\ne1: <e1>\ne2: <e2>\ne3: <e3>\n");
            <tmp0,count> = generate_exp_p(e0,count);
            <tmp1,count> = generate_exp_p(e1,count);
            <tmp2,count> = generate_exp_p(e2,count);
            <tmp3,count> = generate_exp_p(e3,count);
            ret += "<FANCY_EXP_TYPE> <n>(<tmp0>, <tmp1>, <tmp2>, <tmp3>)";
        }
        default: println("!DEFAULT!");
    }
    return <ret,count>;
}

private tuple[str,int] synthesise_f(Core::AST::Exp exp, int count) {
    ret = "";
    println("F: <exp>\n");
    println("START");
    switch (exp) {
        case \var(_): {
            return <"e<count>", count+1>;
        }
        case \nat(_): {
            return <"e<count>", count+1>;
        }
        case &T n(Exp e0): {
            println("NODE WITH ONE CHILD. WHAT IS THIS?: <n>\n");
            return <"",0>;
        }
        case &T n(Exp e0, Exp e1): {
            <tmp0,count> = synthesise_f(e0, count);
            println("COUNT: <count>");
            <tmp1,count> = synthesise_f(e1, count);
            ret += "<n>(comp(<tmp0>), comp(<tmp1>))";
        }
        case &T _(Exp e0, Exp e1, Exp e2): {
            println("_(_,_,_)");
        }
        default: println("!DEFAULT!");
    }
    println("END");
    return <ret,count>;
}

public void synthesise(Fancy::AST::Exp fp, Core::AST::Exp cp) {
    // synthesise parameters
    cp_s = ""; count = 0;
    <fp_s,count> = synthesise_p(fp, 0);
    fp_s = "<CORE_EXP_TYPE> comp(<fp_s>) = ";
    // <cp_s,count> = synthesise_f(cp, 0);
    cp_s += ";";
    c_fun += (fp_s + cp_s);
}

// synthesise(loc0, loc1) - takes a location to a Fancy program and
// a location to a Core program. Should use these to contruct the
// translator...somewhow
public void synthesise(loc floc, loc cloc) {
    println("BEGIN: synth");
    fp = Fancy::Load::load(floc);
    println("\n\nFP: <fp>\n\n");
    cp = Core::Load::load(cloc);
    c = synthesise(fp.exp, cp.exp);
    writeFile(|cwd:///Synth/CompilerSynth.rsc|, c_fun);
    println(readFile(|cwd:///Synth/CompilerSynth.rsc|));

}
