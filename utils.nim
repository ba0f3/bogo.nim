import unicode
import strutils
import strtabs
import types

const  
  VOWELS* = r"àáảãạaằắẳẵặăầấẩẫậâèéẻẽẹeềếểễệêìíỉĩịiòóỏõọoồốổỗộôờớởỡợơùúủũụuừứửữựưỳýỷỹỵy"

when not defined(release):
  import logging
  addHandler(newConsoleLogger())
  
proc ulen*(s: string): int {.noSideEffect, inline.} =
  return s.runeLen

proc `{}`*(s: string, x: int): Rune {.noSideEffect, inline.} =
  ## slice operation for strings.

  var x = x
  if x > s.ulen-1:
    return Rune(0)

  if x < 0:
    x = s.ulen + x;
    
  var i = 0
  for c in s.runes:
    if i == x:
      return c
    i.inc

proc `..-`*(a, b: int): Slice[int] {.noSideEffect, inline.} =
  result.a = a
  result.b = -b
    
proc `{}`*(s: string, x: Slice[int]): string {.noSideEffect, inline.} =
  ## slice operation for unicode strings. 
  result = ""

  var b = x.b
  if b < 0:
    b = s.ulen + b
  
  var i = 0
  for c in s.runes:
    if i >= x.a and i < b:
      result.add($c)
    i.inc

proc u*(s: string): Rune {.compileTime, noSideEffect.} =
  ## Constructor of a literal Rune from single char raw string.
  ## u"ô" == u(r"ô")
  s{0}

proc i*(s: string): int {.compileTime, noSideEffect.} =
  ## Constructor of a literal Rune from single char raw string.
  ## u"ô" == u(r"ô")
  int(s{0})

  
proc indexOf*(s: string, c: Rune): int {.noSideEffect.} =
  var c = c.toLower  
  var i = 0
  for r in s.runes:
    if r == c:
      return i
    i.inc
  return -1

proc rfind*(s: string, c: Rune): int {.noSideEffect.} =
  result = -1
  var i = 0
  for r in s.runes:
    if r == c:
      result = i 
  
proc contains*(s: string, c: Rune): bool {.noSideEffect.} =
  for r in s.runes:
    if r == c:
      return true
  return false

   
proc last*(s: string): Rune {.noSideEffect, inline, procVar.} =
  s{-1}

proc isVowel*(c: Rune): bool {.noSideEffect, inline, procVar.} =
  VOWELS.indexOf(c) != -1

proc toLower*(c: Rune): Rune {.noSideEffect, procvar.} =
  return unicode.toLower(c)

proc toUpper*(c: Rune): Rune {.noSideEffect, procvar.} =
  return unicode.toUpper(c)

proc toLower*(s: string): string {.noSideEffect, procvar.} =
  result = newString(s.len)
  var i = 0
  for r in s.runes:
    var c = r.toLower.toUTF8
    for j in 0..c.len-1:
      result[i+j] = c[j]
    i += c.len

proc toUpper*(s: string): string {.noSideEffect, procvar.} =
  result = newString(s.len)
  var i = 0
  for r in s.runes:
    var c = r.toUpper.toUTF8
    for j in 0..c.len-1:
      result[i+j] = c[j]
    i += c.len


proc appendComps*(comps: var Components, c: Rune) =
  ## Append a character to `comps` following this rule: a vowel is added to the
  ## vowel part if there is no last consonant, else to the last consonant part;
  ## a consonant is added to the first consonant part if there is no vowel, and
  ## to the last consonant part if the vowel part is not empty.
  ##
  ## >>> transform(['', '', ''])
  ## ['c', '', '']
  ## >>> transform(['c', '', ''], '+o')
  ## ['c', 'o', '']
  ## >>> transform(['c', 'o', ''], '+n')
  ## ['c', 'o', 'n']
  ## >>> transform(['c', 'o', 'n'], '+o')
  ## ['c', 'o', 'no']
  if c.isVowel:
    if not comps.hasLast:
      # pos = 1
      comps.vowel.add($c)
    else:
      # pos = 2
      comps.lastConsonant.add($c)
  else:
    if not comps.hasLast and not comps.hasVowel:
      # pos = 0
      comps.firstConsonant.add($c)
    else:
      # pos = 2
      comps.lastConsonant.add($c)
      
proc separate*(s: string): Components =
  ## Separate a string into smaller parts: first consonant (or head), vowel,
  ## last consonant (if any).
  ##
  ## >>> separate('tuong')
  ## ['t','uo','ng']
  ## >>> separate('ohmyfkinggod')
  ## ['ohmyfkingg','o','d']
  
  proc atomicSeparate(s, lastChars: string, lastIsVowel: bool): StringPair =
    if s == "" or (lastIsVowel != s.last.isVowel):
      return [s, lastChars]
    else:
      return atomicSeparate(s{0..-1}, s.last.toUTF8 & lastChars, lastIsVowel)

  new(result)
  var pair = atomicSeparate(s, "", false)
  result.lastConsonant = pair.second()
  pair = atomicSeparate(pair.first(), "", true)
  result.firstConsonant = pair.first()
  result.vowel = pair.second()
  
  if result.hasLast and not result.hasVowel and not result.hasFirst:
    result.firstConsonant = result.lastConsonant  # ['', '', b] -> ['b', '', '']
    result.lastConsonant = ""
  # 'gi' and 'qu' are considered qualified consonants.
  # We want something like this:
  #     ['g', 'ia', ''] -> ['gi', 'a', '']
  #     ['q', 'ua', ''] -> ['qu', 'a', '']
  if (result.hasFirst and result.hasVowel) and
     ((result.firstConsonant[0] in "gG" and result.vowel[0] in "iI" and result.vowel.ulen > 1) or
     (result.firstConsonant[0] in "qQ" and result.vowel[0] in "uU")):
    result.firstConsonant.add($result.vowel{0})
    result.vowel = result.vowel{1..result.vowel.ulen}

