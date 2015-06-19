import utils
import strutils
import unicode
import accent


var s1 = "abcdef"
echo s1[1..2]
quit()

#echo "à".runeAt(0).removeAccentChar
#quit()
#echo separate("tướng")

var s = "TÔI LÀ NGƯỜI VIỆT NAM"
discard "- Cộng hoà xã hội Chủ nghĩa Việt Nam"
echo s.len
echo s.removeAccentString
echo s.removeAccentString.len
var x = VOWELS.runeAt(3)
echo utils.toLower(s)
echo getAccentChar(x)
