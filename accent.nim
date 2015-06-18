import unicode
import utils


const
  GRAVE = 5
  ACUTE = 4
  HOOK = 3
  TIDLE = 2
  DOT = 1
  NONE = 0

proc getAccentChar*(c: Rune): int {.noSideEffect.} =
  ## Get the accent of an single char, if any.
  var index = VOWELS.indexOf(c)
  if index >= 0:
    result = 5 - index mod 6
  else:
    result = NONE

proc getAccentString*(s: string): string =
  ## Get the first accent from the right of a string.
  for c in s.runes:
    accent = c.getAccentChar()
    if accent != NONE:
      return accent
  return NONE
