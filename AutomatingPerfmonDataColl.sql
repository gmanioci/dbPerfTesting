

/*
	Title:			Automated perfmon data collection
	Author:			gmanioci, 12/17/15
	Rev. History	1.0	

	Purpose
	To facilitate testing for 2014 migration or just for general troubleshooting,
	this script will create a perfmon log for the instance that it runs on and
	log the counters to the local expedba dsatabase.
	
	1) Create a .csv file to get the detailed counters of interest 
	   using powershell and a configuration file.
	2) Create a system DSN using trusted security using vbscript
	3) Create a perfmon log using typeperf.exe and the output from step 1
	   which will run for a finite number of sample collection (local variables 
	   to set them are below). 
	4) Query the expedba database using the tables created by typeperf.
	
	Note:  The file C:\Temp\AllPerfmonOfInterest.csv controls which perfmon 
	       counters are collected so edit that one, if needed.  It is 
	       caled by powershell in step 1.
	       
*/

-- declarations
	declare @SampleInterval			int
	declare @NbrSamplesToCollect	int
	declare @sql					varchar(1024)
	
-- initialization

	-- UPDATE HERE ---------------------------------
	set		@SampleInterval			 = 5  -- seconds
	set		@NbrSamplesToCollect	 = 5
	------------------------------------------------

-- 1)  Create a .csv file to get the detailed counters of interest 
	exec master..xp_cmdshell 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe C:\Temp\GeneratePerfmon_ansi.ps1' 

-- 2)  Create a system DSN using trusted security using vbscriptcscript.exe C:\temp\CreateDSN.vbs
	exec master..xp_cmdshell 'cscript.exe C:\temp\CreateDSN.vbs'
	
-- 3)  Start perfmon and write to SQL in the expedba DB.  New tables will be created to hold the data
	
	-- this worked: (cf file in ansi format?)
	-- TYPEPERF -cf "C:\Temp\Counters.csv" -si 5 -sc 4 -f SQL -o SQL:perfmonVBS!PerfCounters
	
	-- this does not work:  (unicode format?)
	-- TYPEPERF.exe -cf "c:\temp\AllPerfmonOfInterest.csv" -si 5 -sc 4 -f SQL -o SQL:perfmonVBS!PerfCounters
	
	
	set @sql = 'TYPEPERF.exe -cf "c:\temp\AllPerfmonOfInterest_ansi.csv" -si '
			   +cast(@SampleInterval as varchar(12))
			   +' -sc '+cast(@NbrSamplesToCollect as varchar(12))
			   +' -f SQL -o SQL:perfmonVBS!PerfCounters'
			   
	select @sql
	exec master..xp_cmdshell @sql  
	
-- 4)  Query the output
	SELECT 
		 cde.[MachineName]
		,cde.[ObjectName]
		,cde.[CounterName]
		,cda.*
	FROM 
		 [EXPEDBA].[dbo].[CounterDetails] cde
	INNER JOIN 
		 [EXPEDBA].[dbo].[CounterData] cda on cda.CounterID = cde.CounterID
	order by 
		 7 desc
	
	
/*
	# Get perfmon counters on an instance into one file
	typeperf.exe -qx | Select-String -Pattern "\LogicalDisk" >> c:\temp\AllPerfmonOfInterest.csv
	typeperf.exe -qx | Select-String -Pattern "\Processor(" >> c:\temp\AllPerfmonOfInterest.csv
	typeperf.exe -qx | Select-String -Pattern "Paging File" >> c:\temp\AllPerfmonOfInterest.csv
	typeperf.exe -qx | Select-String -Pattern "\SQLServer:Memory Manager" >> c:\temp\AllPerfmonOfInterest.csv
	typeperf.exe -qx | Select-String -Pattern "\SQLServer:Buffer Manager" >> c:\temp\AllPerfmonOfInterest.csv
	typeperf.exe -qx | Select-String -Pattern "\Memory\" >> c:\temp\AllPerfmonOfInterest.csv
	typeperf.exe -qx | Select-String -Pattern "SQL Statistics" >> c:\temp\AllPerfmonOfInterest.csv
	typeperf.exe -qx | Select-String -Pattern "Memory Manager >> c:\temp\AllPerfmonOfInterest.csv
	typeperf.exe -qx | Select-String -Pattern "\Network Interface" >> c:\temp\AllPerfmonOfInterest.csv
*/
