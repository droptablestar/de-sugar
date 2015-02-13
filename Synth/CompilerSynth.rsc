
public Core::AST::Prog compile(loc l) {
    p = load(l);
    cp = Core::AST::prog(comp(p.exp));
    return cp;
}

public Core::AST::Exp comp(Fancy::AST::nat(n)) = nat(n);
public Core::AST::Exp comp(Fancy::AST::var(x)) = var(x);
Core::AST::Exp comp(Fancy::AST::Exp cond(Fancy::AST::Exp e0, Fancy::AST::Exp e1, [<Fancy::AST::Exp e2, Fancy::AST::Exp e3>, *<Fancy::AST::Exp e4, Fancy::AST::Exp e5>], Fancy::AST::Exp e6)) = ;