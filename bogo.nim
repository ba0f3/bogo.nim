import unicode except toLower, toUpper
import strutils except toLower, toUpper, strip
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

proc getVniDifinition*(): InputMethod {.procVar.} =
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

proc getTransformationList(key: Rune, im: InputMethod, fallbackSeq: string): seq[string] =
  ## Return the list of transformations inferred from the entered key. The
  ## map between transform types and keys is given by module
  ## bogo_config (if exists) or by variable simple_telex_im
  ##
  ## if entered key is not in im, return "+key", meaning appending
  ## the entered key to current text
  debug "getTransformationlist", key, fallbackSeq
  result = @[]
  var k = unicode.toLower(key)
  if im.hasKey(k):
    if ' ' in im[$k]:
      result = im[$k].split
    else:
      result.add(im[$k])

    for i in 0..result.len-1:
      var trans = result[i]  
      if trans[0] == '<' and key.isAlpha:
        if key.isUpper:
          result[i] = $trans{0} & $key.toUpper
        else:
          result[i] = $trans{0} & $key
    if result.len == 1 and result[0] == "_":
      if fallbackSeq.len >= 2:
        var res: seq[string] = @[]
        for t in getTransformationList(fallbackSeq{-2}, im, fallbackSeq{0..-1}):
          res.add("_" & t)
        return res
  else:
    result.add("+" & $key)
  debug "getTransformationlist", result

proc getAction(trans: string): Action =
  ## Return the action inferred from the transformation `trans`.
  ## and the parameter going with this action
  ## An ADD_MARK goes with a Mark
  ## while an ADD_ACCENT goes with an Accent
  if trans[0] == '<' or trans[0] == '+':
    return newAction(ADD_CHAR, key=trans{1})
  if trans[0] == '_':
    return newAction(UNDO, key=trans{-1})
  if trans.len == 2:
    let m = trans[1]
    var mark: Mark
    case m
    of '^':
      mark = HAT
    of '+':
      mark = BREVE
    of '*':
      mark = HORN
    of '-':
      mark = BAR
    else:
      mark = NO_MARK

    return newAction(ADD_MARK, mark=mark)
  else:
    let a = trans[0]
    var accent: Accent
    case a
    of '\\':
      accent = GRAVE
    of '/':
      accent = ACUTE
    of '?':
      accent = HOOK
    of '~':
      accent = TIDLE
    of '.':
      accent = DOT
    else:
      accent = NONE
      
    return newAction(ADD_ACCENT, accent=accent)      

proc reverse(c: var Components, trans: string) =
  ## Reverse the effect of transformation 'trans' on 'components'
  ## If the transformation does not affect the components, return the original
  ## string.
  let action = trans.getAction
  if action.kind == ADD_CHAR and last($c).toLower == action.key.toLower:
    if c.hasLast:
      c.lastConsonant = c.lastConsonant{0..-1}
    elif c.hasVowel:
      c.vowel = c.vowel{0..-1}
    else:
      c.firstConsonant = c.firstConsonant{0..-1}
  elif action.kind == ADD_ACCENT:
    c.addAccent(NONE)
  elif action.kind == ADD_MARK:
    if action.mark == BAR:
      c.firstConsonant = c.firstConsonant{0..-1} & c.firstConsonant{-1}.addMarkChar(NO_MARK).toUTF8
    else:
      if c.isValidMark(trans):
        var vowel = ""
        for c in c.vowel.runes:
          vowel &= $c.addMarkChar(NO_MARK)
        c.vowel = vowel

proc transform(c: var Components, trans: string) =
  ## Transform the given string with transform type trans
  debug "transform", c.debug, trans
  var action = trans.getAction

  if action.kind == ADD_MARK and not c.hasLast and c.vowel.strip in @["oe", "oa"] and trans == "o^":
    action = newAction(ADD_CHAR, key=trans{0})

  var vowel = ""
  var ac: Accent

  if action.kind == ADD_ACCENT:
    c.addAccent(action.accent)
  elif action.kind == ADD_MARK and c.isValidMark(trans):
    c.addMark(action.mark)

    # Handle uơ in "huơ", "thuở", "quở"
    # If the current word has no last consonant and the first consonant
    # is one of "h", "th" and the vowel is "ươ" then change the vowel into
    # "uơ", keeping case and accent. If an alphabet character is then added
    # into the word then change back to "ươ".
    #
    # NOTE: In the dictionary, these are the only words having this strange
    # vowel so we don't need to worry about other cases.
    if c.vowel.toLower.removeAccentString == "ươ" and c.hasLast and c.firstConsonant.toLower in @["", "h", "th", "kh"]:
      ac = c.vowel.getAccentString
      if c.vowel{0}.isUpper:
        vowel = "U"
      else:
        vowel = "u"
        
      c.vowel = vowel & $c.vowel{1}
      c.addAccent(ac)
  elif action.kind == ADD_CHAR:
    if trans[0] == '<':
      if not c.hasLast:
        # Only allow ư, ơ or ươ sitting alone in the middle part
        # and ['g', 'i', '']. If we want to type giowf = 'giờ', separate()
        # will create ['g', 'i', '']. Therefore we have to allow
        # components[1] == 'i'.
        if c.firstConsonant.toLower == "g" and c.vowel.toLower == "i":
          c.firstConsonant &= c.vowel
          c.vowel = ""
        if not c.hasVowel or (c.vowel.toLower == "ư" and trans{1}.toLower == u"ơ"):
          c.vowel &= $trans{1}
    else:
      c.appendComps(action.key)
      if action.key.isAlpha and c.vowel.removeAccentString.toLower.startsWith("uơ"):
        ac = c.vowel.getAccentString
        if c.vowel{0}.isUpper:
          vowel = "Ư"
        else:
          vowel = "ư"
        if c.vowel{1}.isUpper:
          vowel &= "Ơ"
        else:
          vowel &= "ơ"
        vowel &= c.vowel{2..-1}
        c.vowel = vowel

        c.addAccent(ac)
  elif action.kind == UNDO:
    c.reverse(trans{1..-1})

  if action.kind == ADD_MARK or (action.kind == ADD_CHAR and action.key.isAlpha):
    ac = c.vowel.getAccentString
    if ac != NONE:
      c.addAccent(NONE)
      c.addAccent(ac)
  debug "tranform", c.debug

proc canUndo(c: Components, transList: seq[string]): bool =
  ## Return whether a components can be undone with one of the transformation in
  ## transList.
  var accentList: seq[Accent] = @[]
  var markList: seq[Mark] = @[]
  var actionList: seq[Action] = @[]

  for x in c.vowel.runes:
    if x.getAccentChar != NONE:
      accentList.add(x.getAccentChar)
  for x in ($c).runes:
    if x.getMarkChar != NO_MARK:
      markList.add(x.getMarkChar)
  for x in transList:
    actionList.add(x.getAction)   
        
  proc atomicCheck(action: Action): bool =
    case action.kind
    of ADD_ACCENT:
      if action.accent in accentList:
        return true
    of ADD_MARK:
      if action.mark in markList:
        return true
    of ADD_CHAR:
      if action.key == removeAccentChar(c.vowel.last): # ơ, ư
        return true
    else:
      discard
    return false

  for x in actionList:
    if x.atomicCheck:
      return true
  return false
  
proc processKey*(str: string, key: Rune, im: InputMethod, fallbackSeq = "", skipNonVNese = true): StringPair =
  debug "processKey", str, key, fallbackSeq  
  var fallbackSeq = fallbackSeq
  ## Process a keystroke.
  #proc defaultReturn(): ProcessKeyResult =
  #  return [str & $key, fallbackSeq & $key]

  var comps = str.separate()
  # Find all possible transformations this keypress can generate  
  var transList = getTransformationList(key, im, fallbackSeq)
  var newComps = comps.copy
  # Then apply them one by one
  for t in transList:
    newComps.transform(t)
    
  if newComps == comps:
    var tmpComps = newComps.copy  
    # If none of the transformations (if any) work
    # then this keystroke is probably an undo key.  
    if newComps.canUndo(transList):
      var tmp: seq[string] = @[]
      for trans in transList:
        tmp.add("_" & trans)
      for trans in tmp:
        newComps.transform(trans)

      # Undoing the w key with the TELEX input method with the
      # w:<ư extension requires some care.
      #
      # The input (ư, w) should be undone as w
      # on the other hand, (ư, uw) should return uw.
      #
      # _transform() is not aware of the 2 ways to generate
      # ư in TELEX and always think ư was created by uw.
      # Therefore, after calling _transform() to undo ư,
      # we always get ['', 'u', ''].
      #
      # So we have to clean it up a bit.
      proc isTelexLike(): bool =
        return "<ư" in im["w"]

      proc undoneVowelEndsWithU(): bool =
        return newComps.hasVowel and newComps.vowel.last.toLower == u"u"

      proc notFirstKeyPress(): bool =
        return fallbackSeq.len >= 1

      proc userTypedWW(): bool =
        return ($fallbackSeq.last & $key).toLower == "ww"

      proc userDidntTypeUWW(): bool =
        return not (fallbackSeq.len >= 2 and fallbackSeq{-2}.toLower == u"u")

      if isTelexLike() and notFirstKeyPress() and undoneVowelEndsWithU() and userTypedWW() and userDidntTypeUWW():
        newComps.vowel = newComps.vowel{0..-1}

    if tmpComps == newComps:
      fallbackSeq.add($key)
    newComps.appendComps(key)
  else:
    fallbackSeq.add($key)
    
  if skipNonVNese and key.isAlpha and not newComps.isValidCombination(finalForm=false):
    result = [fallbackSeq, fallbackSeq]
  else:
    result = [$newComps, fallbackSeq]
  debug "processkey", result
      
proc processSequence*(sequence: string, im: InputMethod, skipNonVNese = true): string =
  ## Convert a key sequence into a Vietnamese string with diacritical marks.
  debug "processSequence", sequence
  var result, text, raw = ""
  var pair: StringPair
  for key in sequence.runes:
    if not key.isAcceptedChar(im):
      debug "===", key
      result.add(text)
      result.add($key)
      text = ""
      raw = ""
    else:
      pair = processKey(text, key, im, raw, skipNonVNese)
      text = pair.first()
      raw = pair.second()      
  result.add(text)
  debug "processSequence", result

proc processSequenceTelex*(sequence: cstring, skipNonVNese = true, wShorthand = true, bracketsShorthand = true): cstring {.exportc: "processSequenceTelex".} =
  let im = getTelexDifinition(wShorthand, bracketsShorthand)
  processSequence($sequence, im, skipNonVNese)

proc processSequenceVni*(sequence: cstring, skipNonVNese = true): cstring {.exportc: "processSequenceVni".} =
  let im = getVniDifinition()
  processSequence($sequence, im, skipNonVNese)

  
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
    return rawSeq{0..index} & rawSeq{index+1..-1}
