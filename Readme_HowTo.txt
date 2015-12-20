

How To Execute Automated Perfmon Data Collection

1) Copy these files to c:\temp of the machine to be monitored:
  
	CreateDSN.vbs
	GeneratePerfmon_ansi.ps1

2) In AutomatingPerfmonDataColl.sql, edit the follection two parameters 
   to configure the amount of data that you want to collect:


	-- UPDATE HERE ---------------------------------
	set		@SampleInterval		     = 5  -- seconds
	set		@NbrSamplesToCollect	 = 5

3) Execute AutomatingPerfmonDataColl.sql in Management studio 9SSMS).
   The query window will stay open until the collection is complete.

END
