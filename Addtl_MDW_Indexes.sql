USE [MDW]
GO

-- INDEX 1:
	CREATE NONCLUSTERED INDEX [ncliquery_stats_sql_handle] ON [snapshots].[query_stats] 
	(
		[sql_handle] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	GO

-- INDEX 2:
	CREATE NONCLUSTERED INDEX [snapshort_querystats_sql_handle_covering] ON [snapshots].[query_stats] 
	(
		[sql_handle] ASC,
		[statement_start_offset] ASC,
		[statement_end_offset] ASC,
		[plan_generation_num] ASC,
		[plan_handle] ASC,
		[creation_time] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	GO

-- INDEX 3:
	CREATE INDEX missing_index_311_310 ON [MDW].[snapshots].[notable_query_plan] ([statement_start_offset], [statement_end_offset], [creation_time],[sql_handle], [plan_handle])

-- INDEX 4:
	CREATE NONCLUSTERED INDEX [missing_index_384_383] ON [core].[snapshots_internal] 
	(
		[source_id] ASC
	)
	INCLUDE ( [snapshot_id],
	[snapshot_time_id]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	GO

-- Also, enable read-committed snapshot isolation
	alter database MDW set read_committed_snapshot on;
