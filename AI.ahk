#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include, JSON.ahk

F12::
If !(FileExist("API_Key.ini"))
  {
    ; No real validations put in place yet
    Inputbox, API_key,, Enter your key

    Msgbox IMPORTANT! This does NOT have API key validations in place. If you need to change your key, you MUST edit APIKey.ini or nothing will work.
    IniWrite, %API_key%, API_key.ini, Section, Key
  }
; API endpoint
url:="https://api.openai.com/v1/completions"
IniRead, API_key, API_key.ini, Section, Key
clipboardOld := Clipboard
Clipboard = ""
Send ^c
Clipwait
sleep 200
InputBox, command, Enter command, Enter command to generate the following from highlighted text`n`nc | cloze`ns | summary`nk | key points`nkt | key points + terminology`nt | terminology`nx | explanation`n`nLeave blank if you only want highlighted text as prompt`n`nYou may also enter your own custom prompt below. This custom prompt will act on the input text you have highlighted, , 640, 480
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
  prompt := "Extract the key points from the following input in bullet points. Also define any terminology an average reader might stuggle with. Input start:`n" . clipboard
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
} else if (command = "x" || command == "explain" || command == "explaination") {
  prompt := "Explain the following text in simple terms. Input start:`n" . clipboard
  command_type := "explaination"
} else {
  prompt := command . " Input start: " . clipboard
  command_type := "custom prompt + clipboard"
}

try{ ; only way to properly protect from an error here
    ; weird workaround to get temperature parameter to work
    data:={"model":"text-davinci-003","prompt": prompt,"max_tokens": 1000,"temperature": 1234} ; key-val data to be posted
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    whr.Open("POST", url, true)
    whr.SetRequestHeader("Content-Type", "Application/json")
    whr.SetRequestHeader("Authorization", "Bearer " . API_key)
    tooltip % "Generating " . command_type
    whr.Send(StrReplace(JSON.Dump(data), 1234, 0.7))
    whr.WaitForResponse()

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