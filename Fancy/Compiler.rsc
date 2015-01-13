module lang::Func::Compiler
// imports for the 'sugared' language
import lang::Func::AST;
import lang::Func::Eval;
import lang::Func::Load;

// imports for the 'de-sugared' language
import lang::DFunc::AST;
import lang::DFunc::Eval;
import IO;

// rewrites for numbers and variables...just return the node
public lang::DFunc::AST::Exp comp(nat(n)) = nat(n);
public lang::DFunc::AST::Exp comp(var(x)) = var(x);

// trivial rewrites. these just compile binary operations, compile left,
// compile right, return DFunc node with compiled parts.
public lang::DFunc::AST::Exp comp(seq(Exp e1, Exp e2)) = seq(comp(e1),comp(e2));
public lang::DFunc::AST::Exp comp(mul(Exp e1, Exp e2)) = mul(comp(e1),comp(e2));
public lang::DFunc::AST::Exp comp(div(Exp e1, Exp e2)) = div(comp(e1),comp(e2));
public lang::DFunc::AST::Exp comp(md(Exp e1, Exp e2))  = md(comp(e1),comp(e2));
public lang::DFunc::AST::Exp comp(add(Exp e1, Exp e2)) = add(comp(e1),comp(e2));
public lang::DFunc::AST::Exp comp(sub(Exp e1, Exp e2)) = sub(comp(e1),comp(e2));
public lang::DFunc::AST::Exp comp(eq(Exp e1, Exp e2))  = eq(comp(e1),comp(e2));
public lang::DFunc::AST::Exp comp(gt(Exp e1, Exp e2))  = gt(comp(e1),comp(e2));
public lang::DFunc::AST::Exp comp(lt(Exp e1, Exp e2))  = lt(comp(e1),comp(e2));
public lang::DFunc::AST::Exp comp(geq(Exp e1, Exp e2)) = geq(comp(e1),comp(e2));
public lang::DFunc::AST::Exp comp(leq(Exp e1, Exp e2)) = leq(comp(e1),comp(e2));

// more complicated rewrites. these should be the interesting bits
// *** functions *** //
public lang::DFunc::AST::Exp comp(func([str f], Exp body)) = func(f,comp(body));
public lang::DFunc::AST::Exp comp(func([str f0, *str fn], Exp body)) =
            func(f0,comp(func(fn,body)));

// *** global lets *** //
public list[lang::DFunc::AST::Letg] comp([letg([str v], [Exp e])]) = [letg(v,e)];
public list[lang::DFunc::AST::Letg] comp([letg([str v], [Exp e]),
                                          *lang::Func::AST::Letg lg]) =
    [letg(v,e)] + comp(lg);
public list[lang::DFunc::AST::Letg] comp([letg([str v0, *str vn], [Exp e0, *Exp en])]) =
    [letg(v0,e0)] + comp([letg(vn,en)]);
public list[lang::DFunc::AST::Letg] comp([letg([str v0, *str vn], [Exp e0, *Exp en]), 
                                          *lang::DFunc::AST::Letg lg]) =
    [letg(v0,e0)] + comp([letg(vn,en)]) + comp(lg);

 // *** local lets *** //
public lang::DFunc::AST::Exp comp(let([str v], [Exp e], Exp body)) = let(v,e,body);
public lang::DFunc::AST::Exp comp(let([str v0, *str vn], [Exp e0, *Exp en], Exp body)) =
            let(v0,e0,comp(let(vn,en,body)));

// *** cond *** //
public lang::DFunc::AST::Exp comp(cond(Exp cnd, Exp then, [], Exp els)) =
            cond(cnd,then,els);
public lang::DFunc::AST::Exp comp(cond(Exp cnd0, Exp then0,
                                       [elif(Exp cnd1, Exp then1), *Elif elifs],
                                       Exp els)) =
            cond(cnd0,then0,comp(cond(cnd1,then1,elifs,els)));

public default Exp comp(Exp e) = e;

public lang::DFunc::AST::Prog compile(loc l) {
    lo = load(l);
    // println("lo: <lo>");
    // println("Func: <lang::Func::Eval::eval(lo)>");
    p = bottom-up visit(lo) {
        case [] => []
        case list[Letg] g => comp(g)
        case Exp e => comp(e)
    }
    // println("DFunc: <lang::DFunc::Eval::eval(p)>");
    return p;
}

