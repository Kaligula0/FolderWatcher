# FolderWatcher
A PowerShell (Windows) script that watches folder for new files and archives them somewhere else.

# Why?
Invented especially for GnuCash, which creates a lot of backup and log files in the main file's directory during work.

# Example for GnuCash
### Scheduler - New Task ###
Paste the path to GnuCash.exe into code of both triggers, e.g.:
`and *[EventData[Data[@Name='NewProcessName'] and (Data='C:\Program Files (x86)\gnucash\bin\gnucash.exe')]]`
and
`and *[EventData[Data[@Name='ProcessName'] and (Data='C:\Program Files (x86)\gnucash\bin\gnucash.exe')]]`.

Paste your PowerShell custom window title into the code of the task action, e.g.: <code>cmd /c (FOR /F "tokens=1 USEBACKQ" %a IN (&#96;tasklist /fi "imagename eq powershell.exe" /fo table /nh&#96;) DO (if "%a"=="powershell.exe" (taskkill /im powershell.exe /fi "windowtitle eq **GnuCash Folder Watcher**" & exit) else (start powershell.exe -file "C:\Path\To\FolderWatcher.ps1" & exit)))</code>

### script settings ###
```
# SETTINGS
$host.ui.RawUI.WindowTitle = "GnuCash Folder Watcher" #appears also in Scheduled Task action above!
$homeDir = 'C:\Path\To\Directory\Budget'
$archiveDir = 'C:\Path\To\Directory\Budget\Archive'
$filter = '*.gnucash.*.*'
```

Optionally uncomment a line that clears the directory of desired files before Watcher init:

`Move-Item "$homeDir\$filter" "$archiveDir"`.

### And enjoy the peace. ###
