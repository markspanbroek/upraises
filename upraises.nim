import std/macros

when (NimMajor, NimMinor) < (1, 4):

  macro upraises*(types: untyped{nkBracket}, def: untyped): untyped =
    ## Use instead of a {.raises.} pragma to work around differences between
    ## Nim 1.4 and 1.2:
    ##
    ## ```
    ## proc example {.upraises: [].}
    ## ```
    types.add(ident("Defect"))
    def.addPragma(newColonExpr(ident("raises"), types))

    const defKinds = [
      nnkProcDef,
      nnkFuncDef,
      nnkMethodDef,
      nnkIteratorDef,
      nnkConverterDef
    ]

    if def.kind in defKinds:
      quote do:
        {.hint[XDeclaredButNotUsed]: off.}
        `def`
        {.hint[XDeclaredButNotUsed]: on.}
    else:
      `def`

  macro push*(statements: untyped{nkStmtList}) =
    ## Use instead of a {.push.} pragma for {.upraises.} declarations:
    ##
    ## ```
    ## push: {.upraises: [].}
    ## ```
    statements.expectLen(1)
    statements[0].expectKind(nnkPragma)
    let pragma = statements[0]
    for (index, child) in pragma.pairs:
      if child.kind == nnkExprColonExpr and child[0].eqIdent("upraises"):
        child[0] = ident("raises")
        child[1].add(ident("Defect"))
      pragma[index] = child
    pragma.insert(0, ident("push"))
    quote do:
      {.hint[XDeclaredButNotUsed]: off.}
      `pragma`

else:

  macro upraises*(types: untyped{nkBracket}, def: untyped): untyped =
    ## Use instead of a {.raises.} pragma to work around differences between
    ## Nim 1.4 and 1.2:
    ##
    ## ```
    ## proc example {.upraises: [].}
    ## ```
    def.addPragma(newColonExpr(ident("raises"), types))
    def

  macro push*(statements: untyped{nkStmtList}) =
    ## Use instead of a {.push.} pragma for {.upraises.} declarations:
    ##
    ## ```
    ## push: {.upraises: [].}
    ## ```
    statements.expectLen(1)
    statements[0].expectKind(nnkPragma)
    let pragma = statements[0]
    for (index, child) in pragma.pairs:
      if child.kind == nnkExprColonExpr and child[0].eqIdent("upraises"):
        child[0] = ident("raises")
      pragma[index] = child
    pragma.insert(0, ident("push"))
    pragma
