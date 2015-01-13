module lang::Func::Func

keyword Keywords= "if" | "then" | "else"  | "else if" | "end" | "let" | "fun" | "in";

lexical Ident = [a-zA-Z][a-zA-Z]*  !>> [a-zA-Z0-9] \ Keywords; 
lexical Natural = [0-9]+  !>> [0-9];
lexical LAYOUT = [\t-\n\r\ ];
layout LLIST = LAYOUT*  !>> [\t-\n\r\ ];

start syntax Prog = prog: Letg* ";;" Exp ;
syntax Letg = letg: "let" "(" {Ident ","}* ")" "=" "(" {Exp ","}* ")" "end" LLIST;
syntax Elif = elif: "else if" Exp "then" Exp;
syntax Exp =
    var: Ident LLIST
    | nat: Natural LLIST
    | bracket "(" Exp ")" LLIST
    | let: "let" "(" {Ident ","}* ")" "=" "(" {Exp ","}* ")" "in" Exp "end" LLIST
    | cond: "if" Exp "then" Exp Elif* "else" Exp "end" LLIST
    | func: "fun" "(" {Ident ","}* ")" "-\>" Exp
    > non-assoc (
        left mul: Exp "*" Exp 
        | non-assoc div: Exp "/" Exp 
        | non-assoc md: Exp "%" Exp 
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
    > app: Ident "(" {Exp ","}* ")" LLIST
    > right seq: Exp ";" Exp
    ;
