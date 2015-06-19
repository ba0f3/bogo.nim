import unicode
import strtabs
import utils
import accent
import mark
import types
import validation

proc getTelexDifinition*(wShorthand = true, bracketsShorthand = true): InputMethod {.procVar.} =
  ## Create a definition dictionary for the TELEX input method
  ##
  ## Args:
  ##    w_shorthand (optional): allow a stand-alone w to be
  ##        interpreted as an ư. Default to True.
  ##    brackets_shorthand (optional, True): allow typing ][ as
  ##        shorthand for ươ. Default to True.
  ##
  ## Returns a dictionary to be passed into process_key().

  result = newStringTable(modeCaseInsensitive)
  result["a"] = "a^"
  result["o"] = "o^"
  result["e"] = "e^"
  result["w"] = "u* o* a+"
  result["d"] =  "d-"
  result["f"] =  "\\"
  result["s"] =  "/"
  result["r"] =  "?"
  result["x"] =  "~"
  result["j"] =  "."

  if wShorthand:
    result["w"] = result["w"] & " <ư"

  if bracketsShorthand:
    result["]"] = "<ư"
    result["["] = "<ơ"
    result["}"] = "<Ư"
    result["{"] = "<Ơ"

proc getVniDefinition*(): InputMethod {.procVar.} =
  result = newStringTable(modeCaseInsensitive)
  result["6"] = "a^ o^ e^"
  result["7"] = "u* o*"
  result["8"] = "a+"
  result["9"] =  "d-"
  result["2"] = "\\"
  result["1"] = "/"
  result["3"] = "?"
  result["4"] = "~"
  result["5"] = "."


proc isAcceptedChar(c: Rune, im: InputMethod): bool =
  if c in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ":  
    return true
  if im.hasKey(c):
    return true
  if c in VOWELS:
    return true
  if c == u"đ":
    return true
  return false

proc getTransformationList(key: Rune, im: InputMethod, fallbackSeq): seq[string] =
  ## Return the list of transformations inferred from the entered key. The
  ## map between transform types and keys is given by module
  ## bogo_config (if exists) or by variable simple_telex_im
  ##
  ## if entered key is not in im, return "+key", meaning appending
  ## the entered key to current text
  result = @[]
  var k = key.toLower
  if im.hasKey(k):
    if '\x32' in im[$k):
      result = im[$k].split
    else:
      result.add(im[$k])

    for i in 0..result.len-1:
      var trans = result[i]  
      if trans[0] == '<' and key.isAlpha:
        if key.isUpper:
          result[i] = $trans[0] & key.toUpper
        else:
          result[i] = $trans[0] & key
    if result.len == 1 and result[0] == "_":
      if fallbackSeq.len >= 2:
        var t = 
proc processKey(str: string, key: Rune, im: InputMethod, fallbackSeq = "", skipNonVNese = true): array[0..1, string] =
  ## Process a keystroke.
  proc defaultReturn(): array[0..1, string] =
    return [str & $key, fallbackSeq & $key]

  var comps = str.separate
  var transList = getTransformationList(key, im, fallbackSeq)  
  
proc processSequence*(sequence: string, im: InputMethod, skipNonVNese = true): string =
  ## Convert a key sequence into a Vietnamese string with diacritical marks.
  result = ""
  var raw = ""
  var resultParts: seq[string] = @[]
  for key in sequence.runes:
    if not key.isAcceptedChar(im):
      resultParts.add(result)
      resultParts.add($key)
      result = ""
      raw = ""
    else:
      var tmp = processKey(result, key, raw, im, skipNonVNese)
      result = tmp[0]
      raw = tmp[1]
  resultParts.add(result)
  result = ""    
  for s in resultParts:
    result &= s
  
proc handleBackspace(convertedStr, rawSeq = string, im: InputMethod): string =
  ## Returns a new raw_sequence after a backspace. This raw_sequence should
  ## be pushed back to processSequence().  
  let deletedChar = convertedStr.last

  let accent = deletedChar.getAccentChar
  let mark = deletedChar.getMarkChar

  if mark != NO_MARK or accent != NONE:
    var imeKeysAtEnd = ""
    let rawSeqLen = rawSeq.ulen
    var i = rawSeqLen - 1
    while i >= 0:
      if not im.hasKey(rawSeq{i}) and not (rawSeq{i} in "aeiouyd"):
        i.inc
        break
      else:
        imeKeysAtEnd = $rawSeq{i} & imeKeysAtEnd
        i.dec
    var k = 0
    while k < rawSeqLen:
      if processSequence(rawSeq{i+k}, im) == deletedChar:
        return rawSeq{0..i+k}
      k.inc
  else:
    let index = rawSeq.rfind(deletedChar)
    return rawSeq{0..index} & rawSeq{index+1..rawSeq.runeLen-1}
