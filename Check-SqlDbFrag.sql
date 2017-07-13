SELECT DISTINCT sch.name + '.' + OBJECT_NAME(stat.object_id), 
  ind.name, 
  CONVERT(int, stat.avg_fragmentation_in_percent) AS FragPCT
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,'LIMITED') stat
  JOIN sys.indexes ind ON stat.object_id=ind.object_id AND stat.index_id = ind.index_id
  JOIN sys.objects obj ON obj.object_id = stat.object_id
  JOIN sys.schemas sch ON obj.schema_id = sch.schema_id
WHERE ind.name IS NOT NULL AND
  stat.avg_fragmentation_in_percent > 10.0 AND
  ind.type > 0
ORDER BY CONVERT(int, stat.avg_fragmentation_in_percent) DESC
