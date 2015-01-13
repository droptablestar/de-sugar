module Fancy::Load
import Fancy::AST;
import Fancy::Parse;
import ParseTree;

public Prog load(loc l) = implode(#Prog, parse(l));
public Prog load(str s) = implode(#Prog, parse(s));
