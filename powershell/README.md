# Windows Terminal Stuff

## Profile

* The Terminal profile is stored in JSON format under the user profile folder tree.
* Example: C:\Users\user123\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json

## Images

* Each profile within the profiles.json file has a "backgroundImage" attribute which needs to be mapped to 
a valid image path.  If the path is incorrect, or the name is invalid, the background will show as blank.  There won't
be any error messsages displayed.
