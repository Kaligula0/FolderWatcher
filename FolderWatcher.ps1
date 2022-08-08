# CHECK AUDITION POLICY SETTINGS
# source:
# https://www.tenforums.com/software-apps/139098-can-i-know-when-application-started-closed-windows-10-a.html
#
# run gpedit.msc
# Local Computer Policy \ Computer Configuration \ Windows Settings \ Security Settings \ Local Policies \ Audit Policy \ "Audit process tracking" \ check both boxes "Success,Fail"

# TASK SCHEDULE SETTINGS - CREATE NEW TASK
# source of task triggers code:
# - https://www.tenforums.com/software-apps/139098-can-i-know-when-application-started-closed-windows-10-a.html
# source of task action code:
# - https://www.stackoverflow.com (various threads)
#
# - trigger 1st (waits for the app process to start):
#  Event > Custom > Edit > XML > paste:
#  <QueryList>
#    <Query Id="0" Path="Security">
#      <Select Path="Security">
#       *[System[Provider[@Name='Microsoft-Windows-Security-Auditing']
#       and (EventID=4688)]]
#       and *[EventData[Data[@Name='NewProcessName'] and (Data='C:\Path\To\Your\app.exe')]]
#     </Select>
#    </Query>
#  </QueryList>
#
# - trigger 2nd (waits for the app process to stop):
#  Event > Custom > Edit > XML > paste:
#  <QueryList>
#    <Query Id="0" Path="Security">
#      <Select Path="Security">
#       *[System[Provider[@Name='Microsoft-Windows-Security-Auditing']
#       and (EventID=4689)]]
#       and *[EventData[Data[@Name='ProcessName'] and (Data='C:\Path\To\Your\app.exe')]]
#     </Select>
#    </Query>
#  </QueryList>
#
# - action (pay attention to the "windowtitle eq" part, where it should be the same as $host.ui.RawUI.WindowTitle in SETTINGS below):
#  cmd /c (FOR /F "tokens=1 USEBACKQ" %a IN (`tasklist /fi "imagename eq powershell.exe" /fo table /nh`) DO (if "%a"=="powershell.exe" (taskkill /im powershell.exe /fi "windowtitle eq Folder Watcher" & exit) else (start powershell.exe -file "C:\Path\To\FolderWatcher.ps1" & exit)))

# SAVE THIS FILE WITH ANSI ENCODING

# source of PowerShell code below:
# https://superuser.com/questions/226828/

# SETTINGS
$host.ui.RawUI.WindowTitle = "Folder Watcher" #appears also in Scheduled Task action above!
$homeDir = 'C:\Path\To\Directory\That\Should\Be\Watched'
$archiveDir = 'C:\Path\To\Directory\Where\Files\Shoould\Be\Moved'
$filter = '*.log'

# MOVE EXISTING BAKUPS TO ARCHIVE BEFORE INIT
# (you can uncomment the below line to enable)
# Move-Item "$homeDir\$filter" "$archiveDir"

# INIT WATCHER
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $homeDir
$watcher.Filter = $filter
$watcher.EnableRaisingEvents = $true
$action =
{
    $path = $event.SourceEventArgs.FullPath
    $name = $event.SourceEventArgs.Name
    $changetype = $event.SourceEventArgs.ChangeType
    Write-Host """$name"" was $changetype at $(get-date)."
    Write-Host "Moving that file..."
	# TO DO: handle file-moving errors
	Move-Item "$path" "$archiveDir"
    Write-Host "  -> File ""$name"" moved to $archiveDir."
}

# START WATCHER
Register-ObjectEvent $watcher 'Created' -Action $action

# TEST WATCHER (CREATE NEW FILE)
# Let's create a new text file there and see what happens:
# $null = New-Item -path 'C:\Path\To\Directory\That\Should\Be\Watched\file.txt' -ItemType File

# PAUSE CONSOLE
# (so it doesn't close right after registering Watcher)
while ($true) {sleep 5}

# We can view all existing subscribed events by using
# the Get-EventSubscriber command.
# Then, to remove them, use the Unregister-Event cmdlet.
# 
# REMOVE WATCHER
# Get-EventSubscriber | Unregister-Event
#
# Or simply close the console.
