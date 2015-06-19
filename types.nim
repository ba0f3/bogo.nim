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

  Action* = enum
    ADD_CHAR
    ADD_ACCENT
    ADD_MARK
    UNDO

  Components* = ref object of RootObj
    firstConsonant*: string
    vowel*: string
    lastConsonant*: string


proc newComponents*(f: string = "", v: string = "", la: string = ""): Components =
  new(result)
  result.firstConsonant = f
  result.vowel = v
  result.lastConsonant = la

proc `$`*(c: Components): string =
  return "[" & c.firstConsonant & ", " & c.vowel & ", " & c.lastConsonant & "]"  
