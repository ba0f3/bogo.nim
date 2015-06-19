import utils
import strutils
import unicode
import accent
import mark
import validation
import types

echo separate("tướng")

assert isValidString("éc")
assert isValidString("ác")
assert isValidString("úc")
assert isValidString("óc")

#echo "à".runeAt(0).removeAccentChar
#quit()

var comps = newComponents("Ng", "ƯƠi")
comps.addAccent(HOOK)
echo comps.vowel

var s = "TÔI LÀ NGƯỜI VIỆT NAM - Cộng hoà xã hội Chủ nghĩa Việt Nam"
echo s.len
echo s.removeAccentString
echo s.removeAccentString.len
var x = VOWELS.runeAt(3)
echo utils.toLower(s)
echo getAccentChar(x)
