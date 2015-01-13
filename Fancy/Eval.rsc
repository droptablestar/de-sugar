module Fancy::Eval

import Fancy::AST;
import Fancy::Load;
import List;
import Map;
import IO;

// maps bound variables to expressions
alias Env = map[str, Exp];

public tuple[Exp, Env] eval(loc l, Env env) {
    p = load(l);
    return eval(p.exp, env);
}

public tuple[Exp, Env] eval(nat(int n), Env env) = <nat(n), env>;

public tuple[Exp, Env] eval(var(str name), Env env) {
    assert (size(domainR(env, {name})) != 0) :
    "ERROR: var: <name> not in current environment";
    return eval(env[name], env);
}
public tuple[Exp, Env] eval(seq(Exp e1, Exp e2), Env env) {
    env = eval(e1, env)[1]; return eval(e2, env);
}
public tuple[Exp, Env] eval(cond(Exp cond, Exp then, list[tuple[Exp,Exp]] elifs,
                                 Exp otherwise), Env env) {
    if (eval(cond, env)[0] != nat(0)) return eval(then, env);
    else {
        for (e <- elifs) if (eval(e[0], env)[0] != nat(0)) return eval(e[1],env);
        return eval(otherwise, env);
    }
}
public tuple[Exp, Env] eval(mul(Exp e1, Exp e2), Env env) {
    <nat(n1), nat(n2)> = <eval(e1, env)[0], eval(e2, env)[0]>;
    return <nat(n1*n2), env>;
}
public tuple[Exp, Env] eval(div(Exp e1, Exp e2), Env env) {
    <nat(n1), nat(n2)> = <eval(e1, env)[0], eval(e2, env)[0]>;
    return <nat(n1/n2), env>;
}
public tuple[Exp, Env] eval(md(Exp e1, Exp e2), Env env) {
    <nat(n1), nat(n2)> = <eval(e1, env)[0], eval(e2, env)[0]>;
    return <nat(n1%n2), env>;
}
public tuple[Exp, Env] eval(add(Exp e1, Exp e2), Env env) {
    <nat(n1), nat(n2)> = <eval(e1, env)[0], eval(e2, env)[0]>;
    return <nat(n1+n2), env>;
}
public tuple[Exp, Env] eval(sub(Exp e1, Exp e2), Env env) {
    <nat(n1), nat(n2)> = <eval(e1, env)[0], eval(e2, env)[0]>;
    return <nat(n1-n2), env>;
}
public tuple[Exp, Env] eval(eq(Exp e1, Exp e2), Env env) {
    <nat(n1), nat(n2)> = <eval(e1, env)[0], eval(e2, env)[0]>;
    return (n1==n2) ? <nat(1), env> : <nat(0), env>;
}
public tuple[Exp, Env] eval(gt(Exp e1, Exp e2), Env env) {
    <nat(n1), nat(n2)> = <eval(e1, env)[0], eval(e2, env)[0]>;
    return (n1>n2) ? <nat(1), env> : <nat(0), env>;
}
public tuple[Exp, Env] eval(lt(Exp e1, Exp e2), Env env) {
    <nat(n1), nat(n2)> = <eval(e1, env)[0], eval(e2, env)[0]>;
    return (n1<n2) ? <nat(1), env> : <nat(0), env>;
}
public tuple[Exp, Env] eval(geq(Exp e1, Exp e2), Env env) {
    <nat(n1), nat(n2)> = <eval(e1, env)[0], eval(e2, env)[0]>;
    return (n1>=n2) ? <nat(1), env> : <nat(0), env>;
}
public tuple[Exp, Env] eval(leq(Exp e1, Exp e2), Env env) {
    <nat(n1), nat(n2)> = <eval(e1, env)[0], eval(e2, env)[0]>;
    return (n1<=n2) ? <nat(1), env> : <nat(0), env>;
}

public tuple[Exp, Env] eval(func(list[str] formals, Exp body), Env env) =
    <func(formals, body), env>;

public tuple[Exp, Env] eval(app(Exp fun, Exp arg), Env env) {
    // println("fun: <fun>\narg: <arg>\nenv: <env>\n");
    switch(fun) {
        case var(k): {
            // println("case var(k)\n");
            return eval(app(eval(var(k), env)[0], arg), env);
        }
        case func(formals, body): {
            // println("case func(f, b)\n");
            env[formals[0]] = eval(arg, env)[0];
            if (size(formals) == 1)
                return eval(body, env);
            else
                return <func(formals[1..], body), env>;
        }
        case app(e1, e2): {
            // println("case app(e1, e2)\n");
            // println("e1: <e1>\ne2: <e2>\n");
            res = eval(app(e1, e2), env);
            exp = res[0];
            env = res[1];
            return eval(app(exp, arg), env);
        }
        case _: assert false : "Not a function";
    }
}

public tuple[Exp, Env] eval(let(list[str] vars, list[Exp] exps, Exp body), Env env) {
    assert size(vars) == size(exps) : "Binding sizes dont match in let.";
    for (i <- [0..size(vars)]) env += (vars[i] : eval(exps[i], env)[0]);
    return eval(body, env);
}
    
