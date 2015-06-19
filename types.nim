type
  Accent* = enum
    NONE
    DOT
    TIDLE
    HOOK
    ACUTE
    GRAVE
    
  Components* = ref object of RootObj
    firstConsonant*: string
    vowel*: string
    lastConsonant*: string

proc newComponents*(f: string = "", v: string = "", l: string = ""): Components =
  new(result)
  result.firstConsonant = f
  result.vowel = v
  result.lastConsonant = l
