#NoEnv                                                                         ;Don't check for system variables
#Persistent                                                                    ;Keep running when no hotkeys present
#SingleInstance Force                                                          ;Only run one instance
OnClipboardChange("GrabClip")                                                  ;Check for clipboard changes
CoordMode Mouse                                                                ;Mouse coords relative to fullscreen
CoordMode ToolTip                                                              ;ToolTip coords relative to fullscreen

APP:="D:\Portable\4KVD\4KVD.exe"                                               ;4KVD exe location
DIR:="D:\Video\"                                                               ;Directory videos are saved to

GrabClip(){                                                                    ;Run this on clipboard changes
  Global APP                                                                   ;  Make APP var accessible
  CLP:=Clipboard                                                               ;  Copy clipboard to CLP
  EXE:="ahk_exe 4KVD.exe"                                                      ;  4KVD app name
  If (RegExMatch(CLP,"https:\/\/www.youtube.com\/(watch\?v=|shorts\/)")=1){    ;  Clipboard contains YT link at pos 1?
    HTM:=GrabPage(CLP)                                                         ;    Download the YT html page
    RegExMatch(HTM,"<meta name=""title"" content=""([^""]+)"">",TT)            ;    Grab the title from the html
    RegExMatch(HTM,"ownerChannelName"":""([^""]+)",OC)                         ;    Ditto for the channel name
    If RegExMatch(TT1,"\\|/|:|\*|\?|""|<|>|\||&#0?39;|&amp;")                  ;    Title has non-filesystem characters?
      TT1:=CodePage(TT1)                                                       ;      Run the strip characters function
    If WinExist(EXE)                                                           ;    If 4KVD is already open
      WinActivate                                                              ;      Activate it
    Else                                                                       ;    Otherwise
      Run % APP                                                                ;      Run it
    WinWaitActive % EXE                                                        ;    Wait until it's active
;##### Need to check for 'Continue?' window if closed prematurely! #####       ;    To do!
    MouseGetPos mx,my                                                          ;    Get current mouse position
    WinGetPos wx,wy,,,% EXE                                                    ;    Get 4KVD window position
    MouseClick L,wx+42,wy+73,,0                                                ;    Click the Paste button
    MouseMove mx,my,0                                                          ;    Move the mouse back where it was
    WinMinimize % EXE                                                          ;    Minimise 4KVD
    ClipName(TT1,OC1)                                                          ;    Run a timer to check if finished
  }                                                                            ;  End of clipboard check code
}                                                                              ;End function block

ClipName(TT1:="",OC1:=""){                                                     ;Timer code to check when downloaded
  Static TTL:=[],CHL:=[],CTR:=0                                                ;  Keep these variables in memory
  Global DIR                                                                   ;  Make DIR var accessible
  CTR++                                                                        ;  Add one to time (in seconds)
  If TT1 && OC1                                                                ;  If title AND Channel have contents
    TTL.Push(TT1),CHL.Push(OC1)                                                ;    Add them to an array
  Loop % TTL.Count(){                                                          ;  Loop through still downloading vids
    FIL:=TTL[A_Index] ".mp4"                                                   ;    Filename of completed vid
    PRT:=TTL[A_Index] "*.part"                                                 ;    Filename of unfinished vids
    If !FileExist(DIR PRT)                                                     ;    If no unfinished vids found
      If FileExist(DIR FIL){                                                   ;      And finished vid exists
        FileMove % DIR FIL,% DIR CHL[A_Index] " - " FIL                        ;        Rename the file: Channel - Title
        TTL.Remove(A_Index),CHL.Remove(A_Index)                                ;        Remove from the arrays
      }                                                                        ;      End finished file check
    If TTL.Count()                                                             ;    If files still to download?
      TMP.=TTL[A_Index] " : " CHL[A_Index] (TTL[A_Index]?"`n":"")              ;      Add them to a list
    Else                                                                       ;    Otherwise
      TMP:="",CTR:=0                                                           ;      Clear list and time count
  }                                                                            ;  End loop check
;  ToolTip % TTL.Count()?TTL.Count() " files in " CTR "s.`n`n" TMP:"",10,800,20 ;  Show a ToolTip of what's downloading
  SetTimer % A_ThisFunc,% TTL.Count()?-1000:"Off"                              ;  Restart/Stop the timer if anything left
}                                                                              ;End function block

GrabPage(URL){                                                                 ;Code to grab the html page
  whr:=ComObjCreate("WinHttp.WinHttpRequest.5.1")                              ;  Create a http connection
  whr.Open("GET",URL,True)                                                     ;  Open the connection
  whr.Send()                                                                   ;  Ask for the page content
  whr.WaitForResponse()                                                        ;  Wait until content passed
  Return RegExReplace(whr.ResponseText,"`n","`r`n")                            ;  Send the html back to the grab code
}                                                                              ;End function block

CodePage(STR){                                                                 ;Code to strip non-filesystem characters
  STR:=RegExReplace(STR,"\\|/|:|\*|\?|""|<|>")                                 ;  Remove these characters
  STR:=RegExReplace(STR,"\|"," ")                                              ;  Replace the characters with a space 
  STR:=RegExReplace(STR,"&#0?39;","'")                                         ;  Replace html code with single quote
  STR:=RegExReplace(STR,"&amp;","&")                                           ;  Replace html code with single quote
  Return STR                                                                   ;  Return the amended html back to the code
}                                                                              ;End function block
