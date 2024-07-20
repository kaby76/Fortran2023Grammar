parser grammar Fortran2023Parser;

options { tokenVocab = Fortran2023Lexer; }


name: NAME | PROGRAM | END| FUNCTION | SUBROUTINE | MODULE
	 | SUBMODULE | BLOCK | DATA | INTRINSIC | NONINTRINSIC | OPERATOR
	 | READ | FORMATTED | UNFORMATTED | WRITE | ASSIGNMENT | USE | ONLY | IMPORT |  NONE | ALL
	 | KIND | INTEGER | LEN | REAL | DOUBLE | PRECISION | COMPLEX | CHARACTER | LOGICAL | TYPE | CLASS 
	 | EXTERNAL | IMPLICIT | PARAMETER | FORMAT | BIND | NAME | RESULT | ENTRY | STAT | TEAM | TEAMNUMBER | RE | IM 
	 | SEQUENCE | PRIVATE | PROCEDURE | NOPASS | PASS | POINTER | ALLOCATABLE | CODIMENSION | CONTIGUOUS | DIMENSION 
	 | PUBLIC | CONTAINS | FINAL | GENERIC | DEFERRED | NONOVERRIDABLE | INTENT | OPTIONAL | PROTECTED | SAVE | IN | OUT | INOUT 
	 | INTERFACE | ABSTRACT | ENUM | ENUMERATOR | ASYNCHRONOUS | TARGET | VALUE | VOLATILE | EQUIVALENCE | COMMON | NAMELIST | EVENT
	 | WAIT | UNTILCOUNT | POST | ERRMSG | ERROR | STOP | QUIET | ENDFILE | DEALLOCATE | CYCLE | CONTINUE | CLOSE | UNIT | IOSTAT 
	 | IOMSG | ERR | STATUS | CALL | BACKSPACE | ALLOCATE | MOLD | SOURCE | OPEN | ACCESS | ACTION | BLANK | DECIMAL | DELIM 
	 | ENCODING | FILE | FORM | NEWUNIT | PAD | POSITION | RECL | ROUND | SIGN | NULLIFY | LOCK | ACQUIREDLOCK | INQUIRE | IOLENGTH
	 | EXIST | ID | NAMED | NEXTREC | NUMBER | OPENED | PENDING | POS | READWRITE | SEQUENTIAL | SIZE | STREAM | IF | GOTO | NEWINDEX
	 | FLUSH | FAIL | IMAGE | EXIT | FORALL | WHERE | EOR | UNLOCK | SYNC | MEMORY | IMAGES | REWIND | RETURN | FMT | NML | ADVANCE | REC
	 | PRINT | CRITICAL | CHANGE | SELECT | CASE | DEFAULT | ASSOCIATE | ELSEWHERE | IS | RANK | ELSE | THEN | DO | CONCURRENT | WHILE
	 | SHARED | LOCAL | LOCALINIT | RECURSIVE | PURE | NONRECURSIVE | IMPURE | ELEMENTAL | NOTIFY | TYPEOF | CLASSOF | ENUMERATION
	 | DIRECT | LEADINGZERO | REDUCE | SIMPLE;

programName: name;

// R1402 program-stmt -> PROGRAM program-name
programStmt: PROGRAM programName;

// R1410 module-nature -> INTRINSIC | NON_INTRINSIC
moduleNature: INTRINSIC | NONINTRINSIC;

moduleName: name;

localName: name;

useName: name;

// R1004 defined-unary-op -> . letter [letter]... .
definedUnaryOp: DEFINEDUNARYBINARYOP;

// R1024 defined-binary-op -> . letter [letter]... .
definedBinaryOp: DEFINEDUNARYBINARYOP;

// R1414 local-defined-operator -> defined-unary-op | defined-binary-op
localDefinedOperator: definedUnaryOp | definedBinaryOp;

// R1415 use-defined-operator -> defined-unary-op | defined-binary-op
useDefinedOperator: definedUnaryOp | definedBinaryOp;

// R1411 rename ->
//         local-name => use-name |
//         OPERATOR ( local-defined-operator ) =>
//           OPERATOR ( use-defined-operator )
rename: localName IMPLIES useName |
    OPERATOR LPAREN localDefinedOperator RPAREN IMPLIES OPERATOR LPAREN useDefinedOperator RPAREN;

renameList: rename (COMMA rename)*;

genericName: name;

// R1008 power-op -> **
powerOp: POWER;

// R1009 mult-op -> * | /
multOp: ASTERIK | SLASH;

// R1010 add-op -> + | -
addOp: PLUS | MINUS;

// R1012 concat-op -> //
concatOp: CONCAT;

// R1014 rel-op ->
//         .EQ. | .NE. | .LT. | .LE. | .GT. | .GE. |
//         == | /= | < | <= | > | >=
relOp: EQ | NE | LT | LE | GT | GE |
       EQUAL | NOTEQUAL | LESSTHAN | LESSEQUAL | GREATERTHAN | GREATEREQUAL;

// R1019 not-op -> .NOT.
notOp: NOT;

// R1020 and-op -> .AND.
andOp: AND;

// R1021 or-op -> .OR.
orOp: OR;

// R1022 equiv-op -> .EQV. | .NEQV.
equivOp: EQV | NEQV;       

// R608 intrinsic-operator -> power-op | mult-op | add-op | concat-op | rel-op | not-op | and-op |
// or-op | equiv-op
intrinsicOperator:
	  powerOp
	| multOp
	| addOp
	| concatOp
	| relOp
	| notOp
	| andOp
	| orOp
	| equivOp;

// R610 extended-intrinsic-op -> intrinsic-operator
extendedIntrinsicOp: intrinsicOperator;

// R609 defined-operator -> defined-unary-op | defined-binary-op | extended-intrinsic-op
definedOperator:
	  definedUnaryOp
	| definedBinaryOp
	| extendedIntrinsicOp;

// R1509 defined-io-generic-spec ->
//         READ ( FORMATTED ) | READ ( UNFORMATTED ) |
//         WRITE ( FORMATTED ) | WRITE ( UNFORMATTED )
definedIOGenericSpec:
    READ LPAREN FORMATTED RPAREN |
    READ LPAREN UNFORMATTED RPAREN |
    WRITE LPAREN FORMATTED RPAREN |
    WRITE LPAREN UNFORMATTED RPAREN;  

// R1508 generic-spec ->
//         generic-name | OPERATOR ( defined-operator ) |
//         ASSIGNMENT ( = ) | defined-io-generic-spec
genericSpec:
    genericName |
    OPERATOR LPAREN definedOperator RPAREN |
    ASSIGNMENT LPAREN ASSIGN RPAREN |
    definedIOGenericSpec;

// R1413 only-use-name -> use-name
onlyUseName: useName;    

// R1412 only -> generic-spec | only-use-name | rename
only: genericSpec | onlyUseName | rename;

onlyList: only (COMMA only)*;

// R1409 use-stmt ->
//         USE [[, module-nature] ::] module-name [, rename-list] |
//         USE [[, module-nature] ::] module-name , ONLY : [only-list]
useStmt:
    USE ((COMMA moduleNature)? DOUBLECOLON)? moduleName (COMMA renameList)? |
    USE ((COMMA moduleNature)? DOUBLECOLON)? moduleName COMMA ONLY COLON onlyList?;

importName: name;

importNameList: importName (COMMA importName)*;

// R870 import-stmt -> IMPORT [[::] import-name-list] | IMPORT , ONLY : import-name-list | IMPORT ,
// NONE | IMPORT , ALL
importStmt:
	  IMPORT (DOUBLECOLON? importNameList)?
	| IMPORT COMMA ONLY COLON importNameList
	| IMPORT COMMA NONE
	| IMPORT COMMA ALL;

intConstantName: name;

scalarIntConstantName: intConstantName;

// R709 kind-param -> digit-string | scalar-int-constant-name
kindParam: DIGITSTRING | scalarIntConstantName;

// R708 int-literal-constant -> digit-string [_ kind-param]
intLiteralConstant: DIGITSTRING (UNDERSCORE kindParam)?;

// R712 sign -> + | -
sign: PLUS | MINUS;

// R710 signed-digit-string -> [sign] digit-string
signedDigitString: sign? DIGITSTRING;

// R717 exponent -> signed-digit-string
exponent: signedDigitString;

// R714 real-literal-constant -> significand [exponent-letter exponent] [_ kind-param] |
// digit-string exponent-letter exponent [_ kind-param]
// R715 significand -> digit-string . [digit-string] | . digit-string
///MODIFIED AND MIXED RULE: RESOLVING EXPONENTLETTER DUE TO CLASH WITH NAME
realLiteralConstant:
    DIGITSTRING DOT DIGITSTRING? (UNDERSCORE kindParam)?
	| DOT DIGITSTRING (UNDERSCORE kindParam)?
	| REALEXPONENTLETTER exponent (UNDERSCORE kindParam)?;

// R707 signed-int-literal-constant -> [sign] int-literal-constant
signedIntLiteralConstant: sign? intLiteralConstant;

// R713 signed-real-literal-constant -> [sign] real-literal-constant
signedRealLiteralConstant: sign? realLiteralConstant;

// R606 named-constant -> name
namedConstant: name;

// R719 real-part -> signed-int-literal-constant | signed-real-literal-constant | named-constant
realPart:
		signedIntLiteralConstant
	| signedRealLiteralConstant
	| namedConstant;

// R720 imag-part -> signed-int-literal-constant | signed-real-literal-constant | named-constant
imagPart:
		signedIntLiteralConstant
	| signedRealLiteralConstant
	| namedConstant;

// R718 complex-literal-constant -> ( real-part , imag-part )
complexLiteralConstant: LPAREN realPart COMMA imagPart RPAREN;

// R725 logical-literal-constant -> .TRUE. [_ kind-param] | .FALSE. [_ kind-param]
logicalLiteralConstant:
		TRUE (UNDERSCORE kindParam)?
	| FALSE (UNDERSCORE kindParam)?;

// R724 char-literal-constant -> [kind-param _] ' [rep-char]... ' | [kind-param _] " [rep-char]... "
charLiteralConstant: 
		(kindParam UNDERSCORE)? APOSTROPHEREPCHAR
	| (kindParam UNDERSCORE)? QUOTEREPCHAR;

// R772 boz-literal-constant -> binary-constant | octal-constant | hex-constant
bozLiteralConstant:
		BINARYCONSTANT
	| OCTALCONSTANT
	| HEXCONSTANT;	

// R605 literal-constant -> int-literal-constant | real-literal-constant | complex-literal-constant
// | logical-literal-constant | char-literal-constant | boz-literal-constant
literalConstant:
	  intLiteralConstant
	| realLiteralConstant
	| complexLiteralConstant
	| logicalLiteralConstant
	| charLiteralConstant
	| bozLiteralConstant;

// R804 object-name -> name
objectName: name;

partName: name;

// R919 subscript -> scalar-int-expr
subscript: scalarIntExpr;

// R920 multiple-subscript -> @ int-expr
multipleSubscript: ATSYMBOL intExpr;

// R924 stride -> scalar-int-expr
stride: scalarIntExpr;

// R922 subscript-triplet -> [subscript] : [subscript] [: stride]
subscriptTriplet:  subscript? COLON subscript? (COLON stride)?;

// R923 multiple-subscript-triplet -> @ [int-expr] : [int-expr] [: int-expr]
multipleSubscriptTriplet: ATSYMBOL intExpr? COLON intExpr? (COLON intExpr)?;

// R925 vector-subscript -> int-expr
vectorSubscript: intExpr;

// R921 section-subscript -> subscript | multiple-subscript | subscript-triplet | multiple-subscript-triplet | vector-subscript
sectionSubscript: subscript | multipleSubscript | subscriptTriplet | multipleSubscriptTriplet | vectorSubscript;

sectionSubscriptList: sectionSubscript (COMMA sectionSubscript)*;

// R779 lbracket -> [
lbracket: LBRACKET;

// R927 cosubscript -> scalar-int-expr
cosubscript: scalarIntExpr;

cosubscriptList: cosubscript (COMMA cosubscript)*;

procedureName: name;

procedureComponentName: name;

bindingName: name;		

// R1528 consequent-arg: expr | variable;
consequentArg: expr | variable;

// R1527 consequent -> consequent-arg | .NIL.
consequent: consequentArg | NIL;

// R1526 conditional-arg -> ( scalar-logical-expr ? consequent [ : scalar-logical-expr ? consequent ]... : consequent )
conditionalArg: LPAREN scalarLogicalExpr QUESTION consequent (COLON scalarLogicalExpr QUESTION consequent)* COLON consequent RPAREN;

// R611 label -> digit [digit [digit [digit [digit]]]]
///ISSUE OF SINGLE DIGIT NUMBERS TOKENIZED AS DIGITSTRING INSTEAD OF DIGIT
label: DIGITSTRING;

// R1525 alt-return-spec -> * label
altReturnSpec:
    ASTERIK label;

// R1524 actual-arg ->
//         expr | variable | procedure-name | proc-component-ref | conditional-arg | alt-return-spec
actualArg:
    expr | variable | procedureName | procComponentRef | conditionalArg | altReturnSpec;

// R1523 actual-arg-spec -> [keyword =] actual-arg
actualArgSpec:
    (keyword ASSIGN)? actualArg;

actualArgSpecList: actualArgSpec (COMMA actualArgSpec)*;

// R902 variable -> designator | function-reference
// R1520 function-reference -> procedure-designator ( [actual-arg-spec-list] )
// R1522 procedure-designator ->
//         procedure-name | proc-component-ref | data-ref % binding-name
// R1040 proc-component-ref -> scalar-variable % procedure-component-name
///MUTUALLY LEFT RECURSION RESOLVED
variable: 
		designator
	| procedureName LPAREN actualArgSpecList? RPAREN
	| variable PERCENT procedureComponentName LPAREN actualArgSpecList? RPAREN
	| dataRef PERCENT bindingName LPAREN actualArgSpecList? RPAREN;
	
// R1167 notify-variable -> scalar-variable
notifyVariable: scalarVariable;

// R907 int-variable -> variable
intVariable: variable;

scalarIntVariable: intVariable;

// R946 stat-variable -> scalar-int-variable
statVariable: scalarIntVariable;

scalarExpr: expr;

// R1115 team-value -> scalar-expr
teamValue: scalarExpr;

// R928 image-selector-spec ->
//        NOTIFY = notify-variable |
//        STAT = stat-variable | TEAM = team-value |
//        TEAM_NUMBER = scalar-int-expr
imageSelectorSpec:
	  NOTIFY ASSIGN notifyVariable
    | STAT ASSIGN statVariable
	| TEAM ASSIGN teamValue
	| TEAMNUMBER ASSIGN scalarIntExpr;

imageSelectorSpecList: imageSelectorSpec (COMMA imageSelectorSpec)*;

// R780 rbracket -> ]
rbracket: RBRACKET;

// R926 image-selector -> lbracket cosubscript-list [, image-selector-spec-list] rbracket
imageSelector: lbracket cosubscriptList (COMMA imageSelectorSpecList)? rbracket;

// R912 part-ref -> part-name [( section-subscript-list )] [image-selector]
partRef: partName (LPAREN sectionSubscriptList RPAREN)? imageSelector?;

// R911 data-ref -> part-ref [% part-ref]...
dataRef: partRef (PERCENT partRef)*;

// R917 array-element -> data-ref
arrayElement: dataRef;

// R910 substring-range -> [scalar-int-expr] : [scalar-int-expr]
substringRange: scalarIntExpr? COLON scalarIntExpr?;

// R915 complex-part-designator -> designator % RE | designator % IM
complexPartDesignator: designator PERCENT (RE | IM);

// R918 array-section ->
//        data-ref [( substring-range )] | complex-part-designator
arraySection: dataRef (LPAREN substringRange RPAREN)? | complexPartDesignator;

// R914 coindexed-named-object -> data-ref
coindexedNamedObject: dataRef;

// R913 structure-component -> data-ref
structureComponent: dataRef;

// R903 variable-name -> name
variableName: name;

scalarVariableName: variableName;

scalarStructureComponent: structureComponent;

scalarCharLiteralConstant: charLiteralConstant;

scalarNamedConstant: namedConstant;

// R909 parent-string ->
//        scalar-variable-name | array-element | coindexed-named-object |
//        scalar-structure-component | scalar-constant
parentString: scalarVariableName | arrayElement | coindexedNamedObject
    | scalarStructureComponent | scalarConstant;

// R908 substring -> parent-string ( substring-range )
substring: parentString LPAREN substringRange RPAREN;

// R901 designator ->
//        object-name | array-element | array-section |
//        coindexed-named-object | complex-part-designator |
//        structure-component | substring
// R918 array-section ->
//        data-ref [( substring-range )] | complex-part-designator
// R915 complex-part-designator -> designator % RE | designator % IM
///MUTUALLY LEFT RECURSION RESOLVED
designator:
		objectName 
	| arrayElement
	| dataRef (LPAREN substringRange RPAREN)?
	| coindexedNamedObject
	| designator PERCENT (RE | IM)
	| structureComponent
	| substring;

enumTypeName: name;

// R764 enum-type-spec -> enum-type-name
enumTypeSpec: enumTypeName;

enumerationTypeName: name;

// R770 enumeration-type-spec -> enumeration-type-name
enumerationTypeSpec: enumerationTypeName;

// R702 type-spec -> intrinsic-type-spec | derived-type-spec | enum-type-spec | enumeration-type-spec
typeSpec: intrinsicTypeSpec | derivedTypeSpec | enumTypeSpec | enumerationTypeSpec;

intVariableName: name;

scalarIntVariableName: intVariableName;

// R1124 do-variable -> scalar-int-variable-name
doVariable: scalarIntVariableName;

// R784 ac-do-variable -> do-variable
acDoVariable: doVariable;

// R783 ac-implied-do-control -> [integer-type-spec ::] ac-do-variable = scalar-int-expr ,
// scalar-int-expr [, scalar-int-expr]
acImpliedDoControl:
    (integerTypeSpec DOUBLECOLON)? acDoVariable ASSIGN scalarIntExpr COMMA scalarIntExpr (COMMA scalarIntExpr)?;

// R782 ac-implied-do -> ( ac-value-list , ac-implied-do-control )
acImpliedDo: LPAREN acValueList COMMA acImpliedDoControl RPAREN;

// R781 ac-value -> expr | ac-implied-do
acValue: expr | acImpliedDo;

acValueList: acValue (COMMA acValue)*;

// R778 ac-spec -> type-spec :: | [type-spec ::] ac-value-list
acSpec: typeSpec DOUBLECOLON | (typeSpec DOUBLECOLON)? acValueList;

// R777 array-constructor -> (/ ac-spec /) | lbracket ac-spec rbracket
arrayConstructor: LPARENSLASH acSpec RPARENSLASH | lbracket acSpec rbracket;

// R1038 data-target -> expr
dataTarget: expr;

// R1040 proc-component-ref -> scalar-variable % procedure-component-name
procComponentRef: variable procedureComponentName;

// R1041 proc-target -> expr | procedure-name | proc-component-ref
procTarget: expr | procedureName | procComponentRef;

// R758 component-data-source -> expr | data-target | proc-target
componentDataSource: expr | dataTarget | procTarget;

// R757 component-spec -> [keyword =] component-data-source
componentSpec: (keyword ASSIGN)? componentDataSource;

componentSpecList: componentSpec (COMMA componentSpec)*;

// R756 structure-constructor -> derived-type-spec ( [component-spec-list] )
structureConstructor:
	derivedTypeSpec LPAREN (componentSpecList)? RPAREN;

// R1522 procedure-designator ->
//         procedure-name | proc-component-ref | data-ref % binding-name
procedureDesignator:
    procedureName | procComponentRef | dataRef PERCENT bindingName;

// R1520 function-reference -> procedure-designator ( [actual-arg-spec-list] )
functionReference:
    procedureDesignator LPAREN actualArgSpecList? RPAREN;

typeParamName: name;

// R916 type-param-inquiry -> designator % type-param-name
typeParamInquiry: designator PERCENT typeParamName;

// R1002 conditional-expr -> ( scalar-logical-expr ? expr [: scalar-logical-expr ? expr]... : expr )
conditionalExpr: LPAREN scalarLogicalExpr QUESTION expr (COLON scalarLogicalExpr QUESTION expr)* COLON expr RPAREN;

// R1001 primary ->
//         literal-constant | designator | array-constructor |
//         structure-constructor | enum-constructor | enumeration-constructor | function-reference | type-param-inquiry |
//         type-param-name | ( expr ) | conditional-expr
primary:
    literalConstant |
    designator |
    arrayConstructor |
    structureConstructor |
	enumConstructor |
	enumerationConstructor |
    functionReference |
    typeParamInquiry |
    typeParamName |
    LPAREN expr RPAREN |
	conditionalExpr;

// R1003 level-1-expr -> [defined-unary-op] primary
level1Expr: definedUnaryOp? primary;

// R1005 mult-operand -> level-1-expr [power-op mult-operand]
multOperand:  level1Expr (powerOp multOperand)?;

// R1006 add-operand -> [add-operand mult-op] mult-operand
///LEFT RECURSION RESOLVED
addOperand: multOperand | addOperand multOp multOperand;

// R1007 level-2-expr -> [[level-2-expr] add-op] add-operand
///LEFT RECURSION RESOLVED
level2Expr: addOperand | addOp addOperand | level2Expr addOp addOperand;

// R1011 level-3-expr -> [level-3-expr concat-op] level-2-expr
///LEFT RECURSION RESOLVED
level3Expr: level2Expr | level3Expr concatOp level2Expr;

// R1013 level-4-expr -> [level-3-expr rel-op] level-3-expr
level4Expr: (level3Expr relOp)? level3Expr;

// R1015 and-operand -> [not-op] level-4-expr
andOperand: notOp? level4Expr;

// R1016 or-operand -> [or-operand and-op] and-operand
///LEFT RECURSION RESOLVED
orOperand: andOperand | orOperand andOp andOperand;

// R1017 equiv-operand -> [equiv-operand or-op] or-operand
///LEFT RECURSION RESOLVED
equivOperand: orOperand | equivOperand orOp orOperand;

// R1018 level-5-expr -> [level-5-expr equiv-op] equiv-operand
///LEFT RECURSION RESOLVED
level5Expr: equivOperand | level5Expr equivOp equivOperand;

// R1023 expr -> [expr defined-binary-op] level-5-expr
///LEFT RECURSION RESOLVED
expr: level5Expr | expr definedBinaryOp level5Expr;

// R1027 int-expr -> expr
intExpr: expr;

// R1032 int-constant-expr -> int-expr
intConstantExpr: intExpr;

scalarIntConstantExpr: intConstantExpr; 

// R706 kind-selector -> ( [KIND =] scalar-int-constant-expr )
kindSelector: LPAREN (KIND ASSIGN)? scalarIntConstantExpr RPAREN;

// R705 integer-type-spec -> INTEGER [kind-selector]
integerTypeSpec: INTEGER kindSelector?;

scalarIntExpr: intExpr;

// R701 type-param-value -> scalar-int-expr | * | :
typeParamValue: scalarIntExpr | ASTERIK | COLON;

// R723 char-length -> ( type-param-value ) | int-literal-constant
charLength: LPAREN typeParamValue RPAREN | intLiteralConstant;

// R722 length-selector -> ( [LEN =] type-param-value ) | * char-length [,]
lengthSelector:
  	LPAREN (LEN ASSIGN)? typeParamValue RPAREN
  | ASTERIK charLength (COMMA)?;

// R721 char-selector -> length-selector | ( LEN = type-param-value , KIND =
// scalar-int-constant-expr ) | ( type-param-value , [KIND =] scalar-int-constant-expr ) | ( KIND =
// scalar-int-constant-expr [, LEN = type-param-value] )
charSelector:
	  lengthSelector
	| LPAREN LEN ASSIGN typeParamValue COMMA KIND ASSIGN scalarIntConstantExpr RPAREN
	| LPAREN typeParamValue COMMA (KIND ASSIGN)? scalarIntConstantExpr RPAREN
	| LPAREN KIND ASSIGN scalarIntConstantExpr (COMMA LEN ASSIGN typeParamValue)? RPAREN;

// R704 intrinsic-type-spec -> integer-type-spec | REAL [kind-selector] | DOUBLE PRECISION | COMPLEX
// [kind-selector] | CHARACTER [char-selector] | LOGICAL [kind-selector]
intrinsicTypeSpec:
	  integerTypeSpec
	| REAL kindSelector?
	| DOUBLE PRECISION
	| COMPLEX kindSelector?
	| CHARACTER charSelector?
	| LOGICAL kindSelector?;

typeName: name;

// R516 keyword -> name
keyword: name;

// R755 type-param-spec -> [keyword =] type-param-value
typeParamSpec: (keyword ASSIGN)? typeParamValue;

typeParamSpecList: typeParamSpec (COMMA typeParamSpec)*;

// R754 derived-type-spec -> type-name [(type-param-spec-list)]
derivedTypeSpec: typeName (LPAREN typeParamSpecList RPAREN)?; 

// R703 declaration-type-spec -> intrinsic-type-spec | TYPE ( intrinsic-type-spec ) | TYPE ( derived-type-spec ) | TYPE ( enum-type-spec ) | TYPE ( enumeration-type-spec )
//                               | CLASS ( derived-type-spec ) | CLASS ( * ) | TYPE ( * ) | TYPEOF ( data-ref ) | CLASSOF ( data-ref )
declarationTypeSpec:
	intrinsicTypeSpec
	| TYPE LPAREN intrinsicTypeSpec RPAREN
	| TYPE LPAREN derivedTypeSpec RPAREN
	| TYPE LPAREN enumTypeSpec RPAREN
	| TYPE LPAREN enumerationTypeSpec RPAREN
	| CLASS LPAREN derivedTypeSpec RPAREN
	| CLASS LPAREN ASTERIK RPAREN
	| TYPE LPAREN ASTERIK RPAREN
	| TYPEOF LPAREN dataRef RPAREN
	| CLASSOF LPAREN dataRef RPAREN;

letterSpecList: LETTERSPEC (COMMA LETTERSPEC)*;

// R867 implicit-spec -> declaration-type-spec ( letter-spec-list )
implicitSpec: declarationTypeSpec LPAREN letterSpecList RPAREN;

implicitSpecList: implicitSpec (COMMA implicitSpec)*;

// R869 implicit-none-spec -> EXTERNAL | TYPE
implicitNoneSpec: EXTERNAL | TYPE;

implicitNoneSpecList: implicitNoneSpec (COMMA implicitNoneSpec)*;

// R866 implicit-stmt -> IMPLICIT implicit-spec-list | IMPLICIT NONE [( [implicit-none-spec-list] )]
implicitStmt:
	IMPLICIT implicitSpecList
	| IMPLICIT NONE ( LPAREN implicitNoneSpecList? RPAREN )?;

// R1030 constant-expr -> expr
constantExpr: expr;

// R855 named-constant-def -> named-constant = constant-expr
namedConstantDef: namedConstant ASSIGN constantExpr;

namedConstantDefList: namedConstantDef (COMMA namedConstantDef)*;

// R854 parameter-stmt -> PARAMETER ( named-constant-def-list )
parameterStmt:  PARAMETER LPAREN namedConstantDefList RPAREN;

// R1306 r -> int-literal-constant
r: intLiteralConstant;

// R1308 w -> int-literal-constant
w: intLiteralConstant;

// R1309 m -> int-literal-constant
m: intLiteralConstant;

// R1310 d -> int-literal-constant
d: intLiteralConstant;

// R1311 e -> int-literal-constant
e: intLiteralConstant;

// R1312 v -> signed-int-literal-constant
v: signedIntLiteralConstant;

vList: v (COMMA v)*;

// R1307 data-edit-desc ->
//         I w [. m] | B w [. m] | O w [. m] | Z w [. m] | F w . d |
//         E w . d [E e] | EN w . d [E e] | ES w . d [E e] | EX w . d [E e] |
//         G w [. d [E e]] | L w | A [w] | AT | D w . d |
//         DT [char-literal-constant] [( v-list )]
dataEditDesc:
    I w (DOT m)? |
    B w (DOT m)? |
    O w (DOT m)? |
    Z w (DOT m)? |
    F w DOT d |
    E w DOT d ( E e )? |
    EN w DOT d ( E e )? |
    ES w DOT d ( E e )? |
    EX w DOT d ( E e )? |
    G w (DOT d ( E e )?)? |
    L w |
    A w? |
	AT |
    D w DOT d |
    DT charLiteralConstant? ( LPAREN vList RPAREN )?;

// R1319 leading-zero-edit-desc -> LZS | LZP | LZ
leadingZeroEditDesc: LZS | LZP | LZ;

// R1316 n -> int-literal-constant
n: intLiteralConstant;

// R1315 position-edit-desc -> T n | TL n | TR n | n X
positionEditDesc:
    T n |
    TL n |
    TR n |
    n X;

// R1321 sign-edit-desc -> SS | SP | S
signEditDesc: SS | SP | S;

// R1314 k -> signed-int-literal-constant
k: signedIntLiteralConstant;

// R1317 blank-interp-edit-desc -> BN | BZ
blankInterpEditDesc: BN | BZ;

// R1320 round-edit-desc -> RU | RD | RZ | RN | RC | RP
roundEditDesc: RU | RD | RZ | RN | RC | RP;

// R1318 decimal-edit-desc -> DC | DP
decimalEditDesc: DC | DP;

// R1313 control-edit-desc ->
//         blank-interp-edit-desc | decimal-edit-desc | leading-zero-edit-desc | position-edit-desc |  round-edit-desc
//         | sign-edit-desc | k P | : | [r] / 
controlEditDesc:
    blankInterpEditDesc |
	decimalEditDesc |
	leadingZeroEditDesc |
    positionEditDesc |
	roundEditDesc |
    signEditDesc |
	k P |
    COLON |
    r? SLASH;

// R1322 char-string-edit-desc -> char-literal-constant
charStringEditDesc: charLiteralConstant;

// R1304 format-item ->
//         [r] data-edit-desc | control-edit-desc | char-string-edit-desc | [r] ( format-items )
formatItem: r? dataEditDesc | controlEditDesc | charStringEditDesc | r? LPAREN formatItems RPAREN;

// R1303 format-items -> format-item [[,] format-item]...
formatItems: formatItem (COMMA? formatItem)*;

// R1305 unlimited-format-item -> * ( format-items )
unlimitedFormatItem: ASTERIK LPAREN formatItems RPAREN;

// R1302 format-specification ->
//         ( [format-items] ) | ( [format-items ,] unlimited-format-item )
///MODIFIED RULE: PARENS's shifted to format-stmt
formatSpecification:
		formatItems |  (formatItems COMMA)? unlimitedFormatItem;

// R1301 format-stmt -> FORMAT format-specification
///MODIFIED RULE: Enter into FORMAT Micro Grammer with FORMATIN and Exit with RPAREN
///Added optional label for format statement
///FORMATIN -> FORMAT LPAREN
formatStmt: label? FORMATIN formatSpecification RPAREN;

entryName: name;

// R1539 dummy-arg -> dummy-arg-name | *
dummyArg:
    dummyArgName | ASTERIK;

dummyArgList: dummyArg (COMMA dummyArg)*;

// R1026 default-char-expr -> expr
defaultCharExpr: expr;

// R1031 default-char-constant-expr -> default-char-expr
defaultCharConstantExpr: defaultCharExpr;

scalarDefaultCharConstantExpr: defaultCharConstantExpr;

// R808 language-binding-spec -> BIND ( C [, NAME = scalar-default-char-constant-expr] )
///BINDC -> BIND LPAREN C
languageBindingSpec:
	BINDC (COMMA NAAM ASSIGN scalarDefaultCharConstantExpr)? RPAREN;

// R1531 proc-language-binding-spec -> language-binding-spec
procLanguageBindingSpec:
    languageBindingSpec;

resultName: name;

// R1535 suffix ->
//         proc-language-binding-spec [RESULT ( result-name )] |
//         RESULT ( result-name ) [proc-language-binding-spec]
suffix:
    procLanguageBindingSpec ( RESULT LPAREN resultName RPAREN )? |
    RESULT LPAREN resultName RPAREN procLanguageBindingSpec?;

// R1544 entry-stmt -> ENTRY entry-name [( [dummy-arg-list] ) [suffix]]
entryStmt:
    ENTRY entryName (LPAREN (dummyArgList)? RPAREN (suffix)?)?;

//R506 implicit-part-stmt -> implicit-stmt | parameter-stmt | format-stmt | entry-stmt
implicitPartStmt:
	  implicitStmt
	| parameterStmt
	| formatStmt
	| entryStmt;

//R505 implicit-part -> [implicit-part-stmt]... implicit-stmt
implicitPart: (implicitPartStmt)* implicitStmt;

// R734 type-param-attr-spec -> KIND | LEN
typeParamAttrSpec: KIND | LEN;

typeAttrSpecList: typeParamAttrSpec (COMMA typeParamAttrSpec)*;

typeParamNameList: typeParamName (COMMA typeParamName)*;

// R727 derived-type-stmt -> TYPE [[, type-attr-spec-list] ::] type-name [( type-param-name-list )]
derivedTypeStmt:
    TYPE ((COMMA typeAttrSpecList)? DOUBLECOLON)? typeName (LPAREN typeParamNameList RPAREN)?;

// R733 type-param-decl -> type-param-name [= scalar-int-constant-expr]
typeParamDecl: typeParamName (ASSIGN scalarIntConstantExpr)?;

typeParamDeclList: typeParamDecl (COMMA typeParamDecl)*;

// R732 type-param-def-stmt -> integer-type-spec , type-param-attr-spec :: type-param-decl-list
typeParamDefStmt:
	integerTypeSpec COMMA typeParamAttrSpec DOUBLECOLON typeParamDeclList;

// R745 private-components-stmt -> PRIVATE
privateComponentsStmt: PRIVATE;

// R731 sequence-stmt -> SEQUENCE
sequenceStmt: SEQUENCE;

// R729 private-or-sequence -> private-components-stmt | sequence-stmt
privateOrSequence: privateComponentsStmt | sequenceStmt;

// R730 end-type-stmt -> END TYPE [type-name]
endTypeStmt: END TYPE typeName?;

// R807 access-spec -> PUBLIC | PRIVATE
accessSpec: PUBLIC | PRIVATE;

// R810 deferred-coshape-spec -> :
deferredCoShapeSpec: COLON;

deferredCoShapeSpecList: deferredCoShapeSpec (COMMA deferredCoShapeSpec)*;

// R1029 specification-expr -> scalar-int-expr
specificationExpr: scalarIntExpr;

// R812 lower-cobound -> specification-expr
lowerCoBound: specificationExpr;

// R813 upper-cobound -> specification-expr
upperCoBound: specificationExpr;

// R811 explicit-coshape-spec -> [[lower-cobound :] upper-cobound ,]... [lower-cobound :] *
explicitCoShapeSpec: ((lowerCoBound COLON)? upperCoBound COMMA)* (lowerCoBound COLON)? ASTERIK;

// R809 coarray-spec -> deferred-coshape-spec-list | explicit-coshape-spec
coarraySpec: deferredCoShapeSpecList | explicitCoShapeSpec;

// R816 lower-bound -> specification-expr
lowerBound: specificationExpr;

// R817 upper-bound -> specification-expr
upperBound: specificationExpr;

// R815 explicit-shape-spec -> [lower-bound :] upper-bound
explicitShapeSpec: (lowerBound COLON)? upperBound;

explicitShapeSpecList: explicitShapeSpec (COMMA explicitShapeSpec)*;

// R822 deferred-shape-spec -> :
deferredShapeSpec: COLON;

deferredShapeSpecList: deferredShapeSpec (COMMA deferredShapeSpec)*;

// R740 component-array-spec -> explicit-shape-spec-list | deferred-shape-spec-list
componentArraySpec:
	explicitShapeSpecList
	| deferredShapeSpecList;

// R738 component-attr-spec -> access-spec | ALLOCATABLE | CODIMENSION lbracket coarray-spec
// rbracket | CONTIGUOUS | DIMENSION ( component-array-spec ) | POINTER
componentAttrSpec:
	accessSpec
	| ALLOCATABLE
	| CODIMENSION lbracket coarraySpec rbracket
	| CONTIGUOUS
	| DIMENSION LPAREN componentArraySpec RPAREN
	| POINTER;

componentAttrSpecList: componentAttrSpec (COMMA componentAttrSpec)*;

componentName: name;

// R743 component-initialization -> = constant-expr | => null-init | => initial-data-target
componentInitialization:
	ASSIGN constantExpr
	| IMPLIES nullInit
	| IMPLIES initialDataTarget;

// R739 component-decl -> component-name [( component-array-spec )] [lbracket coarray-spec rbracket]
// [* char-length] [component-initialization]
componentDecl:
	componentName (LPAREN componentArraySpec RPAREN)? (lbracket coarraySpec rbracket)? (ASTERIK charLength)? componentInitialization?;

componentDeclList: componentDecl (COMMA componentDecl)*;

// R737 data-component-def-stmt -> declaration-type-spec [[, component-attr-spec-list] ::] component-decl-list
dataComponentDefStmt:
	declarationTypeSpec ((COMMA componentAttrSpecList)? DOUBLECOLON)? componentDeclList;

// R1516 interface-name -> name
interfaceName: name;

// R1513 proc-interface -> interface-name | declaration-type-spec
procInterface: interfaceName | declarationTypeSpec;

argName: name;

// R742 proc-component-attr-spec -> access-spec | NOPASS | PASS [(arg-name)] | POINTER
procComponentAttrSpec:
	accessSpec
	| NOPASS
	| PASS (LPAREN argName RPAREN)?
	| POINTER;

procComponentAttrSpecList: procComponentAttrSpec (COMMA procComponentAttrSpec)*;

procedureEntityName: name;  

// R806 null-init -> function-reference
nullInit: functionReference;

// R1518 initial-proc-target -> procedure-name
initialProcTarget:
    procedureName;

// R1517 proc-pointer-init -> null-init | initial-proc-target
procPointerInit:
    nullInit | initialProcTarget;

// R1515 proc-decl -> procedure-entity-name [=> proc-pointer-init]
procDecl:
    procedureEntityName (IMPLIES procPointerInit)?;

procDeclList: procDecl (COMMA procDecl)*;

// R741 proc-component-def-stmt -> PROCEDURE ( [proc-interface] ) , proc-component-attr-spec-list ::
// proc-decl-list
procComponentDefStmt:
	PROCEDURE LPAREN procInterface? RPAREN COMMA procComponentAttrSpecList DOUBLECOLON procDeclList;

// R736 component-def-stmt -> data-component-def-stmt | proc-component-def-stmt
componentDefStmt: dataComponentDefStmt | procComponentDefStmt;

// R735 component-part -> [component-def-stmt]...
componentPart: (componentDefStmt)*;

// R747 binding-private-stmt -> PRIVATE
bindingPrivateStmt: PRIVATE;

// R752 bind-attr -> access-spec | DEFERRED | NON_OVERRIDABLE | NOPASS | PASS [(arg-name)]
bindAttr:
	accessSpec
	| DEFERRED
	| NONOVERRIDABLE
	| NOPASS
	| PASS (LPAREN argName RPAREN)?;

bindAttrList: bindAttr (COMMA bindAttr)*;

// R750 type-bound-proc-decl -> binding-name [=> procedure-name]
typeBoundProcDecl: bindingName (IMPLIES procedureName)?;

typeBoundProcDeclList: typeBoundProcDecl (COMMA typeBoundProcDecl)*;

bindingNameList: bindingName (COMMA bindingName)*;

// R749 type-bound-procedure-stmt -> PROCEDURE [[, bind-attr-list] ::] type-bound-proc-decl-list |
// PROCEDURE ( interface-name ) , bind-attr-list :: binding-name-list
typeBoundProcedureStmt:
	PROCEDURE ((COMMA bindAttrList)? DOUBLECOLON)? typeBoundProcDeclList
	| PROCEDURE LPAREN interfaceName RPAREN COMMA bindAttrList DOUBLECOLON bindingNameList;

// R751 type-bound-generic-stmt -> GENERIC [, access-spec] :: generic-spec => binding-name-list
typeBoundGenericStmt:
	GENERIC (COMMA accessSpec)? DOUBLECOLON genericSpec IMPLIES bindingNameList;

finalSubroutineName: name;

finalSubroutineNameList: finalSubroutineName (COMMA finalSubroutineName)*;

// R753 final-procedure-stmt -> FINAL [::] final-subroutine-name-list
finalProcedureStmt: FINAL (DOUBLECOLON)? finalSubroutineNameList;

// R748 type-bound-proc-binding -> type-bound-procedure-stmt | type-bound-generic-stmt |
// final-procedure-stmt
typeBoundProcBinding:
	typeBoundProcedureStmt
	| typeBoundGenericStmt
	| finalProcedureStmt;

// R1546 contains-stmt -> CONTAINS
containsStmt: CONTAINS;

// R746 type-bound-procedure-part -> contains-stmt [binding-private-stmt]
// [type-bound-proc-binding]...
typeBoundProcedurePart:
	containsStmt (bindingPrivateStmt)? (typeBoundProcBinding)*;

// R726 derived-type-def -> derived-type-stmt [type-param-def-stmt]... [private-or-sequence]...
// [component-part] [type-bound-procedure-part] end-type-stmt
derivedTypeDef:
	derivedTypeStmt (typeParamDefStmt)* (privateOrSequence)* componentPart? typeBoundProcedurePart? endTypeStmt;

// R760 enum-def-stmt -> ENUM, BIND(C) [:: enum-type-name]
enumDefStmt: ENUM COMMA BINDC (DOUBLECOLON enumTypeName)?;

// R762 enumerator -> named-constant [= scalar-int-constant-expr]
enumerator: namedConstant (ASSIGN scalarIntConstantExpr)?;

enumeratorList: enumerator (COMMA enumerator)*;

// R761 enumerator-def-stmt -> ENUMERATOR [::] enumerator-list
enumeratorDefStmt: ENUMERATOR (DOUBLECOLON)? enumeratorList;

// R763 end-enum-stmt -> END ENUM
endEnumStmt: END ENUM;

// R759 enum-def -> enum-def-stmt enumerator-def-stmt [enumerator-def-stmt]... end-enum-stmt
enumDef: enumDefStmt enumeratorDefStmt+ endEnumStmt;

// R1507 specific-procedure -> procedure-name
specificProcedure: procedureName;

specificProcedureList: specificProcedure (COMMA specificProcedure)*;

// R1510 generic-stmt ->
//         GENERIC [, access-spec] :: generic-spec => specific-procedure-list
genericStmt:
    GENERIC (COMMA accessSpec)? DOUBLECOLON genericSpec IMPLIES specificProcedureList;

// R1503 interface-stmt -> INTERFACE [generic-spec] | ABSTRACT INTERFACE
interfaceStmt:
    INTERFACE genericSpec? |
    ABSTRACT INTERFACE;

// R1505 interface-body ->
//         function-stmt [specification-part] end-function-stmt |
//         subroutine-stmt [specification-part] end-subroutine-stmt
interfaceBody:
    functionStmt specificationPart? endFunctionStmt |
    subroutineStmt specificationPart? endSubroutineStmt;

// R1506 procedure-stmt -> [MODULE] PROCEDURE [::] specific-procedure-list
procedureStmt:
    (MODULE)? PROCEDURE DOUBLECOLON? specificProcedureList;

// R1502 interface-specification -> interface-body | procedure-stmt
interfaceSpecification:
    interfaceBody | procedureStmt;		

// R1504 end-interface-stmt -> END INTERFACE [generic-spec]
endInterfaceStmt:
    END INTERFACE genericSpec?;		

// R1501 interface-block ->
//         interface-stmt [interface-specification]... end-interface-stmt
interfaceBlock:
    interfaceStmt interfaceSpecification* endInterfaceStmt;		

// R828 intent-spec -> IN | OUT | INOUT
intentSpec: IN | OUT | INOUT;

// R1514 proc-attr-spec ->
//         access-spec | proc-language-binding-spec | INTENT ( intent-spec ) |
//         OPTIONAL | POINTER | PROTECTED | SAVE
procAttrSpec:
    accessSpec | procLanguageBindingSpec | INTENT LPAREN intentSpec RPAREN |
    OPTIONAL | POINTER | PROTECTED | SAVE;

// R1512 procedure-declaration-stmt ->
//         PROCEDURE ( [proc-interface] ) [[, proc-attr-spec]... ::]  proc-decl-list
procedureDeclarationStmt:
    PROCEDURE LPAREN procInterface? RPAREN ((COMMA procAttrSpec)* DOUBLECOLON)? procDeclList;

accessName: name;

// R831 access-id -> access-name | generic-spec
accessId: accessName | genericSpec;

accessIdList: accessId (COMMA accessId)*;

// R830 access-stmt -> access-spec [[::] access-id-list]
accessStmt: accessSpec (DOUBLECOLON? accessIdList)?;

// R819 explicit-bounds-expr -> int-expr
explicitBoundsExpr: intExpr;

// R818 explicit-shape-bounds-spec -> [explicit-bounds-expr :] explicit-bounds-expr 
// | lower-bound : explicit-bounds-expr | explicit-bounds-expr : upper-bound
explicitShapeBoundsSpec: (explicitBoundsExpr COLON)? explicitBoundsExpr 
						| lowerBound COLON explicitBoundsExpr
						| explicitBoundsExpr COLON upperBound;

// R820 assumed-shape-spec -> [lower-bound] :
assumedShapeSpec: (lowerBound)? COLON;

assumedShapeSpecList: assumedShapeSpec (COMMA assumedShapeSpec)*;

// R821 assumed-shape-bounds-spec -> explicit-bounds-expr :
assumedShapeBoundsSpec: explicitBoundsExpr COLON;

// R823 assumed-implied-spec -> [lower-bound :] *
assumedImpliedSpec: (lowerBound COLON)? ASTERIK;

// R824 assumed-size-spec -> explicit-shape-spec-list , assumed-implied-spec
assumedSizeSpec: explicitShapeSpecList COMMA assumedImpliedSpec;

assumedImpliedSpecList: assumedImpliedSpec (COMMA assumedImpliedSpec)*;

// R826 implied-shape-spec -> assumed-implied-spec , assumed-implied-spec-list
impliedShapeSpec: assumedImpliedSpec COMMA assumedImpliedSpecList;

// R825 implied-shape-or-assumed-size-spec -> assumed-implied-spec
impliedShapeOrAssumedSizeSpec: assumedImpliedSpec;

// R827 assumed-rank-spec -> ..
assumedRankSpec: DOUBLEDOT;

// R814 array-spec -> explicit-shape-spec-list | explicit-shape-bounds-spec | assumed-shape-spec-list | assumed-shape-bounds-spec
//| deferred-shape-spec-list | assumed-size-spec | implied-shape-spec | implied-shape-or-assumed-size-spec | assumed-rank-spec
arraySpec:
	explicitShapeSpecList
	| explicitShapeBoundsSpec
	| assumedShapeSpecList
	| assumedShapeBoundsSpec
	| deferredShapeSpecList
	| assumedSizeSpec
	| impliedShapeSpec
	| impliedShapeOrAssumedSizeSpec
	| assumedRankSpec;

// R833 allocatable-decl -> object-name [( array-spec )] [lbracket coarray-spec rbracket]
allocatableDecl: objectName (LPAREN arraySpec RPAREN)? (lbracket coarraySpec rbracket)?;

allocatableDeclList: allocatableDecl (COMMA allocatableDecl)*;

// R832 allocatable-stmt -> ALLOCATABLE [::] allocatable-decl-list
allocatableStmt: ALLOCATABLE DOUBLECOLON? allocatableDeclList;

objectNameList: objectName (COMMA objectName)*;

// R834 asynchronous-stmt -> ASYNCHRONOUS [::] object-name-list
asynchronousStmt: ASYNCHRONOUS DOUBLECOLON? objectNameList;

entityName: name;

commonBlockName: name;

// R836 bind-entity -> entity-name | / common-block-name /
bindEntity: entityName | SLASH commonBlockName SLASH;

bindEntityList: bindEntity (COMMA bindEntity)*;

// R835 bind-stmt -> language-binding-spec [::] bind-entity-list
bindStmt: languageBindingSpec DOUBLECOLON? bindEntityList;

coarrayName: name;

// R838 codimension-decl -> coarray-name lbracket coarray-spec rbracket
codimensionDecl: coarrayName lbracket coarraySpec rbracket;

codimensionDeclList: codimensionDecl (COMMA codimensionDecl)*;

// R837 codimension-stmt -> CODIMENSION [::] codimension-decl-list
codimensionStmt: CODIMENSION DOUBLECOLON? codimensionDeclList;

// R839 contiguous-stmt -> CONTIGUOUS [::] object-name-list
contiguousStmt: CONTIGUOUS DOUBLECOLON? objectNameList;

arrayName: name;

// R851 dimension-stmt -> DIMENSION [::] array-name ( array-spec ) [, array-name ( array-spec )]...
dimensionStmt:
	DIMENSION DOUBLECOLON? arrayName LPAREN arraySpec RPAREN (COMMA arrayName LPAREN arraySpec RPAREN)*;

externalName: name;

externalNameList: externalName (COMMA externalName)*;

// R1511 external-stmt -> EXTERNAL [::] external-name-list
externalStmt:
    EXTERNAL DOUBLECOLON? externalNameList;

// R852 intent-stmt -> INTENT ( intent-spec ) [::] dummy-arg-name-list
intentStmt:
	INTENT LPAREN intentSpec RPAREN DOUBLECOLON? dummyArgNameList;

intrinsicProcedureName: name;

intrinsicProcedureNameList: intrinsicProcedureName (COMMA intrinsicProcedureName)*;

// R1519 intrinsic-stmt -> INTRINSIC [::] intrinsic-procedure-name-list
intrinsicStmt:
    INTRINSIC DOUBLECOLON? intrinsicProcedureNameList;

namelistGroupName: name;

// R872 namelist-group-object -> variable-name
namelistGroupObject: variableName;

namelistGroupObjectList: namelistGroupObject (COMMA namelistGroupObject)*;

// R871 namelist-stmt -> NAMELIST / namelist-group-name / namelist-group-object-list [[,] /
// namelist-group-name / namelist-group-object-list]...
namelistStmt:
	NAMELIST SLASH namelistGroupName SLASH namelistGroupObjectList 
	( COMMA? SLASH namelistGroupName SLASH namelistGroupObjectList)*;

// R853 optional-stmt -> OPTIONAL [::] dummy-arg-name-list
optionalStmt: OPTIONAL DOUBLECOLON? dummyArgNameList;			

procEntityName: name;

procptrEntityName: name;

// R857 pointer-decl -> object-name [( deferred-shape-spec-list )] | procptr-entity-name
pointerDecl:  objectName (LPAREN deferredShapeSpecList RPAREN)? | procptrEntityName;

pointerDeclList: pointerDecl (COMMA pointerDecl)*;

// R856 pointer-stmt -> POINTER [::] pointer-decl-list
pointerStmt: POINTER DOUBLECOLON? pointerDeclList;

entityNameList: entityName (COMMA entityName)*;

// R858 protected-stmt -> PROTECTED [::] entity-name-list
protectedStmt: PROTECTED DOUBLECOLON? entityNameList;

// R861 proc-pointer-name -> name
procPointerName: name;

// R860 saved-entity -> object-name | proc-pointer-name | / common-block-name /
savedEntity:
	objectName
	| procPointerName
	| SLASH commonBlockName SLASH;

savedEntityList: savedEntity (COMMA savedEntity)*;

// R859 save-stmt -> SAVE [[::] saved-entity-list]
saveStmt: SAVE (DOUBLECOLON? savedEntityList)?;

// R863 target-decl -> object-name [( array-spec )] [lbracket coarray-spec rbracket]
targetDecl:
	objectName (LPAREN arraySpec RPAREN)? (lbracket coarraySpec rbracket)?;

targetDeclList: targetDecl (COMMA targetDecl)*;

// R862 target-stmt -> TARGET [::] target-decl-list
targetStmt: TARGET DOUBLECOLON? targetDeclList;

// R865 volatile-stmt -> VOLATILE [::] object-name-list
volatileStmt: VOLATILE DOUBLECOLON? objectNameList;

// R864 value-stmt -> VALUE [::] dummy-arg-name-list
valueStmt: VALUE DOUBLECOLON? dummyArgNameList;

// R877 common-block-object -> variable-name [( array-spec )]
commonBlockObject: variableName ( LPAREN arraySpec RPAREN)?;

commonBlockObjectList: commonBlockObject (COMMA commonBlockObject)*;

// R876 common-stmt -> COMMON [/ [common-block-name] /] common-block-object-list [[,] /
// [common-block-name] / common-block-object-list]...
commonStmt:
	COMMON (SLASH commonBlockName? SLASH)? commonBlockObjectList 
	(COMMA? SLASH commonBlockName? SLASH commonBlockObjectList)*;

// R875 equivalence-object -> variable-name | array-element | substring
equivalenceObject: variableName | arrayElement | substring;

equivalenceObjectList: equivalenceObject (COMMA equivalenceObject)*;

// R874 equivalence-set -> ( equivalence-object , equivalence-object-list )
equivalenceSet:
	LPAREN equivalenceObject COMMA equivalenceObjectList RPAREN;

equivalenceSetList: equivalenceSet (COMMA equivalenceSet)*;

// R873 equivalence-stmt -> EQUIVALENCE equivalence-set-list
equivalenceStmt: EQUIVALENCE equivalenceSetList;

// R513 other-specification-stmt -> access-stmt | allocatable-stmt | asynchronous-stmt | bind-stmt |
// codimension-stmt | contiguous-stmt | dimension-stmt | external-stmt | intent-stmt |
// intrinsic-stmt | namelist-stmt | optional-stmt | pointer-stmt | protected-stmt | save-stmt |
// target-stmt | volatile-stmt | value-stmt | common-stmt | equivalence-stmt
otherSpecificationStmt:
	accessStmt
	| allocatableStmt
	| asynchronousStmt
	| bindStmt
	| codimensionStmt
	| contiguousStmt
	| dimensionStmt
	| externalStmt
	| intentStmt
	| intrinsicStmt
	| namelistStmt
	| optionalStmt
	| pointerStmt
	| protectedStmt
	| saveStmt
	| targetStmt
	| volatileStmt
	| valueStmt
	| commonStmt
	| equivalenceStmt;

// R829 rank-clause -> RANK ( scalar-int-constant-expr )
rankClause: RANK LPAREN scalarIntConstantExpr RPAREN;

// R802 attr-spec -> access-spec | ALLOCATABLE | ASYNCHRONOUS | CODIMENSION lbracket coarray-spec
// rbracket | CONTIGUOUS | DIMENSION ( array-spec ) | EXTERNAL | INTENT ( intent-spec ) | INTRINSIC
// | language-binding-spec | OPTIONAL | PARAMETER | POINTER | PROTECTED | rankClause | SAVE | TARGET | VALUE | VOLATILE
attrSpec:
	accessSpec
	| ALLOCATABLE
	| ASYNCHRONOUS
	| CODIMENSION lbracket coarraySpec rbracket
	| CONTIGUOUS
	| DIMENSION LPAREN arraySpec RPAREN
	| EXTERNAL
	| INTENT LPAREN intentSpec RPAREN
	| INTRINSIC
	| languageBindingSpec
	| OPTIONAL
	| PARAMETER
	| POINTER
	| PROTECTED
	| rankClause
	| SAVE
	| TARGET
	| VALUE
	| VOLATILE;

// R744 initial-data-target -> designator
initialDataTarget: designator;

// R805 initialization -> = constant-expr | => null-init | => initial-data-target
initialization:
	ASSIGN constantExpr
	| IMPLIES nullInit
	| IMPLIES initialDataTarget;

// R803 entity-decl -> object-name [( array-spec )] [lbracket coarray-spec rbracket] [* char-length]
// [initialization] | function-name [* char-length]
entityDecl:
	objectName (LPAREN arraySpec RPAREN)? (lbracket coarraySpec rbracket)? (ASTERIK charLength)? (initialization)?
	| functionName (ASTERIK charLength)?;

entityDeclList: entityDecl (COMMA entityDecl)*;

// R801 type-declaration-stmt -> declaration-type-spec [[, attr-spec]... ::] entity-decl-list
typeDeclarationStmt:
    declarationTypeSpec ((COMMA attrSpec)* DOUBLECOLON)? entityDeclList;

// R767 enumeration-type-stmt -> ENUMERATION TYPE [[, access-spec] ::] enumeration-type-name
enumerationTypeStmt: ENUMERATION TYPE ((COMMA accessSpec)? DOUBLECOLON)? enumerationTypeName;

enumeratorName: name;

enumeratorNameList: enumeratorName (COMMA enumeratorName)*;

// R768 enumeration-enumerator-stmt -> ENUMERATOR [::] enumerator-name-list
enumerationEnumeratorStmt: ENUMERATOR (DOUBLECOLON)? enumeratorNameList;

// R769 end-enumeration-type-stmt -> END ENUMERATION TYPE [ enumeration-type-name ]
endEnumerationTypeStmt: END ENUMERATION TYPE (enumerationTypeName)?;

// R766 enumeration-type-def -> enumeration-type-stmt enumeration-enumerator-stmt [enumeration-enumerator-stmt]... end-enumeration-type-stmt
enumerationTypeDef: enumerationTypeStmt enumerationEnumeratorStmt+ endEnumerationTypeStmt;

// R508 specification-construct -> derived-type-def | enum-def | enumeration-type-def | generic-stmt | interface-block | 
//									parameter-stmt | procedure-declaration-stmt | other-specification-stmt | type-declaration-stmt
specificationConstruct:
	derivedTypeDef
	| enumDef
	| enumerationTypeDef
	| genericStmt
	| interfaceBlock
	| parameterStmt
	| procedureDeclarationStmt
	| otherSpecificationStmt
	| typeDeclarationStmt;

// R844 data-i-do-object -> array-element | scalar-structure-component | data-implied-do
dataIDoObject:
	arrayElement
	| scalarStructureComponent
	| dataImpliedDo;

dataIDoObjectList: dataIDoObject (COMMA dataIDoObject)*;

// R845 data-i-do-variable -> do-variable
dataIDoVariable: doVariable;

// R843 data-implied-do -> ( data-i-do-object-list , [integer-type-spec ::] data-i-do-variable =
// scalar-int-constant-expr , scalar-int-constant-expr [, scalar-int-constant-expr] )
dataImpliedDo:
	LPAREN dataIDoObjectList COMMA (integerTypeSpec DOUBLECOLON)? dataIDoVariable ASSIGN scalarIntConstantExpr COMMA
		scalarIntConstantExpr (COMMA scalarIntConstantExpr)? RPAREN;

// R842 data-stmt-object -> variable | data-implied-do
dataStmtObject: variable | dataImpliedDo;

dataStmtObjectList: dataStmtObject (COMMA dataStmtObject)*;

// R604 constant -> literal-constant | named-constant
constant: literalConstant | namedConstant;

// R607 int-constant -> constant
intConstant: constant;

scalarIntConstant: intConstant;

// R850 constant-subobject -> designator
constantSubobject: designator;

// R849 int-constant-subobject -> constant-subobject
intConstantSubobject: constantSubobject;

scalarIntConstantSubobject: intConstantSubobject;

// R847 data-stmt-repeat -> scalar-int-constant | scalar-int-constant-subobject
dataStmtRepeat: scalarIntConstant | scalarIntConstantSubobject;

scalarConstant: constant;

scalarConstantSubobject: constantSubobject;

// R765 enum-constructor -> enum-type-spec ( scalar-expr )
enumConstructor: enumTypeSpec LPAREN scalarExpr RPAREN;

// R771 enumeration-constructor -> enumeration-type-spec ( scalar-int-expr )
enumerationConstructor: enumerationTypeSpec LPAREN scalarIntExpr RPAREN;

// R848 data-stmt-constant -> scalar-constant | scalar-constant-subobject |
// signed-int-literal-constant | signed-real-literal-constant | null-init | initial-data-target |
// structure-constructor | enum-constructor | enumeration-constructor
dataStmtConstant:
	scalarConstant
	| scalarConstantSubobject
	| signedIntLiteralConstant
	| signedRealLiteralConstant
	| nullInit
	| initialDataTarget
	| structureConstructor
	| enumConstructor
	| enumerationConstructor;

// R846 data-stmt-value -> [data-stmt-repeat *] data-stmt-constant
dataStmtValue: (dataStmtRepeat ASTERIK)? dataStmtConstant;

dataStmtValueList: dataStmtValue (COMMA dataStmtValue)*;

// R841 data-stmt-set -> data-stmt-object-list / data-stmt-value-list /
dataStmtSet: dataStmtObjectList SLASH dataStmtValueList SLASH;

// R840 data-stmt -> DATA data-stmt-set [[,] data-stmt-set]...
dataStmt: DATA dataStmtSet (COMMA? dataStmtSet)*;

// R1547 stmt-function-stmt ->
//         function-name ( [dummy-arg-name-list] ) = scalar-expr
stmtFunctionStmt:
    functionName LPAREN (dummyArgNameList)? RPAREN ASSIGN scalarExpr;

// R507 declaration-construct -> specification-construct | data-stmt | format-stmt | entry-stmt |
// stmt-function-stmt
declarationConstruct:
	specificationConstruct
	| dataStmt
	| formatStmt
	| entryStmt
	| stmtFunctionStmt;

//R504 specification-part -> [use-stmt]... [import-stmt]... [implicit-part]
// [declaration-construct]...
specificationPart:
		(useStmt)* (importStmt)* (implicitPart)? (declarationConstruct)*;

// R934 allocate-object -> variable-name | structure-component
allocateObject: variableName | structureComponent;

// R936 lower-bound-expr -> scalar-int-expr
lowerBoundExpr: scalarIntExpr;

// R938 upper-bound-expr -> scalar-int-expr
upperBoundExpr: scalarIntExpr;

// R935 allocate-shape-spec -> [lower-bound-expr :] upper-bound-expr
allocateShapeSpec: (lowerBoundExpr COLON)? upperBoundExpr;

allocateShapeSpecList: allocateShapeSpec (COMMA allocateShapeSpec)*;

// R937 lower-bounds-expr -> int-expr
lowerBoundsExpr: intExpr;

// R939 upper-bounds-expr -> int-expr
upperBoundsExpr: intExpr;

// R941 allocate-coshape-spec -> [lower-bound-expr :] upper-bound-expr
allocateCoshapeSpec: (lowerBoundExpr COLON)? upperBoundExpr;

allocateCoshapeSpecList: allocateCoshapeSpec (COMMA allocateCoshapeSpec)*;

// R940 allocate-coarray-spec ->
//        [allocate-coshape-spec-list ,] [lower-bound-expr :] *
allocateCoarraySpec:
    (allocateCoshapeSpecList COMMA)? (lowerBoundExpr COLON)? ASTERIK;

// R933 allocation ->
//        allocate-object [( allocate-shape-spec-list )]
//        [lbracket allocate-coarray-spec rbracket]
//       | [lower-bounds-expr :] upper-bounds-expr
//        [lbracket allocate-coarray-spec rbracket]
allocation:
    allocateObject ( LPAREN allocateShapeSpecList RPAREN )? ( lbracket allocateCoarraySpec rbracket )?
	| (lowerBoundsExpr COLON)? upperBoundsExpr (lbracket allocateCoarraySpec rbracket)?;

allocationList: allocation (COMMA allocation)*;

// R906 default-char-variable -> variable
defaultCharVariable: variable;

scalarDefaultCharVariable: defaultCharVariable;

// R931 errmsg-variable -> scalar-default-char-variable
errmsgVariable: scalarDefaultCharVariable;

// R932 source-expr -> expr
sourceExpr: expr;

// R930 alloc-opt ->
//        ERRMSG = errmsg-variable | MOLD = source-expr |
//        SOURCE = source-expr | STAT = stat-variable
allocOpt:
    ERRMSG ASSIGN errmsgVariable |
    MOLD ASSIGN sourceExpr |
    SOURCE ASSIGN sourceExpr |
    STAT ASSIGN statVariable;

allocOptList: allocOpt (COMMA allocOpt)*;

// R929 allocate-stmt ->
//        ALLOCATE ( [type-spec ::] allocation-list [, alloc-opt-list] )
allocateStmt:
    ALLOCATE LPAREN (typeSpec DOUBLECOLON)? allocationList (COMMA allocOptList)? RPAREN;

// R1033 assignment-stmt -> variable = expr
assignmentStmt: variable ASSIGN expr;

// R1202 file-unit-number -> scalar-int-expr
fileUnitNumber: scalarIntExpr;

// R1207 iomsg-variable -> scalar-default-char-variable
iomsgVariable: scalarDefaultCharVariable;

// R1227 position-spec ->
//         [UNIT =] file-unit-number | IOMSG = iomsg-variable |
//         IOSTAT = stat-variable | ERR = label
positionSpec:
    (UNIT ASSIGN)? fileUnitNumber |
    IOMSG ASSIGN iomsgVariable |
    IOSTAT ASSIGN statVariable |
    ERR ASSIGN label;

positionSpecList: positionSpec (COMMA positionSpec)*;

// R1224 backspace-stmt ->
//         BACKSPACE file-unit-number | BACKSPACE ( position-spec-list )
backspaceStmt: BACKSPACE fileUnitNumber | BACKSPACE LPAREN positionSpecList RPAREN;

// R1521 call-stmt -> CALL procedure-designator [( [actual-arg-spec-list] )]
callStmt:
    CALL procedureDesignator (LPAREN actualArgSpecList? RPAREN)?;

scalarDefaultCharExpr: defaultCharExpr;

// R1209 close-spec ->
//         [UNIT =] file-unit-number | IOSTAT = stat-variable |
//         IOMSG = iomsg-variable | ERR = label |
//         STATUS = scalar-default-char-expr
closeSpec:
    (UNIT ASSIGN)? fileUnitNumber |
    IOSTAT ASSIGN statVariable |
    IOMSG ASSIGN iomsgVariable |
    ERR ASSIGN label |
    STATUS ASSIGN scalarDefaultCharExpr;

closeSpecList: closeSpec (COMMA closeSpec)*;

// R1208 close-stmt -> CLOSE ( close-spec-list )
closeStmt: CLOSE LPAREN closeSpecList RPAREN;

// R1161 continue-stmt -> CONTINUE
continueStmt: CONTINUE;

doConstructName: name;

// R1135 cycle-stmt -> CYCLE [do-construct-name]
cycleStmt: CYCLE doConstructName?;

allocateObjectList: allocateObject (COMMA allocateObject)*;

// R945 dealloc-opt -> STAT = stat-variable | ERRMSG = errmsg-variable
deallocOpt: STAT ASSIGN statVariable | ERRMSG ASSIGN errmsgVariable;

deallocOptList: deallocOpt (COMMA deallocOpt)*;

// R944 deallocate-stmt ->
//        DEALLOCATE ( allocate-object-list [, dealloc-opt-list] )
deallocateStmt: DEALLOCATE LPAREN allocateObjectList (COMMA deallocOptList)? RPAREN;

// R1225 endfile-stmt -> ENDFILE file-unit-number | ENDFILE ( position-spec-list )
endfileStmt: ENDFILE fileUnitNumber | ENDFILE LPAREN positionSpecList RPAREN;

// R1164 stop-code -> scalar-default-char-expr | scalar-int-expr
stopCode: scalarDefaultCharExpr | scalarIntExpr;

// R1025 logical-expr -> expr
logicalExpr: expr;

scalarLogicalExpr: logicalExpr;

// R1163 error-stop-stmt -> ERROR STOP [stop-code] [, QUIET = scalar-logical-expr]
errorStopStmt: ERROR STOP stopCode? (COMMA QUIET ASSIGN scalarLogicalExpr)?;

scalarVariable: variable;

// R1175 event-variable -> scalar-variable
eventVariable: scalarVariable;

// R1169 sync-stat -> STAT = stat-variable | ERRMSG = errmsg-variable
syncStat: STAT ASSIGN statVariable | ERRMSG ASSIGN errmsgVariable;

syncStatList: syncStat (COMMA syncStat)*;

// R1174 event-post-stmt -> EVENT POST ( event-variable [, sync-stat-list] )
eventPostStmt: EVENT POST LPAREN eventVariable (COMMA syncStatList)? RPAREN;

// R1178 until-spec -> UNTIL_COUNT = scalar-int-expr
untilSpec: UNTILCOUNT ASSIGN scalarIntExpr;

// R1177 event-wait-spec -> until-spec | sync-stat
eventWaitSpec: untilSpec | syncStat;

eventWaitSpecList: eventWaitSpec (COMMA eventWaitSpec)*;

// R1176 event-wait-stmt -> EVENT WAIT ( event-variable [, event-wait-spec-list] )
eventWaitStmt: EVENT WAIT LPAREN eventVariable (COMMA eventWaitSpecList)? RPAREN;

constructName: name;

// R1158 exit-stmt -> EXIT [construct-name]
exitStmt: EXIT constructName?;

// R1165 fail-image-stmt -> FAIL IMAGE
failImageStmt: FAIL IMAGE;

// R1229 flush-spec ->
//         [UNIT =] file-unit-number | IOSTAT = stat-variable |
//         IOMSG = iomsg-variable | ERR = label
flushSpec:
    (UNIT ASSIGN)? fileUnitNumber |
    IOSTAT ASSIGN statVariable |
    IOMSG ASSIGN iomsgVariable |
    ERR ASSIGN label;

flushSpecList: flushSpec (COMMA flushSpec)*;

// R1228 flush-stmt -> FLUSH file-unit-number | FLUSH ( flush-spec-list )
flushStmt:
    FLUSH fileUnitNumber |
    FLUSH LPAREN flushSpecList RPAREN;

// R1180 team-number -> scalar-int-expr
teamNumber: scalarIntExpr;

// R1181 team-variable -> scalar-variable
teamVariable:  scalarVariable;

// R1182 form-team-spec -> NEW_INDEX = scalar-int-expr | sync-stat
formTeamSpec: NEWINDEX ASSIGN scalarIntExpr | syncStat;

formTeamSpecList: formTeamSpec (COMMA formTeamSpec)*;

// R1179 form-team-stmt ->
//         FORM TEAM ( team-number , team-variable [, form-team-spec-list] )
formTeamStmt:
    FORM TEAM LPAREN teamNumber COMMA teamVariable (COMMA formTeamSpecList)? RPAREN;

// R1159 goto-stmt -> GO TO label
gotoStmt: GOTO label;

// R1141 if-stmt -> IF ( scalar-logical-expr ) action-stmt
ifStmt: IF LPAREN scalarLogicalExpr RPAREN actionStmt;

// R1206 file-name-expr -> scalar-default-char-expr
fileNameExpr: scalarDefaultCharExpr;

// R904 logical-variable -> variable
logicalVariable: variable;

scalarLogicalVariable: logicalVariable;

// R1231 inquire-spec ->
//         [UNIT =] file-unit-number | FILE = file-name-expr |
//         ACCESS = scalar-default-char-variable |
//         ACTION = scalar-default-char-variable |
//         ASYNCHRONOUS = scalar-default-char-variable |
//         BLANK = scalar-default-char-variable |
//         DECIMAL = scalar-default-char-variable |
//         DELIM = scalar-default-char-variable |
//		   DIRECT = scalar-default-char-variable |
//         ENCODING = scalar-default-char-variable |
//         ERR = label | EXIST = scalar-logical-variable |
//         FORM = scalar-default-char-variable |
//         FORMATTED = scalar-default-char-variable | ID = scalar-int-expr |
//         IOMSG = iomsg-variable | IOSTAT = stat-variable |
//         LEADING_ZERO = scalar-default-char-variable |
//         NAME = scalar-default-char-variable |
//         NAMED = scalar-logical-variable | NEXTREC = scalar-int-variable |
//         NUMBER = scalar-int-variable | OPENED = scalar-logical-variable |
//         PAD = scalar-default-char-variable |
//         PENDING = scalar-logical-variable | POS = scalar-int-variable |
//         POSITION = scalar-default-char-variable |
//         READ = scalar-default-char-variable |
//         READWRITE = scalar-default-char-variable |
//         RECL = scalar-int-variable | ROUND = scalar-default-char-variable |
//         SEQUENTIAL = scalar-default-char-variable |
//         SIGN = scalar-default-char-variable | SIZE = scalar-int-variable |
//         STREAM = scalar-default-char-variable |
//         UNFORMATTED = scalar-default-char-variable |
//         WRITE = scalar-default-char-variable
inquireSpec:
    (UNIT ASSIGN)? fileUnitNumber |
    FILE ASSIGN fileNameExpr |
	ACCESS ASSIGN scalarDefaultCharVariable |
    ACTION ASSIGN scalarDefaultCharVariable |
    ASYNCHRONOUS ASSIGN scalarDefaultCharVariable |
    BLANK ASSIGN scalarDefaultCharVariable |
    DECIMAL ASSIGN scalarDefaultCharVariable |
    DELIM ASSIGN scalarDefaultCharVariable |
    DIRECT ASSIGN scalarDefaultCharVariable |
    ENCODING ASSIGN scalarDefaultCharVariable |
    ERR ASSIGN label |
    EXIST ASSIGN scalarLogicalVariable |
    FORM ASSIGN scalarDefaultCharVariable |
    FORMATTED ASSIGN scalarDefaultCharVariable |
    ID ASSIGN scalarIntExpr |
    IOMSG ASSIGN iomsgVariable |
    IOSTAT ASSIGN statVariable |
	LEADINGZERO ASSIGN scalarDefaultCharVariable |
    NAAM ASSIGN scalarDefaultCharVariable |
    NAMED ASSIGN scalarLogicalVariable |
    NEXTREC ASSIGN scalarIntVariable |
    NUMBER ASSIGN scalarIntVariable |
    OPENED ASSIGN scalarLogicalVariable |
    PAD ASSIGN scalarDefaultCharVariable |
    PENDING ASSIGN scalarLogicalVariable |
    POS ASSIGN scalarIntVariable |
    POSITION ASSIGN scalarDefaultCharVariable |
    READ ASSIGN scalarDefaultCharVariable |
    READWRITE ASSIGN scalarDefaultCharVariable |
    RECL ASSIGN scalarIntVariable |
    ROUND ASSIGN scalarDefaultCharVariable |
    SEQUENTIAL ASSIGN scalarDefaultCharVariable |
    SIGN ASSIGN scalarDefaultCharVariable |
    SIZE ASSIGN scalarIntVariable |
    STREAM ASSIGN scalarDefaultCharVariable |
    UNFORMATTED ASSIGN scalarDefaultCharVariable |
    WRITE ASSIGN scalarDefaultCharVariable;

inquireSpecList: inquireSpec (COMMA inquireSpec)*;

// R1216 input-item -> variable | io-implied-do
inputItem: variable | ioImpliedDo;

// R1219 io-implied-do-object -> input-item | output-item
ioImpliedDoObject: inputItem | outputItem;

ioImpliedDoObjectList: ioImpliedDoObject (COMMA ioImpliedDo)*;

// R1220 io-implied-do-control ->
//         do-variable = scalar-int-expr , scalar-int-expr [, scalar-int-expr]
ioImpliedDoControl: doVariable ASSIGN scalarIntExpr COMMA scalarIntExpr (COMMA scalarIntExpr)?;

// R1218 io-implied-do -> ( io-implied-do-object-list , io-implied-do-control )
ioImpliedDo: LPAREN ioImpliedDoObjectList COMMA ioImpliedDoControl RPAREN;

// R1217 output-item -> expr | io-implied-do
outputItem: expr | ioImpliedDo;

outputItemList: outputItem (COMMA outputItem)*;

// R1230 inquire-stmt ->
//         INQUIRE ( inquire-spec-list ) |
//         INQUIRE ( IOLENGTH = scalar-int-variable ) output-item-list
inquireStmt:
    INQUIRE LPAREN inquireSpecList RPAREN |
    INQUIRE LPAREN IOLENGTH ASSIGN scalarIntVariable RPAREN outputItemList;

// R1166 notify-wait-stmt -> NOTIFY WAIT ( notify-variable [, event-wait-spec-list ] )
notifyWaitStmt: NOTIFY WAIT LPAREN notifyVariable (COMMA eventWaitSpecList)? RPAREN;

// R1186 lock-variable -> scalar-variable
lockVariable: scalarVariable;

// R1185 lock-stat -> ACQUIRED_LOCK = scalar-logical-variable | sync-stat
lockStat: ACQUIREDLOCK ASSIGN scalarLogicalVariable | syncStat;

lockStatList: lockStat (COMMA lockStat)*;

// R1183 lock-stmt -> LOCK ( lock-variable [, lock-stat-list] )
lockStmt: LOCK LPAREN lockVariable (COMMA lockStatList)? RPAREN;

// R943 pointer-object -> variable-name | structure-component | proc-pointer-name
pointerObject: variableName | structureComponent | procPointerName;

pointerObjectList: pointerObject (COMMA pointerObject)*;

// R942 nullify-stmt -> NULLIFY ( pointer-object-list )
nullifyStmt: NULLIFY LPAREN pointerObjectList RPAREN;

// R1205 connect-spec ->
//         [UNIT =] file-unit-number | ACCESS = scalar-default-char-expr |
//         ACTION = scalar-default-char-expr |
//         ASYNCHRONOUS = scalar-default-char-expr |
//         BLANK = scalar-default-char-expr |
//         DECIMAL = scalar-default-char-expr | DELIM = scalar-default-char-expr |
//         ENCODING = scalar-default-char-expr | ERR = label |
//         FILE = file-name-expr | FORM = scalar-default-char-expr |
//         IOMSG = iomsg-variable | IOSTAT =stat-variable | LEADING_ZERO = scalar-default-char-expr |
//         NEWUNIT = scalar-int-variable | PAD = scalar-default-char-expr |
//         POSITION = scalar-default-char-expr | RECL = scalar-int-expr |
//         ROUND = scalar-default-char-expr | SIGN = scalar-default-char-expr |
//         STATUS = scalar-default-char-expr
connectSpec:
    (UNIT ASSIGN)? fileUnitNumber |
    ACCESS ASSIGN scalarDefaultCharExpr |
    ACTION ASSIGN scalarDefaultCharExpr |
    ASYNCHRONOUS ASSIGN scalarDefaultCharExpr |
    BLANK ASSIGN scalarDefaultCharExpr |
    DECIMAL ASSIGN scalarDefaultCharExpr |
    DELIM ASSIGN scalarDefaultCharExpr |
    ENCODING ASSIGN scalarDefaultCharExpr |
    ERR ASSIGN label |
    FILE ASSIGN fileNameExpr |
    FORM ASSIGN scalarDefaultCharExpr |
    IOMSG ASSIGN iomsgVariable |
    IOSTAT ASSIGN statVariable |
	LEADINGZERO ASSIGN scalarDefaultCharExpr |
    NEWUNIT ASSIGN scalarIntVariable |
    PAD ASSIGN scalarDefaultCharExpr |
    POSITION ASSIGN scalarDefaultCharExpr |
    RECL ASSIGN scalarIntExpr |
    ROUND ASSIGN scalarDefaultCharExpr |
    SIGN ASSIGN scalarDefaultCharExpr |
    STATUS ASSIGN scalarDefaultCharExpr;

connectSpecList: connectSpec (COMMA connectSpec)*;

// R1204 open-stmt -> OPEN ( connect-spec-list )
openStmt: OPEN LPAREN connectSpecList RPAREN;

dataPointerComponentName: name;

// R1035 data-pointer-object ->
//         variable-name | scalar-variable % data-pointer-component-name
dataPointerObject: variableName
                 | scalarVariable PERCENT dataPointerComponentName;

// R1036 bounds-spec -> lower-bound-expr :
boundsSpec: lowerBoundExpr COLON;

boundsSpecList: boundsSpec (COMMA boundsSpec)*;

// R1037 bounds-remapping -> lower-bound-expr : upper-bound-expr
boundsRemapping: lowerBoundExpr COLON upperBoundExpr;

boundsRemappingList: boundsRemapping (COMMA boundsRemapping)*;

// R1039 proc-pointer-object -> proc-pointer-name | proc-component-ref
procPointerObject: procPointerName | procComponentRef;

// R1034 pointer-assignment-stmt ->
//         data-pointer-object [( bounds-spec-list )] => data-target |
//         data-pointer-object ( lower-bounds-expr : ) => data-target |
//         data-pointer-object ( bounds-remapping-list ) => data-target |
//         data-pointer-object ( lower-bounds-expr : upper-bounds-expr ) => data-target |
//         proc-pointer-object => proc-target
pointerAssignmentStmt: dataPointerObject (LPAREN boundsSpecList RPAREN)? IMPLIES dataTarget
				  | dataPointerObject LPAREN lowerBoundsExpr COLON RPAREN IMPLIES dataTarget
                  | dataPointerObject LPAREN boundsRemappingList RPAREN IMPLIES dataTarget
				  | dataPointerObject LPAREN lowerBoundsExpr COLON upperBoundsExpr RPAREN IMPLIES dataTarget
                  | procPointerObject IMPLIES procTarget;

// R1215 format -> default-char-expr | label | *
format: defaultCharExpr | label | ASTERIK;

// R1212 print-stmt -> PRINT format [, output-item-list]
printStmt: PRINT format (COMMA outputItemList)?;

// R905 char-variable -> variable
charVariable: variable;

// R1203 internal-file-variable -> char-variable
internalFileVariable: charVariable;

// R1201 io-unit -> file-unit-number | * | internal-file-variable
ioUnit: fileUnitNumber | ASTERIK | internalFileVariable;

// R1214 id-variable -> scalar-int-variable
idVariable: scalarIntVariable;

// R1213 io-control-spec ->
//         [UNIT =] io-unit | [FMT =] format | [NML =] namelist-group-name |
//         ADVANCE = scalar-default-char-expr |
//         ASYNCHRONOUS = scalar-default-char-constant-expr |
//         BLANK = scalar-default-char-expr | DECIMAL = scalar-default-char-expr |
//         DELIM = scalar-default-char-expr | END = label | EOR = label |
//         ERR = label | ID = id-variable | IOMSG = iomsg-variable |
//         IOSTAT = stat-variable | LEADING_ZERO = scalar-default-char-expr | PAD = scalar-default-char-expr |
//         POS = scalar-int-expr | REC = scalar-int-expr |
//         ROUND = scalar-default-char-expr | SIGN = scalar-default-char-expr |
//         SIZE = scalar-int-variable
ioControlSpec:
    (UNIT ASSIGN)? ioUnit |
    (FMT ASSIGN)? format |
    (NML ASSIGN)? namelistGroupName |
    ADVANCE ASSIGN scalarDefaultCharExpr |
    ASYNCHRONOUS ASSIGN scalarDefaultCharConstantExpr |
    BLANK ASSIGN scalarDefaultCharExpr |
    DECIMAL ASSIGN scalarDefaultCharExpr |
    DELIM ASSIGN scalarDefaultCharExpr |
    END ASSIGN label |
    EOR ASSIGN label |
    ERR ASSIGN label |
    ID ASSIGN idVariable |
    IOMSG ASSIGN iomsgVariable |
    IOSTAT ASSIGN statVariable |
	LEADINGZERO ASSIGN scalarDefaultCharExpr |
    PAD ASSIGN scalarDefaultCharExpr |
    POS ASSIGN scalarIntExpr |
    REC ASSIGN scalarIntExpr |
    ROUND ASSIGN scalarDefaultCharExpr |
    SIGN ASSIGN scalarDefaultCharExpr |
	SIZE ASSIGN scalarIntVariable;

ioControlSpecList: ioControlSpec (COMMA ioControlSpec)*;

inputItemList: inputItem (COMMA inputItem)*;

// R1210 read-stmt ->
//         READ ( io-control-spec-list ) [input-item-list] |
//         READ format [, input-item-list]
readStmt:
    READ LPAREN ioControlSpecList RPAREN (inputItemList)? |
    READ format (COMMA inputItemList)?;

// R1545 return-stmt -> RETURN [scalar-int-expr]
returnStmt:
    RETURN (scalarIntExpr)?;

// R1226 rewind-stmt -> REWIND file-unit-number | REWIND ( position-spec-list )
rewindStmt: REWIND fileUnitNumber | REWIND LPAREN positionSpecList RPAREN;

// R1162 stop-stmt -> STOP [stop-code] [, QUIET = scalar-logical-expr]
stopStmt: STOP stopCode? (COMMA QUIET ASSIGN scalarLogicalExpr)?;

// R1168 sync-all-stmt -> SYNC ALL [( [sync-stat-list] )]
syncAllStmt: SYNC ALL (LPAREN syncStatList? RPAREN)?;

// R1171 image-set -> int-expr | *
imageSet: intExpr | ASTERIK;

// R1170 sync-images-stmt -> SYNC IMAGES ( image-set [, sync-stat-list] )
syncImagesStmt: SYNC IMAGES LPAREN imageSet (COMMA syncStatList)? RPAREN;

// R1172 sync-memory-stmt -> SYNC MEMORY [( [sync-stat-list] )]
syncMemoryStmt: SYNC MEMORY (LPAREN syncStatList? RPAREN)?;

// R1173 sync-team-stmt -> SYNC TEAM ( team-value [, sync-stat-list] )
syncTeamStmt: SYNC TEAM LPAREN teamValue (COMMA syncStatList)? RPAREN;

// R1185 unlock-stmt -> UNLOCK ( lock-variable [, sync-stat-list] )
unlockStmt: UNLOCK LPAREN lockVariable (COMMA syncStatList)? RPAREN;

// R1223 wait-spec ->
//         [UNIT =] file-unit-number | END = label | EOR = label | ERR = label |
//         ID = scalar-int-expr | IOMSG = iomsg-variable |
//         IOSTAT = stat-variable
waitSpec:
    (UNIT ASSIGN)? fileUnitNumber |
    END ASSIGN label |
    EOR ASSIGN label |
    ERR ASSIGN label |
    ID ASSIGN scalarIntExpr |
    IOMSG ASSIGN iomsgVariable |
    IOSTAT ASSIGN statVariable;

waitSpecList: waitSpec (COMMA waitSpec)*;

// R1222 wait-stmt -> WAIT ( wait-spec-list )
waitStmt: WAIT LPAREN waitSpecList RPAREN;

// R1047 mask-expr -> logical-expr
maskExpr: logicalExpr;

// R1046 where-assignment-stmt -> assignment-stmt
whereAssignmentStmt: assignmentStmt;

// R1042 where-stmt -> WHERE ( mask-expr ) where-assignment-stmt
whereStmt: WHERE LPAREN maskExpr RPAREN whereAssignmentStmt;

// R1211 write-stmt -> WRITE ( io-control-spec-list ) [output-item-list]
writeStmt: WRITE LPAREN ioControlSpecList RPAREN (outputItemList)?;

labelList: label (COMMA label)*;

// R1160 computed-goto-stmt -> GO TO ( label-list ) [,] scalar-int-expr
computedGotoStmt: GOTO LPAREN labelList RPAREN COMMA? scalarIntExpr;

indexName: name;

// R1127 concurrent-limit -> scalar-int-expr
concurrentLimit: scalarIntExpr;

// R1128 concurrent-step -> scalar-int-expr
concurrentStep: scalarIntExpr;

// R1126 concurrent-control ->
//         index-name = concurrent-limit : concurrent-limit [: concurrent-step]
concurrentControl: indexName ASSIGN concurrentLimit COLON concurrentLimit (COLON concurrentStep)?;

concurrentControlList: concurrentControl (COMMA concurrentControl)*;

scalarMaskExpr: maskExpr;

// R1125 concurrent-header ->
//         ( [integer-type-spec ::] concurrent-control-list [, scalar-mask-expr] )
concurrentHeader: 
    LPAREN (integerTypeSpec DOUBLECOLON)? concurrentControlList (COMMA scalarMaskExpr)? RPAREN;

// R1054 forall-assignment-stmt -> assignment-stmt | pointer-assignment-stmt
forallAssignmentStmt: assignmentStmt | pointerAssignmentStmt;

// R1056 forall-stmt -> FORALL concurrent-header forall-assignment-stmt
forallStmt: FORALL concurrentHeader forallAssignmentStmt;

// R515 action-stmt -> allocate-stmt | assignment-stmt | backspace-stmt | call-stmt | close-stmt |
// continue-stmt | cycle-stmt | deallocate-stmt | endfile-stmt | error-stop-stmt | event-post-stmt |
// event-wait-stmt | exit-stmt | fail-image-stmt | flush-stmt | form-team-stmt | goto-stmt | if-stmt
// | inquire-stmt | lock-stmt | notify-wait-stmt | nullify-stmt | open-stmt | pointer-assignment-stmt | print-stmt |
// read-stmt | return-stmt | rewind-stmt | stop-stmt | sync-all-stmt | sync-images-stmt |
// sync-memory-stmt | sync-team-stmt | unlock-stmt | wait-stmt | where-stmt | write-stmt |
// computed-goto-stmt | forall-stmt
actionStmt:
	allocateStmt
	| assignmentStmt
	| backspaceStmt
	| callStmt
	| closeStmt
	| continueStmt
	| cycleStmt
	| deallocateStmt
	| endfileStmt
	| errorStopStmt
	| eventPostStmt
	| eventWaitStmt
	| exitStmt
	| failImageStmt
	| flushStmt
	| formTeamStmt
	| gotoStmt
	| ifStmt
	| inquireStmt
	| lockStmt
	| notifyWaitStmt
	| nullifyStmt
	| openStmt
	| pointerAssignmentStmt
	| printStmt
	| readStmt
	| returnStmt
	| rewindStmt
	| stopStmt
	| syncAllStmt
	| syncImagesStmt
	| syncMemoryStmt
	| syncTeamStmt
	| unlockStmt
	| waitStmt
	| whereStmt
	| writeStmt
	| computedGotoStmt
	| forallStmt;

associateConstructName: name;

associateName: name;

// R1105 selector -> expr | variable
selector: expr | variable;

// R1104 association -> associate-name => selector
association: associateName IMPLIES selector;

associationList: association (COMMA association)*;

// R1103 associate-stmt ->
        // [associate-construct-name :] ASSOCIATE ( association-list )
associateStmt:
    (associateConstructName COLON)? ASSOCIATE LPAREN associationList RPAREN;

// R510 execution-part-construct -> executable-construct | format-stmt | entry-stmt | data-stmt
executionPartConstruct:
	executableConstruct
	| formatStmt
	| entryStmt
	| dataStmt;

// R1101 block -> [execution-part-construct]...
block: (executionPartConstruct)*;

// R1106 end-associate-stmt -> END ASSOCIATE [associate-construct-name]
endAssociateStmt:  END ASSOCIATE associateConstructName?;

// R1102 associate-construct -> associate-stmt block end-associate-stmt
associateConstruct: associateStmt block endAssociateStmt;

blockConstructName: name;

// R1108 block-stmt -> [block-construct-name :] BLOCK
blockStmt: (blockConstructName COLON)? BLOCK;

// R1109 block-specification-part ->
//         [use-stmt]... [import-stmt]...
//         [declaration-construct]... 
blockSpecificationPart: 
    (useStmt)* (importStmt)* (declarationConstruct)*;

// R1110 end-block-stmt -> END BLOCK [block-construct-name]
endBlockStmt: END BLOCK blockConstructName?;

// R1107 block-construct ->
//         block-stmt [block-specification-part] block end-block-stmt
blockConstruct: blockStmt blockSpecificationPart? block endBlockStmt;

caseConstructName: name;

// R1146 case-expr -> scalar-expr
caseExpr: scalarExpr;

// R1143 select-case-stmt -> [case-construct-name :] SELECT CASE ( case-expr )
selectCaseStmt: (caseConstructName COLON)? SELECT CASE LPAREN caseExpr RPAREN;

scalarConstantExpr: constantExpr;

// R1149 case-value -> scalar-constant-expr
caseValue: scalarConstantExpr;

// R1148 case-value-range ->
//         case-value | case-value : | : case-value | case-value : case-value
caseValueRange: caseValue | caseValue COLON | COLON caseValue | caseValue COLON caseValue;

caseValueRangeList: caseValueRange (COMMA caseValueRange)*;

// R1147 case-selector -> ( case-value-range-list ) | DEFAULT
caseSelector: LPAREN caseValueRangeList RPAREN | DEFAULT;

// R1144 case-stmt -> CASE case-selector [case-construct-name]
caseStmt: CASE caseSelector caseConstructName?;

// R1145 end-select-stmt -> END SELECT [case-construct-name]
endSelectStmt: END SELECT caseConstructName?;

// R1142 case-construct -> select-case-stmt [case-stmt block]... end-select-stmt
caseConstruct: selectCaseStmt (caseStmt block)* endSelectStmt;

teamConstructName: name;

// R1113 coarray-association -> codimension-decl => selector
coarrayAssociation: codimensionDecl IMPLIES selector;

coarrayAssociationList: coarrayAssociation (COMMA coarrayAssociation)*;

// R1112 change-team-stmt ->
//         [team-construct-name :] CHANGE TEAM ( team-value
//         [, coarray-association-list] [, sync-stat-list] )
changeTeamStmt: (teamConstructName COLON)? CHANGE TEAM LPAREN teamValue
    (COMMA coarrayAssociationList)? (COMMA syncStatList)? RPAREN;

// R1114 end-change-team-stmt ->
//         END TEAM [( [sync-stat-list] )] [team-construct-name]
endChangeTeamStmt: END TEAM (LPAREN syncStatList? RPAREN)? teamConstructName?;

// R1111 change-team-construct -> change-team-stmt block end-change-team-stmt
changeTeamConstruct: changeTeamStmt block endChangeTeamStmt;

criticalConstructName: name;

// R1117 critical-stmt ->
//         [critical-construct-name :] CRITICAL [( [sync-stat-list] )]
criticalStmt: (criticalConstructName COLON)? CRITICAL (LPAREN syncStatList? RPAREN)?;

// R1118 end-critical-stmt -> END CRITICAL [critical-construct-name]
endCriticalStmt: END CRITICAL criticalConstructName?;

// R1116 critical-construct -> critical-stmt block end-critical-stmt
criticalConstruct: criticalStmt block endCriticalStmt;

variableNameList: variableName (COMMA variableName)*;

// R1132 binary-reduce-op -> + | * | .AND. | .OR. | .EQV. | .NEQV.
binaryReduceOp: PLUS | ASTERIK | AND | OR | EQV | NEQV;

functionReductionName: name;

// R1131 reduce-operation -> binary-reduce-op | function-reduction-name
reduceOperation: binaryReduceOp | functionReductionName;

// R1130 locality-spec ->
//         LOCAL ( variable-name-list ) | LOCAL_INIT ( variable-name-list ) | REDUCE ( reduce-operation : variable-name-list ) |
//         SHARED ( variable-name-list ) | DEFAULT ( NONE )
localitySpec:
    LOCAL LPAREN variableNameList RPAREN |
    LOCALINIT LPAREN variableNameList RPAREN |
	REDUCE LPAREN reduceOperation COLON variableNameList RPAREN |
    SHARED LPAREN variableNameList RPAREN |
    DEFAULT LPAREN NONE RPAREN;

// R1129 concurrent-locality -> [locality-spec]...
concurrentLocality: (localitySpec)*;

// R1123 loop-control ->
//         [,] do-variable = scalar-int-expr , scalar-int-expr
//           [, scalar-int-expr] |
//         [,] WHILE ( scalar-logical-expr ) |
//         [,] CONCURRENT concurrent-header concurrent-locality
loopControl:
    (COMMA)? doVariable ASSIGN scalarIntExpr COMMA scalarIntExpr (COMMA scalarIntExpr)?
    | (COMMA)? WHILE LPAREN scalarLogicalExpr RPAREN
    | (COMMA)? CONCURRENT concurrentHeader concurrentLocality;

// R1122 nonlabel-do-stmt -> [do-construct-name :] DO [loop-control]
nonlabelDoStmt: (doConstructName COLON)? DO loopControl?;

// R1121 label-do-stmt -> [do-construct-name :] DO label [loop-control]
labelDoStmt: (doConstructName COLON)? DO label loopControl?;

// R1120 do-stmt -> nonlabel-do-stmt | label-do-stmt
doStmt: nonlabelDoStmt | labelDoStmt;

// R1134 end-do-stmt -> END DO [do-construct-name]
endDoStmt: END DO doConstructName?;

// R1133 end-do -> end-do-stmt | continue-stmt
endDo: endDoStmt | continueStmt;

// R1119 do-construct -> do-stmt block end-do
doConstruct: doStmt block endDo;

ifConstructName: name;

// R1137 if-then-stmt -> [if-construct-name :] IF ( scalar-logical-expr ) THEN
ifThenStmt: (ifConstructName COLON)? IF LPAREN scalarLogicalExpr RPAREN THEN;

// R1138 else-if-stmt -> ELSE IF ( scalar-logical-expr ) THEN [if-construct-name]
elseIfStmt: ELSE IF LPAREN scalarLogicalExpr RPAREN THEN ifConstructName?;

// R1139 else-stmt -> ELSE [if-construct-name]
elseStmt: ELSE ifConstructName?;

// R1140 end-if-stmt -> END IF [if-construct-name]
endIfStmt: END IF ifConstructName?;

// R1136 if-construct ->
//         if-then-stmt block [else-if-stmt block]... [else-stmt block]
//         end-if-stmt
ifConstruct:
    ifThenStmt block (elseIfStmt block)* (elseStmt block)? endIfStmt;

selectConstructName: name;

// R1151 select-rank-stmt ->
//         [select-construct-name :] SELECT RANK ( [associate-name =>] selector )
selectRankStmt: (selectConstructName COLON)? SELECT RANK LPAREN (associateName IMPLIES)? selector RPAREN;

// R1152 select-rank-case-stmt ->
//         RANK ( scalar-int-constant-expr ) [select-construct-name] |
//         RANK ( * ) [select-construct-name] |
//         RANK DEFAULT [select-construct-name]
selectRankCaseStmt:
    RANK LPAREN scalarIntConstantExpr RPAREN selectConstructName? |
    RANK LPAREN ASTERIK RPAREN selectConstructName? |
    RANK DEFAULT selectConstructName?;

// R1153 end-select-rank-stmt -> END SELECT [select-construct-name]
endSelectRankStmt: END SELECT selectConstructName?;

// R1150 select-rank-construct ->
//         select-rank-stmt [select-rank-case-stmt block]... end-select-rank-stmt
selectRankConstruct: selectRankStmt (selectRankCaseStmt block)* endSelectRankStmt;

// R1155 select-type-stmt ->
//         [select-construct-name :] SELECT TYPE ( [associate-name =>] selector )
selectTypeStmt: (selectConstructName COLON)? SELECT TYPE LPAREN (associateName IMPLIES)? selector RPAREN;

// R1156 type-guard-stmt ->
//         TYPE IS ( type-spec ) [select-construct-name] |
//         CLASS IS ( derived-type-spec ) [select-construct-name] |
//         CLASS DEFAULT [select-construct-name]
typeGuardStmt:
    TYPE IS LPAREN typeSpec RPAREN selectConstructName? |
    CLASS IS LPAREN derivedTypeSpec RPAREN selectConstructName? |
    CLASS DEFAULT selectConstructName?;

// R1157 end-select-type-stmt -> END SELECT [select-construct-name]
endSelectTypeStmt: END SELECT selectConstructName?;

// R1154 select-type-construct ->
//         select-type-stmt [type-guard-stmt block]... end-select-type-stmt
selectTypeConstruct: selectTypeStmt (typeGuardStmt block)* endSelectTypeStmt;

whereConstructName: name;

// R1044 where-construct-stmt -> [where-construct-name :] WHERE ( mask-expr )
whereConstructStmt: (whereConstructName COLON)? WHERE LPAREN maskExpr RPAREN;

// R1045 where-body-construct ->
//         where-assignment-stmt | where-stmt | where-construct
whereBodyConstruct: whereAssignmentStmt | whereStmt | whereConstruct;

// R1048 masked-elsewhere-stmt -> ELSEWHERE ( mask-expr ) [where-construct-name]
maskedElsewhereStmt: ELSEWHERE LPAREN maskExpr RPAREN whereConstructName?;

// R1049 elsewhere-stmt -> ELSEWHERE [where-construct-name]
elsewhereStmt: ELSEWHERE whereConstructName?;

// R1050 end-where-stmt -> END WHERE [where-construct-name]
endWhereStmt: END WHERE whereConstructName?;

// R1043 where-construct ->
//         where-construct-stmt [where-body-construct]...
//         [masked-elsewhere-stmt [where-body-construct]...]...
//         [elsewhere-stmt [where-body-construct]...] end-where-stmt
whereConstruct: whereConstructStmt (whereBodyConstruct)* (maskedElsewhereStmt (whereBodyConstruct)*)* (elsewhereStmt (whereBodyConstruct)*)? endWhereStmt;

forallConstructName: name;

// R1052 forall-construct-stmt ->
//         [forall-construct-name :] FORALL concurrent-header
forallConstructStmt: (forallConstructName COLON)? FORALL concurrentHeader;

// R1053 forall-body-construct ->
//         forall-assignment-stmt | where-stmt | where-construct |
//         forall-construct | forall-stmt
forallBodyConstruct: forallAssignmentStmt | whereStmt | whereConstruct | forallConstruct | forallStmt;

// R1055 end-forall-stmt -> END FORALL [forall-construct-name]
endForallStmt: END FORALL forallConstructName?;

// R1051 forall-construct ->
//         forall-construct-stmt [forall-body-construct]... end-forall-stmt
forallConstruct: forallConstructStmt forallBodyConstruct* endForallStmt;

// R514 executable-construct -> action-stmt | associate-construct | block-construct | case-construct
// | change-team-construct | critical-construct | do-construct | if-construct |
// select-rank-construct | select-type-construct | where-construct | forall-construct
executableConstruct:
	actionStmt
	| associateConstruct
	| blockConstruct
	| caseConstruct
	| changeTeamConstruct
	| criticalConstruct
	| doConstruct
	| ifConstruct
	| selectRankConstruct
	| selectTypeConstruct
	| whereConstruct
	| forallConstruct;

// R509 execution-part -> executable-construct [execution-part-construct]...
executionPart: executableConstruct (executionPartConstruct)*;

// R512 internal-subprogram -> function-subprogram | subroutine-subprogram
internalSubprogram: functionSubprogram | subroutineSubprogram;

// R511 internal-subprogram-part -> contains-stmt [internal-subprogram]...
internalSubprogramPart: containsStmt (internalSubprogram)*;

// R1403 end-program-stmt -> END [PROGRAM [program-name]]
endProgramStmt: END (PROGRAM programName?)?;

// R1401 main-program ->
//         [program-stmt] [specification-part] [execution-part]
//         [internal-subprogram-part] end-program-stmt
mainProgram:
    programStmt? specificationPart? executionPart? internalSubprogramPart? endProgramStmt;

// R1530 prefix-spec ->
//         declaration-type-spec | ELEMENTAL | IMPURE | MODULE | NON_RECURSIVE |
//         PURE | RECURSIVE	| SIMPLE
prefixSpec:
    declarationTypeSpec | ELEMENTAL | IMPURE | MODULE | NONRECURSIVE | PURE | RECURSIVE | SIMPLE;

// R1529 prefix -> prefix-spec [prefix-spec]...
prefix:
    prefixSpec+;

functionName: name;

// R1534 dummy-arg-name -> name
dummyArgName: name;

dummyArgNameList: dummyArgName (COMMA dummyArgName)*;

// R1533 function-stmt ->
//         [prefix] FUNCTION function-name ( [dummy-arg-name-list] ) [suffix]
functionStmt:
    (prefix)? FUNCTION functionName LPAREN (dummyArgNameList)? RPAREN (suffix)?;

// R1536 end-function-stmt -> END [FUNCTION [function-name]]
endFunctionStmt:
    END (FUNCTION (functionName)?)?;

// R1532 function-subprogram ->
//         function-stmt [specification-part] [execution-part]
//         [internal-subprogram-part] end-function-stmt
functionSubprogram:
    functionStmt (specificationPart)? (executionPart)? (internalSubprogramPart)? endFunctionStmt;

subroutineName: name;

// R1538 subroutine-stmt ->
//         [prefix] SUBROUTINE subroutine-name
//         [( [dummy-arg-list] ) [proc-language-binding-spec]]
subroutineStmt:
    (prefix)? SUBROUTINE subroutineName (LPAREN (dummyArgList)? RPAREN (procLanguageBindingSpec)?)?;

// R1540 end-subroutine-stmt -> END [SUBROUTINE [subroutine-name]]
endSubroutineStmt:
    END (SUBROUTINE (subroutineName)?)?;   

// R1537 subroutine-subprogram ->
//         subroutine-stmt [specification-part] [execution-part]
//         [internal-subprogram-part] end-subroutine-stmt
subroutineSubprogram:
    subroutineStmt (specificationPart)? (executionPart)? (internalSubprogramPart)? endSubroutineStmt;   

//R503 external-subprogram -> function-subprogram | subroutine-subprogram
externalSubprogram: functionSubprogram | subroutineSubprogram;    

// R1405 module-stmt -> MODULE module-name
moduleStmt: MODULE moduleName;

// R1542 mp-subprogram-stmt -> MODULE PROCEDURE procedure-name
mpSubprogramStmt:
    MODULE PROCEDURE procedureName;

// R1543 end-mp-subprogram-stmt -> END [PROCEDURE [procedure-name]]
endMpSubprogramStmt:
    END (PROCEDURE (procedureName)?)?;

// R1541 separate-module-subprogram ->
//         mp-subprogram-stmt [specification-part] [execution-part]
//         [internal-subprogram-part] end-mp-subprogram-stmt
separateModuleSubprogram:
    mpSubprogramStmt (specificationPart)? (executionPart)? (internalSubprogramPart)? endMpSubprogramStmt;

// R1408 module-subprogram ->
//         function-subprogram | subroutine-subprogram |
//         separate-module-subprogram
moduleSubprogram: functionSubprogram | subroutineSubprogram | separateModuleSubprogram;

// R1407 module-subprogram-part -> contains-stmt [module-subprogram]...
moduleSubprogramPart: containsStmt moduleSubprogram*;

// R1406 end-module-stmt -> END [MODULE [module-name]]
endModuleStmt: END (MODULE moduleName?)?;

// R1404 module ->
//         module-stmt [specification-part] [module-subprogram-part]
//         end-module-stmt
module:
    moduleStmt specificationPart? moduleSubprogramPart? endModuleStmt;

ancestorModuleName: name;

parentSubmoduleName: name;

// R1418 parent-identifier -> ancestor-module-name [: parent-submodule-name]
parentIdentifier: ancestorModuleName (COLON parentSubmoduleName)?;

submoduleName: name;

// R1417 submodule-stmt -> SUBMODULE ( parent-identifier ) submodule-name
submoduleStmt: SUBMODULE LPAREN parentIdentifier RPAREN submoduleName;

// R1419 end-submodule-stmt -> END [SUBMODULE [submodule-name]]
endSubmoduleStmt: END (SUBMODULE submoduleName?)?;  

// R1416 submodule ->
//         submodule-stmt [specification-part] [module-subprogram-part]
//         end-submodule-stmt
submodule:
    submoduleStmt specificationPart? moduleSubprogramPart? endSubmoduleStmt;

blockDataName: name;

// R1421 block-data-stmt -> BLOCK DATA [block-data-name]
blockDataStmt: BLOCK DATA blockDataName?;

// R1422 end-block-data-stmt -> END [BLOCK DATA [block-data-name]]
endBlockDataStmt: END (BLOCK DATA blockDataName?)?;

// R1420 block-data -> block-data-stmt [specification-part] end-block-data-stmt
blockData: blockDataStmt specificationPart? endBlockDataStmt;

//R502 program-unit -> main-program | external-subprogram | module | submodule | block-data
programUnit:
    mainProgram
	| externalSubprogram
	| module
	| submodule
	| blockData;

//R501 program -> program-unit [program-unit]...    
program: programUnit (programUnit)*;

file_: program EOF;
