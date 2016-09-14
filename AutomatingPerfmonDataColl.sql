

/*
	Title:			Automated perfmon data collection
	Rev. History
		1.0			gmanioci		Introduction	
		1.1			gmanioci		Make local host dynamic to avoid having to modify the vbscript for the name of the local host

	Purpose:
		To facilitate testing for MSSQL migrations or just for general troubleshooting,
		this script will create a perfmon log for the instance that it runs on and
		log the counters to its local expedba database.
	
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

-- check for an EXPEDBA DB and create if necessary
	if not exists (select name from sys.databases where name = 'expedba')
		begin
			select 'This instance is missing the EXPEDBA database.  Please contact the PDBA team.  Creating a tempory one now for perfmon data collection.'
			print  'This instance is missing the EXPEDBA database.  Please contact the PDBA team.  Creating a tempory one now for perfmon data collection.'
			
			exec ('create database expedba')
			exec ('alter database expedba set recovery simple')
		end 

-- declarations
	declare @SampleInterval			int
	declare @NbrSamplesToCollect	int
	declare @sql					varchar(1024)
	
-- initialization

	-------- UPDATE HERE --------------------------------------------------------------------------------
		set		@SampleInterval			 = 5  -- collect data this every this many seconds
		set		@NbrSamplesToCollect	 = 5  -- collect this many samples
	-----------------------------------------------------------------------------------------------------

-- 1)  Create a .csv file to get the detailed counters of interest based on the counter classes hard-coded in c:\temp\GeneratePerfmon_ansi.ps1
--     Any applicable counters found on the host that are part of the parent classes will be discovered.

	exec master..xp_cmdshell 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe C:\Temp\GeneratePerfmon_ansi.ps1' 

-- 2)  Create a system DSN using trusted security using vbscript:  cscript.exe C:\temp\CreateDSN.vbs "local server"
	declare @sql2 varchar(1024)
	declare @MachName sql_variant = (select serverproperty('machinename'))
	
	-- report localhost
		select cast(@MachName as nvarchar(128)) as 'LocalMachine'
	
	-- form synamic SQL
		set @sql2 = 'cscript.exe C:\temp\CreateDSN.vbs ' + char(34)+cast(@MachName as nvarchar(128))+char(34) 
			
	-- create the DSN
		exec master..xp_cmdshell @sql2  --'cscript.exe C:\temp\CreateDSN.vbs'
	
-- 3)  Start perfmon and write to SQL in the expedba DB.  New tables will be created to hold the data
	set @sql = 'TYPEPERF.exe -cf "c:\temp\AllPerfmonOfInterest_ansi.csv" -si '
			   +cast(@SampleInterval as varchar(12))
			   +' -sc '+cast(@NbrSamplesToCollect as varchar(12))
			   +' -f SQL -o SQL:perfmonVBS!PerfCounters'
			   
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
		 CounterDateTime desc
	
	
/*  sp_configure 'xp_cmdshell'     ,1;reconfigure
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
