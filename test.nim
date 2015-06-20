
import strutils
import unicode
import bogo
import accent
import mark
import validation
import types
import utils

echo processSequence("con méof.ddieen", getTelexDifinition())
echo processSequence("Vieejt Nam quee huwowng tooi", getTelexDifinition())


echo separate("tướng")

assert isValidString("éc")
assert isValidString("ác")
assert isValidString("úc")
assert isValidString("óc")


var s = "TÔI LÀ NGƯỜI VIỆT NAM - Cộng hoà xã hội Chủ nghĩa Việt Nam"
echo s.ulen
echo s.removeAccentString
echo s.removeAccentString.ulen
var x = VOWELS{3}
echo utils.toLower(s)
echo getAccentChar(x)

