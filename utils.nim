import unicode
import strutils

const  
  VOWELS* = "àáảãạaằắẳẵặăầấẩẫậâèéẻẽẹeềếểễệêìíỉĩịiòóỏõọoồốổỗộôờớởỡợơùúủũụuừứửữựưỳýỷỹỵy"

proc indexOf*(s: string, c: Rune): int {.noSideEffect.} =
  var i = 0  
  for r in s.runes:
    if r == c:
      return i
    i += 1
  return -1

proc runeAt*(s: string, i: int): Rune =
  var j = 0
  for r in s.runes:
    if j == i:
      return r
    j += 1    
  
proc isVowel*(c: Rune): bool {.noSideEffect.} =
  VOWELS.indexOf(c) != -1
  
proc appendComps(comps: var array[0..2, string], c: Rune) =
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
  
  var pos: int  
  if c.isVowel:
    if comps[2] == "":
      pos = 1
    else:
      pos = 2
  else:
    if comps[2] == "" and comps[1] == "":
      pos = 0
    else:
      pos = 2
  comps[pos] = $c

proc separate*(s: string): array[0..2, string] =
  ## Separate a string into smaller parts: first consonant (or head), vowel,
  ## last consonant (if any).
  ##
  ## >>> separate('tuong')
  ## ['t','uo','ng']
  ## >>> 
  ## ['ohmyfkingg','o','d']
  
  proc atomicSeparate(s, lastChars: string, lastIsVowel: bool): array[0..1, string] =
    echo "lastChars ", lastChars

    if s.len == 0 or (lastIsVowel != s.runeAt(s.runeLen-1).isVowel):
      result = [s, lastChars]
    else:
      result = atomicSeparate(s[0..s.runeLen-2], s[s.runeLen-1] & lastChars, lastIsVowel)
    echo result[1]

  var firstConsonant, lastConsonant, vowel: string
  var tmp = atomicSeparate(s, "", false)
  lastConsonant = tmp[1]
  tmp = atomicSeparate(tmp[0], "", true)
  firstConsonant = tmp[0]
  vowel = tmp[1]

  if lastConsonant != "" and vowel == "" and firstConsonant == "":
    result = [lastConsonant, "", ""] # ['', '', b] -> ['b', '', '']
  else:
    result = [firstConsonant, vowel, lastConsonant]

  # 'gi' and 'qu' are considered qualified consonants.
  # We want something like this:
  #     ['g', 'ia', ''] -> ['gi', 'a', '']
  #     ['q', 'ua', ''] -> ['qu', 'a', '']
  if (result[0] != "" and result[1] != "") and
     ((result[0][0] in "gG" and result[1][0] in "iI" and result[1].runeLen > 1) or
     (result[0][0] in "qQ" and result[1][0] in "uU")):
    result[0] &= $result[1][0]
    result[1].delete(0, 0)


    
