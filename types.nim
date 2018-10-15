from unicode import Rune
import utils

type
  Accent* = enum
    NONE
    DOT
    TIDLE
    HOOK
    ACUTE
    GRAVE

  Mark* = enum
    NO_MARK
    BAR
    BREVE
    HORN
    HAT

  ActionKind* = enum
    ADD_CHAR
    ADD_ACCENT
    ADD_MARK
    UNDO

  Action* = ref ActionObj
  ActionObj = object
    case kind*: ActionKind
    of ADD_MARK:
      mark*: Mark
    of ADD_ACCENT:
      accent*: Accent
    else:
      key*: Rune

  StringPair* = array[0..1, string]

  Components* = ref object of RootObj
    firstConsonant*: string
    vowel*: string
    lastConsonant*: string

proc newComponents*(f: string = "", v: string = "", la: string = ""): Components {.noSideEffect, inline.} =
  new(result)
  result.firstConsonant = f
  result.vowel = v
  result.lastConsonant = la

proc `==`*(x,y: Components): bool {.noSideEffect, inline.} =
  return x.firstConsonant == y.firstConsonant and x.vowel == y.vowel and x.lastConsonant == y.lastConsonant

proc debug*(c: Components): string =
  return "[\"" & c.firstConsonant & "\", \"" & c.vowel & "\", \"" & c.lastConsonant & "\"]"

proc copy*(c: Components): Components {.noSideEffect, inline.} =
  newComponents(c.firstConsonant, c.vowel, c.lastConsonant)

proc hasFirst*(c: Components): bool =
  return c.firstConsonant.len != 0

proc hasVowel*(c: Components): bool {.noSideEffect, inline.} =
  return c.vowel.len != 0

proc hasLast*(c: Components): bool {.noSideEffect, inline.} =
  return c.lastConsonant.len != 0

proc `$`*(c: Components): string {.noSideEffect, inline.} =
  result = ""
  if c.hasFirst:
    result.add(c.firstConsonant)
  if c.hasVowel:
    result.add(c.vowel)
  if c.hasLast:
    result.add(c.lastConsonant)

proc first*(p: StringPair): string {.noSideEffect, inline, procVar.} =
  p[0]

proc second*(p: StringPair): string {.noSideEffect, inline, procVar.} =
  p[1]
  
proc `$`*(p: StringPair): string =
  return "[\"" & p[0] & "\", \"" & p[1] & "\"]"    
 
proc newAction*(k: ActionKind, mark: Mark = NO_MARK, accent = NONE, key = Rune(0)): Action {.noSideEffect, inline.} =
  new(result)
  result.kind = k
  case k
  of ADD_ACCENT:
    result.accent = accent
  of ADD_MARK:
    result.mark = mark
  else:
    result.key = key

    
