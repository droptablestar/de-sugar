module Fancy::Parse
import Fancy::Fancy;
import ParseTree;

public Prog parse(loc l) = parse(#Prog, l);
public Prog parse(str s) = parse(#Prog, s);

