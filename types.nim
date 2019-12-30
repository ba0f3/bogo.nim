from unicode import Rune

type
  Accent* = enum
    NONE, DOT, TIDLE, HOOK, ACUTE, GRAVE

  Mark* = enum
    NO_MARK, BAR, BREVE, HORN, HAT

  ActionKind* = enum
    ADD_CHAR, ADD_ACCENT, ADD_MARK, UNDO

  Action* = object
    case kind*: ActionKind
    of ADD_MARK:
      mark*: Mark
    of ADD_ACCENT:
      accent*: Accent
    else:
      key*: Rune

  StringPair* = tuple[first, second: string]

  Components* = object
    firstConsonant*: string
    vowel*: string
    lastConsonant*: string

proc debug*(c: Components): string =
  return "[\"" & c.firstConsonant & "\", \"" & c.vowel & "\", \"" & c.lastConsonant & "\"]"

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