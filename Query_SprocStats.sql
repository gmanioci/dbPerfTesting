

/*
	General query for sproc stats data.  Stats are at the SQL statement level,
	so there are separate stats for each statement making up the batch or stored procedure.
	
	There might be more than one cached plan if the query has been optimized for 
	both parallel and non-parallel query plans.  Output is sorted first by plan_handle, then 
	statement_start_offset which identifies the statement's starting position within the batch.

	Data is collected every 15 minutes. It is useful for seeing the execution count change to 
	quantify how much work was done as well as to see the changes in average logical reads since 
	that will often show problems with bad query plans (same query results in the output, but 
	many more logical reads done to get there if a scan is chosen instead of a seek, etc).
	
*/
 
	select
		 MyTimeStamp
		,statement_start_offset
		,AvgLogicalReads
		,execution_count
		,LastExecutionTime
		,CreationTime  -- when the statement was last cached
	from 
		expedba.dbo.SprocStats with(nolock)
	where	
		ObjectName = 'RatePlanAvailabilityLst#45'
	and
		DBName = 'LodgingInventoryMaster12'
	order by 
		 plan_handle
		,statement_start_offset
		,MyTimeStamp
