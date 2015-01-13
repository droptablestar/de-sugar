module Core::AST

data Prog = prog(Exp exp);

data Exp =
    var(str name)
    | nat(int nat)
    | cond(Exp cond, Exp then, Exp otherwise)
    | func(str formal, Exp body)
    | app(Exp fun, Exp body)
    | seq(Exp lhs, Exp rhs)

    | mul(Exp lhs, Exp rhs)
    | div(Exp lhs, Exp rhs)
    | md(Exp lhs, Exp rhs)
    | add(Exp lhs, Exp rhs)
    | sub(Exp lhs, Exp rhs)
    | eq(Exp lhs, Exp rhs)
    | gt(Exp lhs, Exp rhs)
    | lt(Exp lhs, Exp rhs)
    | geq(Exp lhs, Exp rhs)
    | leq(Exp lhs, Exp rhs)
    ;
