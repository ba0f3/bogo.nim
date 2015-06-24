
import strutils
import unicode
import ../bogo
import ../accent
import ../mark
import ../validation
import ../types
import ../utils


echo processSequence("Vieetj Nam quee huowng toio", getTelexDifinition())
echo processSequence("Vie65t Nam que6 hu7o7ng toi6", getVniDifinition())


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

