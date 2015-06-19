import unicode
import strutils
import types

const  
  VOWELS* = "àáảãạaằắẳẵặăầấẩẫậâèéẻẽẹeềếểễệêìíỉĩịiòóỏõọoồốổỗộôờớởỡợơùúủũụuừứửữựưỳýỷỹỵy"

proc indexOf*(s: string, c: Rune): int {.noSideEffect.} =
  var c = c.toLower  
  var i = 0  
  for r in s.runes:
    if r == c:
      return i
    i += 1
  return -1

proc contains*(s: string, c: Rune): bool {.noSideEffect.} =
  for r in s.runes:
    if r == c:
      return true
  return false

proc runeAt*(s: string, i: int): Rune {.inline.} =
  var j = 0
  for r in s.runes:
    if j == i:
      return r
    j += 1    

#proc `[]`*(s: string, i: int): Rune =
#  discard    
    
proc lastRune*(s: string): Rune {.noSideEffect.} =
  for r in s.runes:
    result = r

proc isVowel*(c: Rune): bool {.noSideEffect, inline.} =
  VOWELS.indexOf(c) != -1

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
    if comps.lastConsonant == "":
      # pos = 1
      comps.vowel = $c
    else:
      # pos = 2
      comps.lastConsonant = $c
  else:
    if comps.lastConsonant == "" and comps.vowel == "":
      # pos = 0
      comps.firstConsonant = $c
    else:
      # pos = 2
      comps.lastConsonant = $c

proc separate*(s: string): Components =
  ## Separate a string into smaller parts: first consonant (or head), vowel,
  ## last consonant (if any).
  ##
  ## >>> separate('tuong')
  ## ['t','uo','ng']
  ## >>> 
  ## ['ohmyfkingg','o','d']
  
  proc atomicSeparate(s, lastChars: string, lastIsVowel: bool): array[0..1, string] =
    if s.len == 0 or (lastIsVowel != s.runeAt(s.runeLen-1).isVowel):
      result = [s, lastChars]
    else:
      result = atomicSeparate(s[0..s.runeLen-2], s[s.runeLen-1] & lastChars, lastIsVowel)
    echo result[1]

  new(result)
  var tmp = atomicSeparate(s, "", false)
  result.lastConsonant = tmp[1]
  tmp = atomicSeparate(tmp[0], "", true)
  result.firstConsonant = tmp[0]
  result.vowel = tmp[1]

  if result.lastConsonant != "" and result.vowel == "" and result.firstConsonant == "":
    result = newComponents(result.lastConsonant)  # ['', '', b] -> ['b', '', '']

  # 'gi' and 'qu' are considered qualified consonants.
  # We want something like this:
  #     ['g', 'ia', ''] -> ['gi', 'a', '']
  #     ['q', 'ua', ''] -> ['qu', 'a', '']
  if (result.firstConsonant != "" and result.vowel != "") and
     ((result.firstConsonant[0] in "gG" and result.vowel[0] in "iI" and result.vowel.runeLen > 1) or
     (result.firstConsonant[0] in "qQ" and result.vowel[0] in "uU")):
    result.firstConsonant &= $result.vowel[0]
    result.vowel.delete(0, 0)
    
