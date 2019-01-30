-- returns 'YYYYMMDD' such as '20190130' for Jan 30, 2019
select STR(YEAR(GETDATE()))+''+(REPLACE( STR(MONTH(GETDATE()),2),' ','0'))+''+'01'
