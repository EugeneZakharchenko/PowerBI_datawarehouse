USE [PowerBI_datawarehouse]
GO
/****** Object:  StoredProcedure [dbo].[GetDatabaseSummary]    Script Date: 8/9/2023 9:51:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetDatabaseSummary]
AS
BEGIN
    -- Get number of records in each table
    SELECT 
        'Connecticut' AS TableName,
        COUNT(*) AS RecordCount
    FROM Connecticut
    UNION ALL
    SELECT 
        'EmployeeSampleData' AS TableName,
        COUNT(*) AS RecordCount
    FROM EmployeeSampleData
    UNION ALL
    SELECT 
        'National' AS TableName,
        COUNT(*) AS RecordCount
    FROM [National]
    UNION ALL
    SELECT 
        'NationalPrice' AS TableName,
        COUNT(*) AS RecordCount
    FROM NationalPrice;

    -- Get database size
    EXEC sp_spaceused;

    -- Get index usage
    SELECT 
        OBJECT_NAME(s.[object_id]) AS TableName,
        i.name AS IndexName,
        s.avg_fragmentation_in_percent
    FROM sys.dm_db_index_physical_stats (NULL, NULL, NULL, NULL, NULL) s
    INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id] AND s.index_id = i.index_id;

    -- Get query performance (you might need to customize this)
    SELECT
        r.database_id, -- Database ID associated with the query
        qs.total_elapsed_time, -- Total elapsed time of the query
        qs.total_logical_reads, -- Total logical reads by the query
        qs.total_logical_writes, -- Total logical writes by the query
        qs.execution_count, -- Number of times the query has been executed
        s.text AS QueryText -- Text of the query
    FROM sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) s
    CROSS APPLY sys.dm_exec_requests r
    WHERE r.plan_handle = qs.plan_handle; -- Join based on plan_handle

    SELECT * FROM DatabaseSummaryLog
END;
