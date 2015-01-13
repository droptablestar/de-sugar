module lang::Func::Synthesiser
import IO;
import Map;
import List;
import Type;
import String;
import Node;

import lang::Func::AST;
import lang::Func::Load;

str c =
"
module lang::Func::CompilerSynth
import lang::Func::AST;
import lang::Func::Eval;
import lang::Func::Load;

import lang::DFunc::AST;
import lang::DFunc::Eval;
import IO;

public lang::DFunc::AST::Prog compile(loc l) {
    lo = load(l);
    //println(\"synth\");
    println(\"Func: \<lang::Func::Eval::eval(lo)\>\");
    p = bottom-up visit(lo) {
        case [] =\> []
        case list[Letg] g =\> comp(g)
        case Exp e =\> comp(e)
    }
    println(\"DFunc: \<lang::DFunc::Eval::eval(p)\>\");
    return p;
}

public lang::DFunc::AST::Exp comp(nat(n)) = nat(n);
public lang::DFunc::AST::Exp comp(var(x)) = var(x);

";

str fun_template = "public lang::DFunc::AST::Exp comp(";

map[str, bool] pre_comp = ();
private str expand_lists(str node_t, list[&T] types) {
    println("expanding: <node_t> <types>");
    done = false;
    params = "<fun_template><node_t>("; pcount = 0;
    rec_ps = [];
    ret = "<node_t>(";
    rec = false;
    for (i <- [0..size(types)]) {
        println("t: <types[i]> <i>");
        switch (types[i]) {
            case Symbol _:\adt(str name,_): {
                params += "<name> p<pcount>,";
                if (i == size(types)-1) {rec_ps += pcount; break;}
                ret +=  "p<pcount>,";
                pcount+=1;
            }
            case Symbol _:\list(Symbol s): {
                typ = "";
                switch (s) {
                    case \str(): typ="str";
                    case Symbol _:\adt(str nm,_): {
                        typ = "Exp";
                        // TODO: Abstract this to some kind of Exp pair
                        if (nm == "Elif") {
                            params +=
                                "elif([<typ> p<pcount>,<typ> p<pcount+1>]),*Elif p<pcount+2>,";
                                pcount+=3;
                            continue;
                        }
                    }
                    case \void(): {params += "[],"; continue;}
                }
                params += "[<typ> p<pcount>,*<typ> p<pcount+1>],";
                rec_ps += pcount+1;
                ret += "p<pcount>,";
                pcount+=2;
                rec = true;
            }
        }
    }
    params = replaceLast(params,",","") + ")) = ";
    ret += "comp(<node_t>(";
    for (i <- rec_ps) {
        ret += "p<i>,";
    }
    ret = replaceLast(ret,",","") + ")));";
    ret = "<params><ret>";
    return "<ret>\n";
}

private str synthesise(str node_t, list[&T] types) {
    println("synthesising: <node_t> <types>");
    list_bases = []; 
    params = "<fun_template><node_t>("; pcount = 0;
    ret = "<node_t>(";
    rec = false;
    for (i <- [0..size(types)]) {
        println("t: <types[i]> <i>");
        temp = slice(types,0,i) + \list(\void()) + slice(types,i+1,size(types)-i-1);
        switch (types[i]) {
            case Symbol _:\adt(str name,_): {
                params += "<name> p<pcount>,";
                ret +=  "p<pcount>,";
                pcount+=1;
            }
            case Symbol _:\list(Symbol s): {
                typ = "";
                switch (s) {
                    case \str(): typ="str";
                    case Symbol _:\adt(str nm,_): {
                        typ = "Exp";
                        // TODO: Abstract this to some kind of Exp pair
                        if (nm == "Elif") {
                            params += "[elif(<typ> p<pcount>,<typ> p<pcount+1>)],";
                            println("ELIF: <expand_lists(node_t,types)>");
                            list_bases += "<synthesise(node_t,temp)>";
                            continue;
                        }
                    }
                    case \void(): {params += "[],"; continue;}
                }
                params += "[<typ> p<pcount>],";
                ret += "p<pcount>,";
                pcount+=1;
                list_bases += "<synthesise(node_t,temp)>";
                println("base: <list_bases> *** expanding ***");
                list_bases += "<expand_lists(node_t,types)>";
                println("base: <list_bases>");
                rec = true;
            }
        }
    }
    
    params = replaceLast(params,",","") + ")) = ";
    ret = "<params><replaceLast(ret,",","")>);";
    recs = "";
    if (rec) {
        recs = expand_lists(node_t, types);
    }
    return "<intercalate("",list_bases)><ret>\n";
}

private void synthesise() {
    fds = |cwd:///lang/Func/tests/synth|.ls;
    for (f <- fds) {
        f = |cwd:///lang/Func/tests/synth/0.func|;
        println("f: <f>");
        astf = load(f);
        println("astf: <astf>");
        visit (astf) {
            case Exp e:str t(&T t1, &T t2): {
                if (size(domainR(pre_comp, {"<t>tt"}))==0) {
                    c += "<synthesise(t,[typeOf(t1),typeOf(t2)])>";
                    pre_comp += ("<t>tt":true);
                }
            }
            case Exp e:str t(&T t1,&T t2,&T t3): {
                if (size(domainR(pre_comp, {"<t>ttt"}))==0) {
                    c += "<synthesise(t,[typeOf(t1),typeOf(t2),typeOf(t3)])>";
                    pre_comp += ("<t>ttt":true);
                }
            }
            case Exp e:str t(&T t1,&T t2,&T t3,&T t4): {
                println("tttt: <e>");
                if (size(domainR(pre_comp, {"<t>tttt"}))==0) {
                    c += "<synthesise(t,[typeOf(t1),typeOf(t2),typeOf(t3),typeOf(t4)])>";
                    pre_comp += ("<t>ttt":true);
                }
            }
        }
        return;
    }
}

public void synth() {
    println("BEGIN: synth");
    synthesise();
    writeFile(|cwd:///lang/Func/CompilerSynth.rsc|, c);
    println(readFile(|cwd:///lang/Func/CompilerSynth.rsc|));
}
