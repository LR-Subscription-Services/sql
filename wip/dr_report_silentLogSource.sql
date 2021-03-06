SELECT ms.[MsgSourceID]
      ,msmld.[MaxLogDate]
      ,ms.[Name] AS 'LogSourceName'
      ,mst.[FullName] as 'LogSourceType'
      ,CASE WHEN ms.[MPEMode] = 1 THEN 'Enabled' ELSE 'Disabled' END AS 'MPEMode'
      ,CASE WHEN ms.[RecordStatus] = 1 THEN 'Active' ELSE 'Retired' END AS 'RecordStatus'
  FROM [LogRhythmEMDB].[dbo].[MsgSource] ms
	LEFT JOIN [LogRhythmEMDB].[dbo].[MsgSourceMaxLogDate] msmld ON ms.[MsgSourceID] = msmld.MsgSourceID
	LEFT JOIN [LogRhythmEMDB].[dbo].[MsgSourceType] mst ON ms.[MsgSourceTypeID] = mst.[MsgSourceTypeID]
  WHERE 
	ms.[RecordStatus] = 1  -- Filters out retired records
	AND DATEDIFF(dd,msmld.[MaxLogDate],GETUTCDATE()) > 14  -- Looks for logs that have not checked in in this number of days
	AND msmld.[MaxLogDate] > '2000-01-01 00:00:00.000'  -- Filters out system log sources with ancient MaxLogDate entries
  ORDER BY msmld.[MaxLogDate] ASC