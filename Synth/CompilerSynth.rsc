
public Core::AST::Prog compile(loc l) {
    p = load(l);
    cp = Core::AST::prog(comp(p.exp));
    return cp;
}

public Core::AST::Exp comp(Fancy::AST::nat(n)) = nat(n);
public Core::AST::Exp comp(Fancy::AST::var(x)) = var(x);
Core::AST::Exp comp(Fancy::AST::Exp let([str e0, *str e1], [Fancy::AST::Exp e2, *str e3], Fancy::AST::Exp e4)) = ;