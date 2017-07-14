'****************************************************************
' Filename..: db_crawler.vbs
' Author....: David M. Stein
' Date......: 10/26/2012
' Purpose...: enumerate databases, and tables/columns (for each)
' SQL.......: see DSN
'****************************************************************

Const schema_name = "dbo"
Const dbserver = "sqlserver1"

'----------------------------------------------------------------
 
dblist = "db1,db2,db3"

For each db in Split(dbList, ",")
  EnumDatabases db
Next

Public conn

'----------------------------------------------------------------
' function: retrieve table names
'----------------------------------------------------------------

Sub EnumDatabases(strName)
	Dim dsn, cmd, rs
	
	wscript.echo "database: " & strName
	
	dsn = "DRIVER=SQL Server;SERVER=" & dbserver & ";database=" & strName & ";Trusted_Connection=true;"

	On Error Resume Next 
	Set conn = CreateObject("ADODB.Connection")
	conn.ConnectionTimeOut = 5
	conn.Open dsn
	If err.Number <> 0 Then
		wscript.echo "error: database connection failed (" & err.Number & ")"
		Exit Sub
	End If
	
	Set cmd  = CreateObject("ADODB.Command")
	Set rs   = CreateObject("ADODB.Recordset")

	query = "SELECT table_name, table_type " & _
		"FROM information_schema.tables " & _
		"WHERE table_schema='" & schema_name & "' " & _
		"AND table_type='BASE TABLE' ORDER BY table_name"

	rs.CursorLocation = adUseClient
	rs.CursorType = adOpenStatic
	rs.LockType = adLockReadOnly

	Set cmd.ActiveConnection = conn

	cmd.CommandType = adCmdText
	cmd.CommandText = query
	rs.Open cmd

	If Not(rs.BOF And rs.EOF) Then
		Do Until rs.EOF
			tableName = rs.Fields("table_name").value
			If InStr(tableName, "canada") > 0 Then
				wscript.echo "table: " & tableName
				TableDump conn, tableName, 10
			'Else
			'	wscript.echo "table: " & tableName
			End If
			rs.MoveNext
		Loop
	End If

	rs.Close
	conn.Close
	Set rs = Nothing
	Set cmd = Nothing
	Set conn = Nothing
 End Sub
 
 Sub TableDump(cn, tname, recNum)
 	Dim query, cmd, rs, i
	wscript.echo vbTab & "querying table: " & tname
 	
 	If recNum = 0 Then
 		query = "SELECT * FROM dbo." & tname
 	Else
		query = "SELECT TOP (" & recNum & ") * FROM dbo." & tname
 	End If

	wscript.echo vbTab & "query: " & query
 	
	Set cmd  = CreateObject("ADODB.Command")
	Set rs   = CreateObject("ADODB.Recordset")
	 
	rs.CursorLocation = adUseClient
	rs.CursorType = adOpenStatic
	rs.LockType = adLockReadOnly
	 
	Set cmd.ActiveConnection = cn
	 
	cmd.CommandType = adCmdText
	cmd.CommandText = query
	rs.Open cmd
	 
	If Not(rs.BOF And rs.EOF) Then
		Do Until rs.EOF
			For i = 0 to rs.Fields.Count - 1
				wscript.echo vbTab & rs.Fields(i).Name & " = " & rs.Fields(i).Value
			Next
			rs.MoveNext
		Loop
	Else
		wscript.echo "error: no records found"
	End If

	rs.Close
	Set rs = Nothing
	Set cmd = Nothing
	 
 End Sub
