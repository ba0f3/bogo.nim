import unicode
import utils


type
  Accent* = enum
    NONE
    DOT
    TIDLE
    HOOK
    ACUTE
    GRAVE
  
proc getAccentChar*(c: Rune): Accent {.noSideEffect.} =
  ## Get the accent of an single char, if any.
  var index = VOWELS.indexOf(c)
  if index >= 0:
    result = Accent(5 - index mod 6)
  else:
    result = NONE

proc getAccentString*(s: string): Accent =
  ## Get the first accent from the right of a string.
  for c in s.runes:
    var accent = c.getAccentChar()
    if accent != NONE:
      return accent
  return NONE
