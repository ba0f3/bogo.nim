import unicode

import utils
import accent
import mark
import types
import validation

proc getTelexDifination(wShorthan = true, bracketsShorthand = true) =
  ## Create a definition dictionary for the TELEX input method
  ##
  ## Args:
  ##    w_shorthand (optional): allow a stand-alone w to be
  ##        interpreted as an ư. Default to True.
  ##    brackets_shorthand (optional, True): allow typing ][ as
  ##        shorthand for ươ. Default to True.
  ##
  ## Returns a dictionary to be passed into process_key().

  var telex = {
               'a': @["a^"],
               'o': @["o^"],
               'e': @["e^"],
               'w': @["u*", "o*", "a+"]
  }
  #echo telex('w')
