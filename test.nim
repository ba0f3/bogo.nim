
import strutils
import unicode
import bogo
import accent
import mark
import validation
import types
import utils



let myrune: Rune = u"ê"
echo myrune
echo VOWELS{2}

echo VOWELS{1..2}
echo VOWELS.ulen
discard getTelexDifinition()
echo separate("tướng")

assert isValidString("éc")
assert isValidString("ác")
assert isValidString("úc")
assert isValidString("óc")

echo u"à".removeAccentChar
#quit()

var comps = newComponents("Ng", "ƯƠi")
comps.addAccent(HOOK)
echo comps.vowel

var s = "TÔI LÀ NGƯỜI VIỆT NAM - Cộng hoà xã hội Chủ nghĩa Việt Nam"
echo s.ulen
echo s.removeAccentString
echo s.removeAccentString.ulen
var x = VOWELS{3}
echo utils.toLower(s)
echo getAccentChar(x)

