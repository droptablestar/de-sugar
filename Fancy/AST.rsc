module Fancy::AST

data Prog = prog(Exp exp);

data Binding = binding(str var, Exp exp);

data Exp =
    app(Exp fun, Exp body)
    | var(str name)
    | nat(int nat)
    | func(list[str] formal, Exp body)
    | cond(Exp cond, Exp then, list[tuple[Exp,Exp]] elifs, Exp otherwise)
    | let(list[str] vars, list[Exp] exps, Exp body)
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
