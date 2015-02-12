module Core::Eval

import Core::AST;
import Core::Load;
import List;
import Map;
import IO;

// maps bound variables to expressions
alias Env = map[str, Exp];
map[str,str] Bound = ();
list[str] Free = [];
bool Alpha = false;

public tuple[Exp, Env] eval(Prog p, Env env) = eval(p.exp, env);

public tuple[Exp, Env] eval(loc l, Env env) {
    p = load(l);
    t = eval(p.exp, env);
    println("Bound: <Bound> Free: <Free>");
    return t;
}

public tuple[Exp, Env] eval(nat(int n), Env env) = <nat(n), env>;

public tuple[Exp, Env] eval(var(str name), Env env) {
    println("Bound: <Bound>");
    if (name in Bound) name = Bound[name];
    else Free += name;
    if (Alpha) return <var(name), env>;
    assert (size(domainR(env, {name})) != 0) :
    "ERROR: var: <name> not in current environment";
    return eval(env[name], env);
}
public tuple[Exp, Env] eval(seq(Exp e1, Exp e2), Env env) {
    env = eval(e1, env)[1];
    return eval(e2, env);
}
public tuple[Exp, Env] eval(cond(Exp cond, Exp then, Exp otherwise), Env env) =
    (eval(cond, env)[0] != nat(0)) ? eval(then, env) : eval(otherwise, env);

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

public void subst(str org, str rep, Env env) {
    println("free: <Free> org: <org>");
    if ((rep in Free)) subst(org, rep+rep[0], env);
    else Bound[org] = rep;
}

public tuple[Exp, Env] eval(func(str formal, Exp body), Env env) {
    subst(formal, formal, env);
    Alpha = true;
    body = eval(body, env)[0];
    Alpha = false;
    return <func(Bound[formal], body), env>;
    // return <func(formal, body), env>;
}

public tuple[Exp, Env] eval(app(Exp fun, Exp param), Env env) {
    if (Alpha) {return <app(eval(fun, env)[0], eval(param, env)[0]),env>;}
    switch(fun) {
        case var(k): 
            return eval(app(eval(var(k), env)[0], param), env);
        case func(formal, body): {
            subst(formal, formal, env);
            env[Bound[formal]] = eval(param, env)[0];
            // env[formal] = eval(param, env)[0];
            return eval(body, env);
        }
        case app(e1, e2): {
            res = eval(app(e1, e2), env);
            exp = res[0];
            env = res[1];
            return eval(app(exp, param), env);
        }
        case _: assert false : "Not a function";
    }
}

