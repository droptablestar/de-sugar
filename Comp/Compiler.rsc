module Comp::Compiler
// imports for the 'sugared' language
import Fancy::AST;
import Fancy::Eval;
import Fancy::Load;

// imports for the 'de-sugared' language
import Core::AST;
import Core::Eval;

import IO;

// rewrites for numbers and variables...just return the node
public Core::AST::Exp comp(Fancy::AST::nat(n)) = nat(n);
public Core::AST::Exp comp(Fancy::AST::var(x)) = var(x);

// trivial rewrites. these just compile binary operations, compile left,
// compile right, return Core node with compiled parts.
public Core::AST::Exp comp(seq(Fancy::AST::Exp e1, Fancy::AST::Exp e2)) =
            seq(comp(e1),comp(e2));
public Core::AST::Exp comp(mul(Fancy::AST::Exp e1, Fancy::AST::Exp e2)) =
            mul(comp(e1),comp(e2));
public Core::AST::Exp comp(div(Fancy::AST::Exp e1, Fancy::AST::Exp e2)) =
            div(comp(e1),comp(e2));
public Core::AST::Exp comp(md(Fancy::AST::Exp e1, Fancy::AST::Exp e2))  =
            md(comp(e1),comp(e2));
public Core::AST::Exp comp(add(Fancy::AST::Exp e1, Fancy::AST::Exp e2)) =
            add(comp(e1),comp(e2));
public Core::AST::Exp comp(sub(Fancy::AST::Exp e1, Fancy::AST::Exp e2)) =
            sub(comp(e1),comp(e2));
public Core::AST::Exp comp(eq(Fancy::AST::Exp e1, Fancy::AST::Exp e2))  =
            eq(comp(e1),comp(e2));
public Core::AST::Exp comp(gt(Fancy::AST::Exp e1, Fancy::AST::Exp e2))  =
            gt(comp(e1),comp(e2));
public Core::AST::Exp comp(lt(Fancy::AST::Exp e1, Fancy::AST::Exp e2))  =
            lt(comp(e1),comp(e2));
public Core::AST::Exp comp(geq(Fancy::AST::Exp e1, Fancy::AST::Exp e2)) =
            geq(comp(e1),comp(e2));
public Core::AST::Exp comp(leq(Fancy::AST::Exp e1, Fancy::AST::Exp e2)) =
            leq(comp(e1),comp(e2));

// more complicated rewrites. these should be the interesting bits
// *** functions *** //
public Core::AST::Exp comp(Fancy::AST::func([str f], Fancy::AST::Exp body)) =
            func(f,comp(body));
public Core::AST::Exp comp(Fancy::AST::func([str f0, *str fn], Fancy::AST::Exp body)) =
            func(f0,comp(func(fn,body)));

public Core::AST::Exp comp(app(Fancy::AST::Exp e1, Fancy::AST::Exp e2)) =
            app(comp(e1), comp(e2));

// *** lets *** //
public Core::AST::Exp comp(let([str v], [Fancy::AST::Exp e], Fancy::AST::Exp body)) {
    println("v: <v>\ne: <e>\nbody:<body>");
    return app(func(v,comp(body)),comp(e));
}
public Core::AST::Exp comp(let([*str vn, str v0], [*Fancy::AST::Exp en, Fancy::AST::Exp e0], Fancy::AST::Exp body)) =
            app(comp(let(vn,en,func([v0],body))),comp(e0));
//TODO: would be nice to have lets with more than one variable (e.g. let x,y = 1,2 in x)

// *** cond *** //
public Core::AST::Exp comp(cond(Fancy::AST::Exp cnd, Fancy::AST::Exp then, [], Fancy::AST::Exp els)) =
            cond(comp(cnd),comp(then),comp(els));
public Core::AST::Exp comp(cond(Exp cnd0, Exp then0, [<Exp cnd1, Exp then1>, *elifs], Exp els)) =
            cond(comp(cnd0),comp(then0),comp(cond(cnd1,then1,elifs,els)));

// public default Exp comp(Exp e) = e;

public Core::AST::Prog compile(loc l) {
    p = load(l);
    cp = Core::AST::prog(comp(p.exp));
    println("Fancy: <Fancy::Eval::eval(p, ())[0]>");
    println("Core:  <Core::Eval::eval(cp,())[0]>");
    return cp;
}

