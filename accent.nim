import unicode except toLower, toUpper
import utils
import types

## Utility functions to deal with accents (should have been called tones),
## which are diacritical markings that changes the pitch of a character.
## E.g. the acute accent in á.

proc getAccentChar*(c: Rune): Accent {.noSideEffect.} =
  ## Get the accent of an single char, if any.
  let index = VOWELS.indexOf(c)
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

proc addAccentChar*(c: Rune, accent: Accent): Rune =
  ## Add accent to a single char.
  if c.int == 0 or c.isVowel == false:
    return c

  let isUpper = c.isUpper
  var ch = unicode.toLower(c)
  var index = VOWELS.indexOf(ch)
  if index >= 0:
    index = index - index mod 6 + 5
    ch = VOWELS{index - ord(accent)}
  if isUpper:
    result = ch.toUpper
  else:
    result = ch

proc removeAccentChar*(c: Rune): Rune =
  ## Remove accent from a single char, if any.
  return c.addAccentChar(NONE)

proc removeAccentString*(s: string): string =
  ## Remove all accent from a whole string.
  result = ""
  for r in s.runes:
    result.add($r.removeAccentChar)

proc addAccent*(comps: var Components, accent: Accent) =
  ## Add accent to the given components.
  debug "addAccent", comps.debug, accent
  var vowel = comps.vowel
  if accent == NONE:
    comps.vowel = vowel.removeAccentString
  elif vowel == "":
    discard
  else:
    var rawString = vowel.removeAccentString.toLower
    
    var index = max(rawString.indexOf(u"ê"), rawString.indexOf(u"ơ"))
    var newVowel = ""
    if index != -1:
      newVowel = $vowel{0..index} & $vowel{index}.addAccentChar(accent) & vowel{index+1..vowel.ulen}
    elif vowel.ulen == 1 or (vowel.ulen == 2 and not comps.hasLast):
      newVowel = $vowel{0}.addAccentChar(accent) & vowel{1..vowel.ulen}
    else:
      newVowel = $vowel{0} & $vowel{1}.addAccentChar(accent) & vowel{2..vowel.ulen}
    comps.vowel = newVowel

  debug "addAccent", comps.debug
