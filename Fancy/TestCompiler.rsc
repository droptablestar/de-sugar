module lang::Func::TestCompiler
import lang::Func::Compiler;
import lang::Func::Eval;
import lang::Func::Load;

import lang::DFunc::Eval;
import lang::DFunc::Load;
import IO;
import List;
import Exception;

public void runtests() {
    ff_tests = |cwd:///lang/Func/tests|.ls;
    fd_tests = |cwd:///lang/DFunc/tests|.ls;
    for (f <- zip(ff_tests, fd_tests)) {
        if (isDirectory(f[0])) continue;
        print("<f>: ");
        eval_func = ""; eval_dfunc = ""; eval_compile = "";
        try {
            eval_func = lang::Func::Eval::eval(lang::Func::Load::load(f[0]));
            print("<eval_func>");
        }
        catch ParseError(l): println("Func ParseError::<l>");
        catch IO(m): println("Func IO::<m>");
        try {
            eval_dfunc = lang::DFunc::Eval::eval(lang::DFunc::Load::load(f[1]));
            print(", <eval_dfunc>");
        }
        catch ParseError(l): println("DFunc Eval ParseError::<l>");
        catch IO(m): println("DFunc IO::<m>");
        try {
            eval_compile = lang::DFunc::Eval::eval(compile(f[0]));
            println(", <eval_compile>");
        }
        catch ParseError(l): println("DFunc Compile ParseError::<l>");
        catch IO(m): println("DFunc IO::<m>");
        
        try assert eval_func == eval_dfunc && eval_dfunc == eval_compile : "";
        catch _: println("******** Fail: eval_func: <eval_func>, eval_dfunc: <eval_dfunc>, eval_compile: <eval_compile> ********");
        
    }
}
