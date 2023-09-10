
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

  
sp_BlitzWho @ExpertMode=1, @ShowActualParameters = 1



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


exec dbadmin..sp_Blitz @OutputType = 'MARKDOWN', @CheckServerInfo = 1;

-- https://www.joshthecoder.com/2020/08/27/unusual-threadpool-waits.html

EXEC dbo.sp_PressureDetector @what_to_check = N'cpu';

---------------

--LCK% long running + low cpu = locking   Long Running With Low CPU
EXEC dbadmin..sp_BlitzCache  @ExpertMode = 1, @HideSummary=1, @sortOrder='duration'
-- resource semaphore
exec dbadmin..sp_BlitzCache  @ExpertMode = 1, @HideSummary=1, @sortOrder='memory grant'
-- SOS_SCHEDULER_YIELD
EXEC dbadmin..sp_BlitzCache  @ExpertMode = 1, @HideSummary=1, @sortOrder='cpu'
--, @SkipAnalysis = 1

-- PAGEIOLATCH  THREADPOOL (queries which do scans)
exec dbadmin..sp_BlitzCache  @ExpertMode = 1, @HideSummary=1, @sortOrder='reads'
--, @SkipAnalysis = 1

-- WRITELOG
exec dbadmin..sp_BlitzCache  @ExpertMode = 1, @HideSummary=1, @sortOrder='writes'
--most intencive / heavy
exec dbadmin..sp_BlitzCache  @ExpertMode = 1, @HideSummary=1, @sortOrder='executions'
--recent compilation
exec dbadmin..sp_BlitzCache @SortOrder = 'recent compilations'

--spills
exec dbadmin..sp_BlitzCache  @ExpertMode = 1, @HideSummary=1, @sortOrder='spills'

