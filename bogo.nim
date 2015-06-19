import unicode
import strtabs
import utils
import accent
import mark
import types
import validation

proc getTelexDifinition*(wShorthand = true, bracketsShorthand = true): InputMethod =
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

proc getVniDefinition*(): InputMethod =
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
  for k in im.keys:
    if c in k:
      return true
  if c in VOWELS:
    return true
  if c == u"đ":
    return true
  return false


