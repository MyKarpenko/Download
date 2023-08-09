--/*


USE master
IF NOT EXISTS(select * from sys.databases where name='dbadmin')
BEGIN 
	CREATE DATABASE dbadmin
	ALTER DATABASE [dbadmin] SET RECOVERY SIMPLE WITH NO_WAIT


	--ALTER DATABASE [dbadmin] MODIFY FILE ( NAME = N'dbadmin', SIZE = 65536KB )
	--ALTER DATABASE [dbadmin] MODIFY FILE ( NAME = N'dbadmin_log', SIZE = 524288KB , FILEGROWTH = 524288KB )

	PRINT 'The DB has been created successfully.'
END
ELSE PRINT 'The DB already exists.'

GO
------------------------------
USE [dbadmin]
GO
ALTER AUTHORIZATION ON DATABASE::[dbadmin] TO [sa]
GO



USE [dbadmin]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[quick_debug](
	[LogDate] [datetime] NULL,
	[session_id] [smallint] NOT NULL,
	[sql_text] [nvarchar](max) NULL,
	[login_name] [nvarchar](128) NOT NULL,
	[wait_info] [nvarchar](4000) NULL,
	[CPU] [int] NULL,
	[tempdb_allocations] [bigint] NULL,
	[tempdb_current] [bigint] NULL,
	[blocking_session_id] [smallint] NULL,
	[reads] [bigint] NULL,
	[writes] [bigint] NULL,
	[physical_reads] [bigint] NULL,
	[query_plan] [xml] NULL,
	[used_memory] [bigint] NOT NULL,
	[status] [varchar](30) NOT NULL,
	[open_tran_count] [smallint] NULL,
	[percent_complete] [real] NULL,
	[host_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[program_name] [nvarchar](128) NULL,
	[start_time] [datetime] NOT NULL,
	[login_time] [datetime] NULL,
	[request_id] [int] NULL,
	[collection_time] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


USE [dbadmin]
GO


CREATE NONCLUSTERED INDEX [IX_quick_debug_LogDate] ON [dbo].[quick_debug]
(
	[LogDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

--*/



USE [msdb]
GO

/****** Object:  Job [SQL_Maint: sp_whoisactive]    Script Date: 10/1/2018 9:54:44 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10/1/2018 9:54:44 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SQL_Maint: sp_whoisactive', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'SELECT * FROM [dbadmin].[dbo].[quick_debug]
order by LogDate desc', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [step 1]    Script Date: 10/1/2018 9:54:45 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'step 1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'

drop table tempdb.dbo.quick_debug
DECLARE @s VARCHAR(MAX)

EXEC dbadmin.dbo.sp_WhoIsActive @get_plans = 2,
    @format_output = 0, 
    @return_schema = 1, 
    @schema = @s OUTPUT

SET @s = REPLACE(@s, ''<table_name>'', ''tempdb.dbo.quick_debug'')

EXEC(@s) 
GO

EXEC dbadmin.dbo.sp_WhoIsActive @get_plans = 2,
    @format_output = 0, 
    @destination_table = ''tempdb.dbo.quick_debug''

--WAITFOR DELAY ''00:00:05'' 
--GO 60
INSERT INTO [dbadmin].[dbo].[quick_debug]
select GETDATE() LogDate, * from tempdb.dbo.quick_debug

--SELECT * FROM [dbadmin].[dbo].[quick_debug]

DELETE FROM [dbadmin].[dbo].[quick_debug] WHERE LogDate < GETDATE()-3
--CREATE INDEX IX_quick_debug_LogDa

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every 10 sec', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181021, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959,
		@schedule_uid=N'4c78e170-7442-49f5-9d98-da19854d82fe'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO









--USE [msdb]
--GO

--/****** Object:  Job [SQL_Maint: sp_whoisactive]    Script Date: 6/11/2018 12:10:52 PM ******/
--BEGIN TRANSACTION
--DECLARE @ReturnCode INT
--SELECT @ReturnCode = 0
--/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 6/11/2018 12:10:52 PM ******/
--IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
--BEGIN
--EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

--END

--DECLARE @jobId BINARY(16)
--EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SQL_Maint: sp_whoisactive', 
--		@enabled=1, 
--		@notify_level_eventlog=0, 
--		@notify_level_email=0, 
--		@notify_level_netsend=0, 
--		@notify_level_page=0, 
--		@delete_level=0, 
--		@description=N'SELECT * FROM dbadmin.[dbo].[quick_debug]
--order by LogDate desc', 
--		@category_name=N'[Uncategorized (Local)]', 
--		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--/****** Object:  Step [step 1]    Script Date: 6/11/2018 12:10:52 PM ******/
--EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'step 1', 
--		@step_id=1, 
--		@cmdexec_success_code=0, 
--		@on_success_action=1, 
--		@on_success_step_id=0, 
--		@on_fail_action=2, 
--		@on_fail_step_id=0, 
--		@retry_attempts=0, 
--		@retry_interval=0, 
--		@os_run_priority=0, @subsystem=N'TSQL', 
--		@command=N'
--drop table tempdb.dbo.quick_debug
--DECLARE @s VARCHAR(MAX)

--EXEC sp_WhoIsActive @get_plans = 2,
--    @format_output = 0, 
--    @return_schema = 1, 
--    @schema = @s OUTPUT

--SET @s = REPLACE(@s, ''<table_name>'', ''tempdb.dbo.quick_debug'')

--EXEC(@s) 
--GO

--EXEC sp_WhoIsActive @get_plans = 2,
--    @format_output = 0, 
--    @destination_table = ''tempdb.dbo.quick_debug''

----WAITFOR DELAY ''00:00:05'' 
----GO 60
--INSERT INTO dbadmin.[dbo].[quick_debug]
--select GETDATE() LogDate, * from tempdb.dbo.quick_debug

----SELECT * FROM dbadmin.[dbo].[quick_debug]

--DELETE FROM dbadmin.[dbo].[quick_debug] WHERE LogDate < GETDATE()-14
----CREATE INDEX IX_quick_debug_LogDate ON dbadmin.[dbo].[quick_debug] (LogDate)', 
--		@database_name=N'master', 
--		@flags=0
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every 5 min', 
--		@enabled=1, 
--		@freq_type=4, 
--		@freq_interval=1, 
--		@freq_subday_type=4, 
--		@freq_subday_interval=5, 
--		@freq_relative_interval=0, 
--		@freq_recurrence_factor=0, 
--		@active_start_date=20180411, 
--		@active_end_date=99991231, 
--		@active_start_time=0, 
--		@active_end_time=235959, 
--		@schedule_uid=N'4c78e170-7442-49f5-9d98-da19854d82fe'
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--COMMIT TRANSACTION
--GOTO EndSave
--QuitWithRollback:
--    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
--EndSave:
--GO


