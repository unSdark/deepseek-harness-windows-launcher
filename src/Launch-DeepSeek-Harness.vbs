Option Explicit

Const WAIT_STEPS = 60
Const WAIT_MILLISECONDS = 500

Dim shell, fileSystem, dshCommand, serviceUrl, launcherDir, logFile
Set shell = CreateObject("WScript.Shell")
Set fileSystem = CreateObject("Scripting.FileSystemObject")

dshCommand = shell.ExpandEnvironmentStrings("%APPDATA%") & "\npm\dsh.cmd"
serviceUrl = "http://127.0.0.1:3080/"
launcherDir = shell.ExpandEnvironmentStrings("%USERPROFILE%") & "\.dsh\launcher"
logFile = launcherDir & "\dsh-web.log"

If WScript.Arguments.Named.Exists("syntax") Then
  WScript.Echo "OK: VBScript syntax"
  WScript.Quit 0
End If

If WScript.Arguments.Named.Exists("test") Then
  If Not fileSystem.FileExists(dshCommand) Then
    WScript.Echo "ERROR: dsh.cmd was not found at " & dshCommand
    WScript.Quit 1
  End If

  WScript.Echo "OK: " & dshCommand
  WScript.Quit 0
End If

If Not fileSystem.FileExists(dshCommand) Then
  MsgBox "DeepSeek Harness was not found:" & vbCrLf & dshCommand, vbCritical, "DeepSeek Harness"
  WScript.Quit 1
End If

If Not fileSystem.FolderExists(launcherDir) Then
  fileSystem.CreateFolder launcherDir
End If

If Not IsReady(serviceUrl) Then
  Dim commandLine
  commandLine = shell.ExpandEnvironmentStrings("%COMSPEC%") & " /d /c " & _
    Chr(34) & Chr(34) & dshCommand & Chr(34) & _
    " web --host 127.0.0.1 --port 3080 >> " & Chr(34) & logFile & Chr(34) & " 2>&1" & Chr(34)

  shell.Run commandLine, 0, False

  Dim stepNumber
  For stepNumber = 1 To WAIT_STEPS
    WScript.Sleep WAIT_MILLISECONDS
    If IsReady(serviceUrl) Then Exit For
  Next
End If

If IsReady(serviceUrl) Then
  shell.Run serviceUrl, 1, False
Else
  MsgBox "DeepSeek Harness did not start within 30 seconds." & vbCrLf & _
    "Please check the log:" & vbCrLf & logFile, vbCritical, "DeepSeek Harness"
  WScript.Quit 1
End If

Function IsReady(address)
  On Error Resume Next

  Dim request
  Set request = CreateObject("WinHttp.WinHttpRequest.5.1")
  request.SetTimeouts 400, 400, 400, 400
  request.Open "GET", address, False
  request.Send

  If Err.Number = 0 Then
    IsReady = (request.Status >= 200 And request.Status < 500)
  Else
    IsReady = False
  End If

  Set request = Nothing
  Err.Clear
  On Error GoTo 0
End Function
