module Core::Load
import Core::AST;
import Core::Parse;
import ParseTree;

public Prog load(loc l) = implode(#Prog, parse(l));
public Prog load(str s) = implode(#Prog, parse(s));
