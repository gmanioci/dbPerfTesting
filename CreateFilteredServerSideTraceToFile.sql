
-- Create a Server-Side Trace for Events Greater Than Specificed Filter (in MS)

-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
set @maxfilesize = 1024  --UPDATE HERE 

-- Output file:  the .trc extension
-- will be appended to the filename automatically. If you are writing from
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share

-- UPDATE HERE
exec @rc = sp_trace_create @TraceID output, 0, N'D:\TempDB1\TraceOutput', @maxfilesize, NULL 


if (@rc != 0) goto error

-- Client side File and Table cannot be scripted

-- Set the events
declare @on bit
set @on = 1

-- Output definition
-- Ref:  https://msdn.microsoft.com/en-us/library/ms186265.aspx 

-- EVENTS:  10 - RPC:Completed

-- excluded:
    --exec sp_trace_setevent @TraceID, 10, 10, @on  -- ApplicationName
    --exec sp_trace_setevent @TraceID, 10, 11, @on  -- LoginName
    --exec sp_trace_setevent @TraceID, 10, 14, @on  -- StartTime
    --exec sp_trace_setevent @TraceID, 10, 2, @on   -- BinaryData
    --exec sp_trace_setevent @TraceID, 10, 25, @on  -- IntegerData
    --exec sp_trace_setevent @TraceID, 10, 26, @on  -- ServerName
    --exec sp_trace_setevent @TraceID, 10, 3, @on   -- DatabaseID
    --exec sp_trace_setevent @TraceID, 10, 34, @on  -- ObjectName 
    --exec sp_trace_setevent @TraceID, 10, 4, @on   -- TransactionID
    --exec sp_trace_setevent @TraceID, 10, 41, @on  -- LoginSID
    --exec sp_trace_setevent @TraceID, 10, 49, @on  -- RequestID
    --exec sp_trace_setevent @TraceID, 10, 50, @on  -- XactSequence
    --exec sp_trace_setevent @TraceID, 10, 6, @on   -- NTUserName
    --exec sp_trace_setevent @TraceID, 10, 60, @on  -- IsSystem
    --exec sp_trace_setevent @TraceID, 10, 64, @on  -- SessionLoginName
    --exec sp_trace_setevent @TraceID, 10, 66, @on  -- ?
    --exec sp_trace_setevent @TraceID, 10, 9, @on   -- ClientProcessID
    --exec sp_trace_setevent @TraceID, 10, 7, @on   -- NTDomainName

-- included:
    exec sp_trace_setevent @TraceID, 10, 1, @on   -- TextData
    exec sp_trace_setevent @TraceID, 10, 12, @on  -- SPID
    exec sp_trace_setevent @TraceID, 10, 13, @on  -- Duration
    exec sp_trace_setevent @TraceID, 10, 15, @on  -- EndTime
    exec sp_trace_setevent @TraceID, 10, 16, @on  -- Reads
    exec sp_trace_setevent @TraceID, 10, 17, @on  -- Writes
    exec sp_trace_setevent @TraceID, 10, 18, @on  -- CPU
    exec sp_trace_setevent @TraceID, 10, 31, @on  -- Error
    exec sp_trace_setevent @TraceID, 10, 35, @on  -- DatabaseName
    exec sp_trace_setevent @TraceID, 10, 48, @on  -- Rowcounts
    exec sp_trace_setevent @TraceID, 10, 51, @on  -- EventSequence
    exec sp_trace_setevent @TraceID, 10, 8, @on   -- HostName

-- EVENTS:  12 - SQL:BatchCompleted
-- excluded:
	  --exec sp_trace_setevent @TraceID, 12, 50, @on  -- XactSequence
    --exec sp_trace_setevent @TraceID, 12, 4, @on   -- TransactionID

-- included:
    exec sp_trace_setevent @TraceID, 12, 15, @on  -- EndTime
    exec sp_trace_setevent @TraceID, 12, 31, @on  -- Error
    exec sp_trace_setevent @TraceID, 12, 8, @on   -- HostName
    exec sp_trace_setevent @TraceID, 12, 16, @on  -- Reads
    exec sp_trace_setevent @TraceID, 12, 48, @on  -- Rowcounts
    exec sp_trace_setevent @TraceID, 12, 1, @on   -- TextData
    exec sp_trace_setevent @TraceID, 12, 17, @on  -- Writes
    exec sp_trace_setevent @TraceID, 12, 18, @on  -- CPU
    exec sp_trace_setevent @TraceID, 12, 35, @on  -- DatabaseName
    exec sp_trace_setevent @TraceID, 12, 51, @on  -- EventSequence
    exec sp_trace_setevent @TraceID, 12, 12, @on  -- SPID
    exec sp_trace_setevent @TraceID, 12, 13, @on  -- Duration


-- Filters:
declare @intfilter int
declare @bigintfilter bigint

exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Server Profiler - 86fb9417-482e-4f8e-9424-8d7614871389'

-- UPDATE HERE (Duration filter in MS)
set @bigintfilter = 17000

exec sp_trace_setfilter @TraceID, 13, 0, 4, @bigintfilter

-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID
goto finish

error: 
select ErrorCode=@rc

finish: 
go

/* How to stop your server-side trace:
   The trace will stop by itself once the file size specified at the top is reached.  To 
   stop it before then:
   
   -- Show all server side traces
	SELECT * FROM ::fn_trace_getinfo(null)

  -- Stop the trace by specifying its trace id
	EXEC sp_trace_setstatus @traceid = 2, @status = 0
 
  -- Close the trace and delete the trace information 
	EXEC sp_trace_setstatus @traceid = 2, @status = 2
*/
