
-- Mediator: Trend By Hour
SELECT
	a.[MediatorID]
	,b.[Name] as 'Mediator'
	,[StatDate] as 'DateTimeUtc'
	,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
	,[CountLogs]
	,[CountLogs]/3600 as 'RateLogs'
	,[CountProcessedLogs]
	,[CountProcessedLogs]/3600 as 'RateProcessedLogs'
	,[CountIdentifiedLogs]
	,[CountIdentifiedLogs]/3600 as 'RateIdentifiedLogs'
	,[CountArchivedLogs]
	,[CountArchivedLogs]/3600 as 'RateArchivedLogs'
	,[CountOnlineLogs]
	,[CountOnlineLogs]/3600 as 'RateOnlineLogs'
	,[CountEvents]
	,[CountEvents]/3600 as 'RateEvents'
	,[CountLogMart]
	,[CountLogMart]/3600 as 'RateLogMart'
FROM [LogRhythm_LogMart].[dbo].[StatsMediatorCountsHour] a
	LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] b on a.MediatorID = b.MediatorID
	INNER JOIN ( -- To run this query against a larger dataset, comment out this entire INNER JOIN and uncomment the WHERE clause below
			SELECT TOP 1
				CONVERT(DATE,(DATEADD(HH,-7,[StatDate]))) as 'PeakDay'
				,SUM(CAST([CountProcessedLogs] AS BIGINT))/(3600*24) as 'MPS_PeakDay'
			FROM
				[LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
			WHERE
				[StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
			GROUP BY
				CONVERT(DATE,(DATEADD(HH,-7,[StatDate])))
			ORDER BY
				MPS_PeakDay DESC
			) peak ON CONVERT(DATE,(DATEADD(HH,-7,a.[StatDate])))  = peak.[PeakDay]
-- WHERE [StatDate] > DATEADD(DD,-15,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
ORDER BY 
	[MediatorID] ASC
	,[StatDate] DESC
;