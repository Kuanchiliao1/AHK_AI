#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include, JSON.ahk


F12::
IniRead, API_key, API_key.ini, Section, Key
clipboardOld := Clipboard
Clipboard = ""
Send ^c
Clipwait
sleep 200
InputBox, command, Enter command, Enter command to generate the following from highlighted text`n`nc | cloze`ns | summary`nk | key points`nt | terminology`n`nLeave blank if you only want highlighted text as prompt, , 640, 480
sleep 200
prompt := ""
command_type := ""
; Convert to plain text
clipboard := clipboard

StringLower, command, command
if (command == "c" || command == "cloze") {
  prompt := "Generate fill in the blanks that capture the main points in the following input. Rules { 1. The blanks are short and there may only be one blank per sentence. 2. Make 3-10 of these total. 3. List out answers as a numbered list at the end. 4. Prioritize nouns to avoid ambiguity} Example of good output: `n1. The __ never falls far from the tree. `n2. What comes up must go __. `n3 May the __ always be with you. `n4. What is the powerhouse of the cell? `n1. apple `n2. down `n3. Force `n4 Mitochondria `n Input start:`n" . clipboard
  command_type := "cloze"
} else if (command == "k" || command == "key points" || command == "key") {
  prompt := "Extract the key points from the following text in bullet format. Input start:`n" . clipboard
  command_type := "key points"
} else if (command == "kt" || command == "tk") {
  prompt := "Extract the key points from the following text in bulleAlso define any terminology an average reader might stuggle with. Input start:`n" . clipboard
  command_type := "key points and terminology"
} else if (command == "t" || command == "terminology" || command == "term") {
  prompt := "Define any terminology an average reader might stuggle with. Input start:`n" . clipboard
  command_type := "terminology"
} else if (command == "c" || command == "cloze") {
  prompt := "Generate cloze deletions for the following input. Generate them to cover all the main points and reword every sentence. Wrap the answer in brackets [like so].Make up to 10. Input start:`n" . clipboard
  command_type := "cloze"
} else if (command = "s" || command == "summary" || command == "summarize") {
  prompt := "Summarize the following text. Input start:`n" . clipboard
  command_type := "summary"
} else if (command = "t" || command == "thought provoking" || command == "thought") {
  prompt := "Generate thought provoking points and questions from the following passage. Input start:`n" . clipboard
  command_type := "thought provoking points"
} else {
  prompt := clipboard
  command := "based on raw clipboard"
}
; switch command
; {
;   case ("c"):
;     prompt := "Generate fill in the blanks that capture the main points in the following input. Rules: 1. Wrap the answer in brackets [like so]. 2. Make up to 10. 3. Do NOT show the answers at the end. List them out at the end.`n Input start:`n" . clipboard
;     command_type := "cloze"
;     msgbox % command_type
;   case ("k" || "key points" || "key"):
;     prompt := "Extract the key points from the following text in bullet format. Input start:`n" . clipboard
;     command_type := "key points"
;   case ("t" || "terminology"):
;     prompt := "Define any terminology an average reader might stuggle with in a seperate section. Input start:`n" . clipboard
;     command_type := "terminology"
;   case ("kt" || "key terminology"):
;     prompt := "Generate cloze deletions for the following input. Generate them to cover all the main points and reword every sentence. Wrap the answer in brackets [like so].Make up to 10. Input start:`n" . clipboard
;     command_type := "cloze"
;   case "s" || "summary":
;     prompt := "Summarize the following text. Input start:`n" . clipboard
;     command_type := "summary"
;   case ("tp" || "thought provoking points" || "thought"):
;     prompt := "Generate thought provoking points and questions from the following passage. Input start:`n" . clipboard
;     command_type := "thought provoking points"
;   default:
;     prompt := clipboard
; }

try{ ; only way to properly protect from an error here
    data:={"model":"text-davinci-003","prompt": prompt,"max_tokens": 1000,"temperature": 1234} ; key-val data to be posted
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    whr.Open("POST", url, true)
    whr.SetRequestHeader("Content-Type", "Application/json")
    whr.SetRequestHeader("Authorization", "Bearer " . API_key)
    tooltip % "Generating " . command_type
    whr.Send(StrReplace(JSON.Dump(data), 1234, 0.7))
    whr.WaitForResponse()
    ; msgbox % whr.ResponseText

    ; you can get the response data either in raw or text format
    ; raw: hObject.responseBody
    responseText := whr.ResponseText
    responseData := JSON.load(responseText)
    
    response := responseData["choices"][1]["text"]
    sleep 200
    Clipboard := RegexReplace(response, "\n")
    Clipboard := response
    tooltip
    Gui, Destroy
    Gui, Font, s25, Verdana,
    Gui, Add, Text, cTeal W1100 wrap ReadOnly, Copied to clip!`n`n %clipboard%
    Gui, Show, W1200 H1000 Center,, Wrap Text
    Gui, Color, cNavy
    Gui, +resize
}catch e {
    MsgBox, % e.message
}
return