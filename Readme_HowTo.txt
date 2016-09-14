

How To Execute Automated Perfmon Data Collection


1) Extract and copy these files to c:\temp of the machine to be monitored:
  
	
CreateDSN.vbs
	
GeneratePerfmon_ansi.ps1



2) By default, the script will collect 5 samples of perfmon 5 seconds apart.  Edit as needed in AutomatingPerfmonDataColl.sql

The query window will stay open until the collection is complete.



END
