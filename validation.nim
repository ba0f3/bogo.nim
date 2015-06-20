import sequtils
import utils
import accent
import mark
import types

## Utility functions to check whether a word looks like Vietnamese
## or not (i.e. can be pronounced by a Vietnamese speaker).

const
  CONSONANTS = @["b", "c", "ch", "d", "g", "gh", "gi", "h", "k", "kh", "l", "m",
                 "n", "ng", "ngh", "nh", "p", "ph", "qu", "r", "s", "t", "th", "tr", "v", "x", "đ"]
  TERMINAL_CONSONANTS = @["c", "ch", "m", "n", "ng", "nh", "p", "t"]
  VOWELS = @["a", "ai", "ao", "au", "ay", "e", "eo", "i", "ia", "iu", "iê", "iêu",
             "o", "oa", "oai", "oao", "oay", "oe", "oeo", "oi", "oo", "oă", "u", "ua",
             "ui", "uy", "uya", "uyu", "uyê", "uâ", "uây", "uê", "uô", "uôi",
             "uơ", "y", "yê", "yêu", "â", "âu", "ây", "ê", "êu", "ô", "ôi",
             "ă", "ơ", "ơi", "ư", "ưa", "ưi", "ưu", "ươ", "ươi", "ươu"]
  STRIPPED_VOWELS = @["a", "ai", "ao", "au", "ay", "e", "eo", "i", "ia", "iu", "ie", "ieu",
                      "o", "oa", "oai", "oao", "oay", "oe", "oeo", "oi", "oo", "oa", "u", "ua",
                      "ui", "uy", "uya", "uyu", "uye", "ua", "uay", "ue", "uo", "uoi",
                      "uo", "y", "ye", "yeu", "a", "au", "ay", "e", "eu", "o", "oi",
                      "a", "o", "oi", "u", "ua", "ui", "uu", "uo", "uoi", "uou"]
  TERMINAL_VOWELS = @["ai", "ao", "au", "ay", "eo", "ia", "iu", "iêu", "oai", "oao", "oay",
                     "oeo", "oi", "ua", "ui", "uya", "uyu", "uây", "uôi", "uơ", "yêu", "âu",
                      "ây", "êu", "ôi", "ơi", "ưa", "ưi", "ưu", "ươi", "ươu"]
  
  STRIPPED_TERMINAL_VOWELS = @["ai", "ao", "au", "ay", "eo", "ia", "iu", "ieu", "oai", "oao", "oay",
                               "oeo", "oi", "ua", "ui", "uya", "uyu", "uay", "uoi", "yeu", "au",
                               "ay", "eu", "oi", "oi", "ui", "uu", "uoi", "uou"]

proc hasValidConsonants(c: Components): bool =
  return not ((c.hasFirst and not CONSONANTS.contains(c.firstConsonant)) or
    (c.hasLast and not TERMINAL_CONSONANTS.contains(c.lastConsonant)))

proc hasValidVowelNonFinal(c: Components): bool =
  ## If the sound_tuple is not complete, we only care whether its vowel
  ## position can be transformed into a legit vowel.
  var stripped = c.vowel.strip
  if c.hasLast:
    return stripped in filter(STRIPPED_VOWELS) do (x: string) -> bool: not STRIPPED_TERMINAL_VOWELS.contains(x)
  else:
    return stripped in STRIPPED_VOWELS

proc hasValidVowel(c: Components): bool =
  var vowelNoAccent = c.vowel.removeAccentString

  proc hasValidVowelForm(): bool =
    return vowelNoAccent in VOWELS and
      not (c.hasLast and vowelNoAccent in TERMINAL_VOWELS)

  proc hasValidChEnding(): bool =
    # 'ch' can only go after a, ê, uê, i, uy, oa
    return not (c.lastConsonant == "ch" and not (vowelNoAccent in @["a", "ê", "uê", "i", "uy", "oa"]))

  #proc hasValidCEnding(): bool =
  #  # 'c' can't go after 'i' or 'ơ'
  #  return not (c.lastConsonant == "c" and (vowelNoAccent in @["i", "ơ"]))

  #proc hasValidNgEnding(): bool =
  #  # 'ng' can't go after 'i' or 'ơ'
  #  return not (c.lastConsonant == "ng" and (vowelNoAccent in @["i", "ơ"]))

  #proc hasValidNhEnding(): bool =
  #  # 'nh' can only go after a, ê, uy, i, oa, quy
  #  var hasYButIsNotQuynh = vowelNoAccent == "y" and c.firstConsonant != "qu"
  #  var hasInvalidVowel = not (vowelNoAccent in @["a", "ê", "i", "uy", "oa", "uê", "y"])
  #  return not (c.lastConsonant == "nh" and (hasInvalidVowel or hasYButIsNotQuynh))

  # The ng and nh rules are not really phonetic but spelling rules.
  # Including them may hinder typing freedom and may prevent typing
  # unique local names.
  # FIXME: Config key, anyone?
  return hasValidVowelForm() and hasValidChEnding() and hasValidChEnding()
  # has_valid_ng_ending() and \
  # has_valid_nh_ending()

proc hasValidAccent(c: Components): bool =
  var akzent = c.vowel.getAccentString  

  # These consonants can only go with ACUTE, DOT accents
  return not ((c.lastConsonant in @["c", "p", "t", "ch"]) and
              not (akzent in @[ACUTE, DOT]))
    
proc isValidSoundTuple(c: Components, finalForm = true): bool =
  ## Check if a character combination complies to Vietnamese phonology.
  ## The basic idea is that if one can pronunce a sound_tuple then it's valid.
  ## Sound tuples containing consonants exclusively (almost always
  ## abbreviations) are also valid.
  ##
  ## Input:
  ##    sound_tuple - a SoundTuple
  ##    final_form  - whether the tuple represents a complete word
  ## Output:
  ##    True if the tuple seems to be Vietnamese, False otherwise.
  c.firstConsonant = c.firstConsonant.toLower
  c.vowel = c.vowel.toLower
  c.lastConsonant = c.lastConsonant.toLower

  #XXX Words with no vowel are always valid ??
  if not c.hasVowel:
    return true
  elif finalForm:
    return c.hasValidConsonants and c.hasValidVowel and c.hasValidAccent
  else:
    return c.hasValidConsonants and c.hasValidVowelNonFinal

proc isValidCombination*(c: Components, finalForm = true): bool =
  return c.isValidSoundTuple(finalForm)
    
proc isValidString*(s: string, finalForm = true): bool =
  return s.separate.isValidCombination(finalForm)
