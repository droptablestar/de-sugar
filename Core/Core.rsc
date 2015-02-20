module Core::Core

keyword Keywords= "if" | "then" | "else"  | "end" | "fun";

lexical Ident = [a-zA-Z] !>> [a-zA-Z]+ !>> [a-zA-Z0-9] \ Keywords; 
lexical Natural = [0-9]+  !>> [0-9];
lexical LAYOUT = [\t-\n\r\ ];
layout LAYOUTLIST = LAYOUT*  !>> [\t-\n\r\ ];

start syntax Prog = prog: Exp LAYOUTLIST;

syntax Exp =
    var: Ident
    | nat: Natural 
    | bracket "(" Exp ")"
    > left app: Exp Exp
    | cond: "if" Exp "then" Exp "else" Exp "end"

    > left (
        left mul: Exp "*" Exp 
        | non-assoc div: Exp "/" Exp 
        | left md: Exp "%" Exp
            )

    > left (
        left add: Exp "+" Exp 
        | left sub: Exp "-" Exp
            )
    
    > non-assoc (
        non-assoc eq: Exp "=" Exp 
        | non-assoc gt: Exp "\>" Exp 
        | non-assoc lt: Exp "\<" Exp 
        | non-assoc geq: Exp "\>=" Exp 
        | non-assoc leq: Exp "\<=" Exp
                 )
    > left seq: Exp ";" Exp
    > func: "fun" Ident "-\>" Exp
    ;
