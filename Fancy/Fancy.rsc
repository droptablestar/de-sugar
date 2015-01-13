module Fancy::Fancy

keyword Keywords= "if" | "then" | "else if" | "else"  | "end" | "fun" | "let" | "in";

lexical Ident = [a-zA-Z] !>> [a-zA-Z]+ !>> [a-zA-Z0-9] \ Keywords; 
lexical Natural = [0-9]+  !>> [0-9];
lexical LAYOUT = [\t-\n\r\ ];
layout LAYOUTLIST = LAYOUT*  !>> [\t-\n\r\ ];

start syntax Prog = prog: Exp LAYOUTLIST;

syntax Exp =
    var: Ident
    | nat: Natural 
    | left app: Exp Exp
    | bracket "(" Exp ")"
    | cond: "if" Exp "then" Exp ("else if" Exp "then" Exp)* "else" Exp "end"

    > left mul: Exp "*" Exp 
    | non-assoc div: Exp "/" Exp 
    | non-assoc md: Exp "%" Exp 

    > left add: Exp "+" Exp 
    | left sub: Exp "-" Exp 

    > non-assoc eq: Exp "=" Exp 
    | non-assoc gt: Exp "\>" Exp 
    | non-assoc lt: Exp "\<" Exp 
    | non-assoc geq: Exp "\>=" Exp 
    | non-assoc leq: Exp "\<=" Exp

    > left seq: Exp ";" Exp
    > right func: "fun" {Ident ","}+ "-\>" Exp
    | left let: "let" {Ident ","}+ "=" {Exp ","}+ "in" Exp
    ;
