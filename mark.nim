

## Utility functions to deal with marks, which are diacritical markings
## to change the base sound of a character but not its tonal quality.
## E.g. the hat mark in â.

import unicode except toLower, toUpper
import accent
import utils
import types

const
  FAMILY_A = "aăâ"
  FAMILY_E = "eê"
  FAMILY_O = "oơô"
  FAMILY_U = "uư"
  FAMILY_D = "dđ"

proc getMarkChar*(c: Rune): Mark =
  ## Get the mark of a single char, if any.
  if c.int == 0:
    return NO_MARK
  var c = c.removeAccentChar
  if u"đ" == c:
    return BAR
  if u"ă" == c:
    return BREVE
  if c in "ơư":
    return HORN
  if c in "âêô":
    return HAT
  return NO_MARK

proc addMarkChar*(c: Rune, m: Mark): Rune =
  ## Add mark to a single char.  
  var isUpper = c.isUpper
  var accent = c.getAccentChar
  var ch = unicode.toLower(c).addAccentChar(NONE)
  var newCh = ch
  if m == HAT:
    if ch in FAMILY_A:
      newCh = u"â"
    elif ch in FAMILY_O:
      newCh = u"ô"
    elif ch in FAMILY_E:
      newCH = u"ê"
  elif m == HORN:
    if ch in FAMILY_O:
      newCh = u"ơ"
    elif ch in FAMILY_U:
      newCh = u"ư"
  elif m == BREVE:
    if ch in FAMILY_A:
      newCh = u"ă"
  elif m == BAR:
    if ch in FAMILY_D:
      newCh = u"đ"
  elif m == NO_MARK:
    if ch in FAMILY_A:
      newCh = u"a"
    elif ch in FAMILY_E:
      newCh = u"e"
    elif ch in FAMILY_O:
      newCh = u"o"
    elif ch in FAMILY_U:
      newCh = u"u"
    elif ch in FAMILY_D:
      newCh = u"d"
  newCh = newCh.addAccentChar(accent)
  if isUpper:
    result = newCh.toUpper
  else:
    result = newCh
  
proc addMarkAt*(s: string, index: int, mark: Mark): string =
  ## Add mark to the index-th character of the given string. Return the new string after applying change.
  if index == -1:
    return s
  result = ""
  var i = 0  
  for c in s.runes:
    if i == index:
      result &= $c.addMarkChar(mark)
    else:
      result &= $c
  
  
proc addMark*(comps: var Components, mark: Mark) =
  echo comps.debug, " ", mark
  var rawVowel: string      
  if mark == BAR and comps.hasFirst and comps.firstConsonant.last in FAMILY_D:
    var f = comps.firstConsonant
    comps.firstConsonant = f.addMarkAt(f.ulen-1, BAR)
  else:
    # remove all marks and accents in vowel part
    comps.addAccent(NONE)
    rawVowel = comps.vowel.removeAccentString.toLower
    var pos: int
    if mark == HAT:
      pos = max(rawVowel.find('a'), rawVowel.find('o'), rawVowel.find('e'))
      comps.vowel = comps.vowel.addMarkAt(pos, mark)
    elif mark == BREVE:
      if rawVowel != "ua":
        comps.vowel = comps.vowel.addMarkAt(rawVowel.find('a'), mark)
    elif mark == HORN:
      if rawVowel == "ou" or rawVowel == "uoi" or rawVowel == "uou":
        var i = 0
        var tmp = ""
        for c in comps.vowel.runes:
          # slice [:2]
          if i == 0 or i == 1:
            tmp &= $c.addMarkChar(mark)
          else:
            tmp &= $c
        comps.vowel = tmp
      elif rawVowel == "oa":
        comps.vowel = comps.vowel.addMarkAt(1, mark)
      else:
        pos = max(rawVowel.find('\0'), rawVowel.find('o'))
        comps.vowel = comps.vowel.addMarkAt(pos, mark)
            
  if mark == NO_MARK:     
    if rawVowel != comps.vowel.toLower:
      comps.vowel = rawVowel
    elif comps.hasFirst and comps.firstConsonant.last == u"đ":
      comps.firstConsonant = comps.firstConsonant{0..-1} & "d"
    

proc removeMarkChar*(c: Rune): Rune =
  ## Remove mark from a single character, if any.
  return c.addMarkChar(NO_MARK)

proc removeMarkString*(s: string): string =
  var i = 0
  result = newString(s.len)
  for r in s.runes:
    if r.int == 0:
      continue
    var c = r.removeMarkChar.toUTF8
    for j in 0..c.len-1:
      var x = c[j]
      result[i+j] = x
    i += c.len
  result.setLen(i)
    
proc strip*(s: string): string =
  ## Strip a string of all marks and accents.
  return s.removeAccentString.removeMarkString

proc isValidMark*(comps: Components, marks: string): bool =
  ## Check whether the mark given by mark_trans is valid to add to the components
  if marks == "*_":
    return true
  if marks[0] == 'd' and comps.hasFirst and comps.firstConsonant.last in FAMILY_D:
    return true
  elif comps.hasVowel and comps.vowel.strip.toLower.find(marks[0]) != -1:
    return true
  else:
    return false
