-- Query to access perfmon data stored in MDW databases.  The joins are a little tricky.

SELECT [database_name]
      ,[resource_description]
      ,sum(wait_duration_ms)
  FROM [MDW].[snapshots].[active_sessions_and_requests] asr
  inner join
	core.snapshots_internal							csi with(nolock)  on csi.snapshot_id = asr.snapshot_id 
inner join		
	core.source_info_internal						csii with(nolock) on csii.source_id = csi.source_id
inner join 
	msdb.dbo.syscollector_collection_sets_internal  scsi with(nolock) on scsi.collection_set_uid = csii.collection_set_uid 
  where wait_type like 'pagelatch%'
  group by [database_name]
      ,[resource_description]
