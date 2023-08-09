
exec dbadmin..sp_BlitzWho @ExpertMode=1, @ShowActualParameters = 1



EXEC dbadmin..sp_whoisactive @get_plans = 2
, @get_avg_time = 1 --parameter sniffing
,@show_system_spids = 1

-- top waits
EXEC dbadmin..sp_blitzfirst @outputtype = 'Top10'

-- top waits
EXEC dbadmin..sp_blitzfirst @outputtype = 'Top10', @SinceStartup = 1


EXEC dbadmin..sp_BlitzFirst @ExpertMode=1, @Seconds=60;
GO



-- SOS_SCHEDULER_YIELD
exec dbadmin..sp_BlitzCache  @ExpertMode = 1, @HideSummary=1, @sortOrder='cpu'
, @SkipAnalysis = 1sp_BlitzWho @ExpertMode=1, @ShowActualParameters = 1



EXEC dbadmin..sp_BlitzFirst 
  @ExpertMode = 1,
  @OutputDatabaseName = 'dbadmin', 
  @OutputSchemaName = 'dbo', 
  @OutputTableName = 'BlitzFirst',
  @OutputTableNameFileStats = 'BlitzFirst_FileStats',
  @OutputTableNamePerfmonStats = 'BlitzFirst_PerfmonStats',
  @OutputTableNameWaitStats = 'BlitzFirst_WaitStats',
  @OutputTableNameBlitzCache = 'BlitzCache',
  @OutputTableRetentionDays = 7,
  @OutputType = 'none'
