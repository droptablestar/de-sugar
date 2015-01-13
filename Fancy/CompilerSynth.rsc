
module lang::Func::CompilerSynth
import lang::Func::AST;
import lang::Func::Eval;
import lang::Func::Load;

import lang::DFunc::AST;
import lang::DFunc::Eval;
import IO;

public lang::DFunc::AST::Prog compile(loc l) {
    lo = load(l);
    //println("synth");
    println("Func: <lang::Func::Eval::eval(lo)>");
    p = bottom-up visit(lo) {
        case [] => []
        case list[Letg] g => comp(g)
        case Exp e => comp(e)
    }
    println("DFunc: <lang::DFunc::Eval::eval(p)>");
    return p;
}

public lang::DFunc::AST::Exp comp(nat(n)) = nat(n);
public lang::DFunc::AST::Exp comp(var(x)) = var(x);

public lang::DFunc::AST::Exp comp(func([str p0],Exp p1)) = func(p0,p1);
public lang::DFunc::AST::Exp comp(func([str p0, *str p1],Exp p2)) = func(p0,comp(func(p1,p2)));
public lang::DFunc::AST::Exp comp(add(Exp p0,Exp p1)) = add(p0,p1);
                                                                         public lang::DFunc::AST::Exp comp(seq(Exp p0,Exp p1)) = seq(p0,p1);
