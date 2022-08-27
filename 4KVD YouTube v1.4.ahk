#NoEnv
#Persistent
#SingleInstance Force
OnClipboardChange("GrabClip")
CoordMode Mouse
CoordMode ToolTip
SetBatchLines -1

Global APP:="D:\Portable\4KVD\4KVD.exe"
Global DIR:="D:\Video\"
Global EXE:="ahk_exe 4KVD.exe"
Global LNK:="https:\/\/(?:www.)?youtu.?be(?:.com)?\/(?:watch\?v=|shorts\/)?(.{11})"
Global TTL:=[],CHL:=[],CHK:=[]
Global TOG:=1,CTR:=0

GrabClip(){
  If TOG{
    CLP:=Clipboard
    If RegExMatch(CLP,LNK){
      POS:=1
      While POS:=RegExMatch(CLP,LNK,FD,POS+StrLen(FD)){
        TMP:="https://www.youtube.com/watch?v=" FD1
        HTM:=GrabPage(TMP)
        RegExMatch(HTM,"<meta name=""title"" content=""([^""]+)"">",TT)
        RegExMatch(HTM,"ownerChannelName"":""([^""]+)",OC)
        If RegExMatch(TT1,"\\|/|:|\*|\?|""|<|>|\||&#0?39;|&amp;|&quot;")
          TT1:=CodePage(TT1)
        DupCheck(TT1,OC1,TMP)
      }
    }
  }
}

DupCheck(TT1:="",OC1:="",TMP:=""){
  Loop % TTL.Count(){
    If (TT1=TTL[A_Index])
      Return
  }
  TOG:=0,Clipboard:=TMP,TOG:=1

  If WinExist(EXE)
    WinActivate
  Else
    Run % APP
  WinWaitActive % EXE
;### Need to check for 'Continue?' window if closed prematurely! ###
  MouseGetPos mx,my
  WinGetPos wx,wy,,,% EXE
  MouseClick L,wx+42,wy+73,,0
  MouseMove mx,my,0
  WinMinimize % EXE

  ClipName(TT1,OC1)
}

ClipName(TT1:="",OC1:=""){
  If TT1 && OC1
    TTL.Push(TT1),CHL.Push(OC1),CHK.Push(12)
  Loop % TTL.Count(){
    If CHK[A_Index]{
       CHK[A_Index]--
    }Else{
      FIL:=TTL[A_Index] ".mp4"
      PRT:=TTL[A_Index] "*.part"
      If !FileExist(DIR PRT)
        If FileExist(DIR FIL){
          FileMove % DIR FIL,% DIR CHL[A_Index] " - " FIL
          TTL.Remove(A_Index),CHL.Remove(A_Index),CHK.Remove(A_Index)
        }
    }
   If TTL.Count()
     TMP.=TTL[A_Index] " : " CHL[A_Index] " : " CHK[A_Index] (TTL[A_Index]?"`n":"")
   Else
     TMP:=""
  }
  ToolTip % TTL.Count()?TMP:"",10,800,20
  SetTimer % A_ThisFunc,% TTL.Count()?-1000:"Off"
}

GrabPage(URL){
  whr:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
  whr.Open("GET",URL,True)
  whr.Send()
  whr.WaitForResponse()
  Return RegExReplace(whr.ResponseText,"`n","`r`n")
}

CodePage(STR){
  STR:=RegExReplace(STR,"\\|/|:|\*|\?|""|<|>")
  STR:=RegExReplace(STR,"\||&quot;"," ")
  STR:=RegExReplace(STR,"&#0?39;","'")
  STR:=RegExReplace(STR,"&amp;","&")
  Return STR
}
