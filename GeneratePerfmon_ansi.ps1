# Get perfmon counters on an instance into one file

# Remove previous output file, if needed

$FileName = "c:\temp\AllPerfmonOfInterest_ansi.csv"
if (Test-Path $FileName) {
  Remove-Item $FileName
}

# Populate output file with counters of interest
#   Note1:  The output file default is UTF8 which will NOT WORK when typeperf tries to use this file later as a configuration file.
#   Note2:  Regex is at play here, so you have to escape the backslash (\)  

typeperf.exe -qx | Select-String -Pattern "\\LogicalDisk"              | out-file         -filePath c:\temp\AllPerfmonOfInterest_ansi.csv -encoding ASCII
typeperf.exe -qx | Select-String -Pattern "\\Processor\("              | out-file -append -filePath c:\temp\AllPerfmonOfInterest_ansi.csv -encoding ASCII
typeperf.exe -qx | Select-String -Pattern "Paging File"                | out-file -append -filePath c:\temp\AllPerfmonOfInterest_ansi.csv -encoding ASCII
typeperf.exe -qx | Select-String -Pattern "\\SQLServer:Memory Manager" | out-file -append -filePath c:\temp\AllPerfmonOfInterest_ansi.csv -encoding ASCII
typeperf.exe -qx | Select-String -Pattern "\\SQLServer:Buffer Manager" | out-file -append -filePath c:\temp\AllPerfmonOfInterest_ansi.csv -encoding ASCII
typeperf.exe -qx | Select-String -Pattern "\\Memory\\"                 | out-file -append -filePath c:\temp\AllPerfmonOfInterest_ansi.csv -encoding ASCII
typeperf.exe -qx | Select-String -Pattern "SQL Statistics"             | out-file -append -filePath c:\temp\AllPerfmonOfInterest_ansi.csv -encoding ASCII
typeperf.exe -qx | Select-String -Pattern "Memory Manager"             | out-file -append -filePath c:\temp\AllPerfmonOfInterest_ansi.csv -encoding ASCII
typeperf.exe -qx | Select-String -Pattern "\\Network Interface"        | out-file -append -filePath c:\temp\AllPerfmonOfInterest_ansi.csv -encoding ASCII
