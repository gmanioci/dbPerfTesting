

  
-- FILTERED & GROUPED ACTIVE WAIT DATA 
-- OVER THS COURSE OF THE CURRENT DAY
	  
	DECLARE		@aDate DateTime
	SET			@aDate = getDate()
	  
	SELECT  
		   datepart(hh,MyTimeStamp) as 'Hour'  
		  ,datepart(mi,MyTimeStamp) as 'Minute'
		  ,wait_type
		  ,resource_description
		  ,substring([text],1,70)		as 'Text70'
		  ,sum([wait_duration_ms])	as 'SumWaitMS'
	      
	  FROM 
		   [EXPEDBA].[dbo].[active_waits] with(nolock)
	  where 
			-- TIME FILTER
			 mytimestamp > (  -- THIS RETURNS MIDNIGHT OF THE CURRENT DAY
								Select DateAdd(minute, 0, DateAdd(day, DateDiff(day, 0, @aDate), 0))
							  )
			
			-- TEXT FILTER
			--and text not like '%CREATE PROCEDURE sys.sp_MSget_repl_commands%'
			
			-- WAIT TYPE FILTER(S) - adjust as-needed
				-- BLOCKING
				and wait_type like 'LCK%'		-- lock wait only
	  		
  				-- CXPACKET
  				--and wait_type like 'CX%'
	  			
  				-- DISK PERFORMANCE
  				 and ((wait_type like 'PAGEIO%') OR (wait_type = 'WRITELOG'))
	  			
  				-- IGNORE THESE SAFELY
  				and wait_type NOT IN (   'CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE','SLEEP_TASK'
										,'SLEEP_SYSTEMTASK','SQLTRACE_BUFFER_FLUSH','WAITFOR', 'LOGMGR_QUEUE','CHECKPOINT_QUEUE'
										,'REQUEST_FOR_DEADLOCK_SEARCH','XE_TIMER_EVENT','BROKER_TO_FLUSH','BROKER_TASK_STOP','CLR_MANUAL_EVENT'
										,'CLR_AUTO_EVENT','DISPATCHER_QUEUE_SEMAPHORE', 'FT_IFTS_SCHEDULER_IDLE_WAIT'
										,'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP'
									 )
	  group by 
			   datepart(hh,MyTimeStamp)   
			  ,datepart(mi,MyTimeStamp)
			  ,wait_type
			  ,resource_description
			  ,substring([text],1,70)
	  order by 
				[hour]
			   ,[minute]
			   ,wait_type
