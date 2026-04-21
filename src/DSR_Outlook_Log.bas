Attribute VB_Name = "DSR_Outlook_Log"
' =============================================================================
'  DSR Outlook Log — Auto-populate email log from Outlook
'
'  Pulls every email in Outlook (Sent Items + Inbox) where the subject contains
'  "DSR" and writes Subject / Sender / Timestamp / Direction / Recipient(s)
'  into the 'Outlook Log' sheet.
'
'  The DSR Count sheet reads this log via COUNTIFS to compute working-day
'  compliance automatically — no manual Y/N entry needed.
'
'  Repo: https://github.com/HarshaaNandakumar/logistics-ops-excellence
' =============================================================================

Option Explicit

' -----------------------------------------------------------------------------
'  Main entry point — bind this to the "Refresh Outlook Log" button
' -----------------------------------------------------------------------------
Sub RefreshOutlookLog()
    Dim olApp As Object, olNS As Object
    Dim sentFolder As Object, inboxFolder As Object
    Dim wsLog As Worksheet
    Dim nextRow As Long
    Dim lookbackDays As Long

    ' How far back to scan (edit to taste — 60 days is a reasonable default)
    lookbackDays = 60

    ' --- Target sheet
    Set wsLog = ThisWorkbook.Worksheets("Outlook Log")

    ' --- Clear existing data (keep header rows 1–3)
    Dim lastRow As Long
    lastRow = wsLog.Cells(wsLog.Rows.Count, "A").End(xlUp).Row
    If lastRow >= 4 Then
        wsLog.Range("A4:E" & lastRow).ClearContents
        wsLog.Range("A4:E" & lastRow).Interior.ColorIndex = xlNone
    End If

    ' --- Connect to Outlook
    On Error Resume Next
    Set olApp = GetObject(, "Outlook.Application")
    If olApp Is Nothing Then Set olApp = CreateObject("Outlook.Application")
    On Error GoTo 0

    If olApp Is Nothing Then
        MsgBox "Could not connect to Outlook. Is Outlook installed and running?", _
               vbExclamation, "DSR Outlook Log"
        Exit Sub
    End If

    Set olNS = olApp.GetNamespace("MAPI")
    Set sentFolder = olNS.GetDefaultFolder(5)   ' olFolderSentMail = 5
    Set inboxFolder = olNS.GetDefaultFolder(6)  ' olFolderInbox    = 6

    ' --- Scan both folders, starting at row 4
    nextRow = 4

    Application.ScreenUpdating = False
    Application.StatusBar = "Scanning Sent Items..."
    ScanFolder sentFolder, wsLog, nextRow, "Sent", lookbackDays

    Application.StatusBar = "Scanning Inbox..."
    ScanFolder inboxFolder, wsLog, nextRow, "Received", lookbackDays

    ' --- Sort the log by timestamp descending (newest first)
    SortLogByTimestamp wsLog

    Application.StatusBar = False
    Application.ScreenUpdating = True

    MsgBox "Outlook Log refreshed." & vbCrLf & _
           (nextRow - 4) & " DSR emails pulled from the last " & lookbackDays & " days.", _
           vbInformation, "DSR Outlook Log"
End Sub

' -----------------------------------------------------------------------------
'  Scan one Outlook folder and write DSR-matching emails to the log
' -----------------------------------------------------------------------------
Private Sub ScanFolder(folder As Object, wsLog As Worksheet, _
                       ByRef nextRow As Long, direction As String, _
                       lookbackDays As Long)
    Dim item As Object
    Dim cutoff As Date
    cutoff = Date - lookbackDays

    For Each item In folder.Items
        On Error Resume Next
        ' Only Mail items have a Subject; skip anything else (meeting requests, etc.)
        If item.Class = 43 Then   ' olMail = 43
            If item.ReceivedTime >= cutoff Or item.SentOn >= cutoff Then
                ' Match if subject contains 'DSR' (case-insensitive)
                If InStr(1, item.Subject, "DSR", vbTextCompare) > 0 Then
                    WriteLogRow wsLog, nextRow, item, direction
                    nextRow = nextRow + 1
                End If
            End If
        End If
        On Error GoTo 0
    Next item
End Sub

' -----------------------------------------------------------------------------
'  Write a single row into the log sheet with formatting
' -----------------------------------------------------------------------------
Private Sub WriteLogRow(wsLog As Worksheet, row As Long, item As Object, direction As String)
    Dim ts As Date
    Dim senderEmail As String
    Dim recipients As String
    Dim i As Long

    ' Timestamp — use SentOn for Sent, ReceivedTime for Received
    If direction = "Sent" Then
        ts = item.SentOn
    Else
        ts = item.ReceivedTime
    End If

    ' Sender — for Sent items this is the current user's email
    On Error Resume Next
    senderEmail = item.SenderEmailAddress
    If senderEmail = "" Then senderEmail = item.Sender.Address
    On Error GoTo 0

    ' Recipients — concatenate all addresses
    recipients = ""
    For i = 1 To item.Recipients.Count
        If recipients <> "" Then recipients = recipients & "; "
        recipients = recipients & item.Recipients(i).Address
    Next i

    ' Write to sheet
    wsLog.Cells(row, 1).Value = item.Subject
    wsLog.Cells(row, 2).Value = senderEmail
    wsLog.Cells(row, 3).Value = ts
    wsLog.Cells(row, 3).NumberFormat = "dd-mmm-yyyy hh:mm"
    wsLog.Cells(row, 4).Value = direction
    wsLog.Cells(row, 5).Value = recipients

    ' Row formatting
    Dim rng As Range
    Set rng = wsLog.Range(wsLog.Cells(row, 1), wsLog.Cells(row, 5))
    rng.Font.Name = "Calibri"
    rng.Font.Size = 10
    rng.Borders.LineStyle = xlContinuous
    rng.Borders.Color = RGB(191, 191, 191)

    ' Direction-specific color
    If direction = "Sent" Then
        wsLog.Cells(row, 4).Font.Color = RGB(55, 86, 35)     ' green
        wsLog.Cells(row, 4).Font.Bold = True
    Else
        wsLog.Cells(row, 4).Font.Color = RGB(128, 96, 0)     ' amber
        wsLog.Cells(row, 4).Font.Bold = True
    End If
    wsLog.Cells(row, 4).HorizontalAlignment = xlCenter
    wsLog.Cells(row, 3).HorizontalAlignment = xlCenter

    ' Zebra stripe
    If row Mod 2 = 0 Then
        rng.Interior.Color = RGB(250, 250, 250)
    End If
End Sub

' -----------------------------------------------------------------------------
'  Sort the log by timestamp descending (newest first)
' -----------------------------------------------------------------------------
Private Sub SortLogByTimestamp(wsLog As Worksheet)
    Dim lastRow As Long
    lastRow = wsLog.Cells(wsLog.Rows.Count, "A").End(xlUp).Row
    If lastRow < 5 Then Exit Sub

    With wsLog.Sort
        .SortFields.Clear
        .SortFields.Add Key:=wsLog.Range("C4:C" & lastRow), _
                        SortOn:=xlSortOnValues, _
                        Order:=xlDescending
        .SetRange wsLog.Range("A4:E" & lastRow)
        .Header = xlNo
        .Apply
    End With
End Sub

' -----------------------------------------------------------------------------
'  Optional: install a button on Outlook Log sheet (run once after import)
' -----------------------------------------------------------------------------
Sub AddRefreshButton()
    Dim wsLog As Worksheet
    Dim btn As Object

    Set wsLog = ThisWorkbook.Worksheets("Outlook Log")

    ' Remove any existing buttons
    Dim shp As Object
    For Each shp In wsLog.Shapes
        If shp.Name Like "btnRefresh*" Then shp.Delete
    Next shp

    ' Add new button
    Set btn = wsLog.Buttons.Add(Left:=wsLog.Columns("F").Left + 10, _
                                 Top:=wsLog.Rows(2).Top, _
                                 Width:=160, Height:=24)
    btn.Name = "btnRefresh"
    btn.Caption = "↻  Refresh Outlook Log"
    btn.OnAction = "RefreshOutlookLog"
    btn.Font.Bold = True
    btn.Font.Size = 10

    MsgBox "Refresh button added. Click it to pull DSR emails from Outlook.", _
           vbInformation, "DSR Outlook Log"
End Sub
