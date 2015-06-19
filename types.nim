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

