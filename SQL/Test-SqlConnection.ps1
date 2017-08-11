[CmdletBinding()]
param (
    [string]$HostName,
    [int]$Port = "",
    [string]$InstanceName = "",
    [string]$ConnectionString = "",
    [string]$ProviderName = "SqlClient",
    [switch]$TestSqlServerServiceStatus,
    [switch]$TestHost,
    [switch]$TestPort,
    [switch]$TestSqlServerBrowser,
    [switch]$TestConnectionString
 )

Set-Strictmode -version 2.0;
$ExitCode = 0;

# SqlConnectionTest.ps1
# Version 0.01.00
#
#
# Purpose: Utility script to test SQL Server network connectivity and connection strings independent of application code.  This facilitates troubleshooting client connection problems.
#          even if tools like SQL Server Management Studio and TELNET are not available on the client machine.
#
#
# Usage:
#
#    PowerShell SqlConnectionTest.ps1 [-HostName <host-name>] [-Port <Port-number>] [-InstanceName <instance-name>] [-ConnectionString <connection-string>] [-ProviderName <provider-name>] [-TestHost] [-TestPort] [-TestSqlServerBrowser] [-TestConnectionString] [-TestSqlServerServiceStatus]
#
#
#    Parameters:
#
#        -TestHost (optional, default false): Perform host TCP/IP connectivity checks.  HostName must be supplied.  Test TCP/IP connectivty by performing the following actions:
#            1) resolve the specified HostName or IP address using GetHostEntry to validate the host name or IP address is valid
#            2) list IP address(es) returned by GetHostEntry (if Verbose is specified)
#            3) ping using the specified HostName or IP address to test ICMP connectivity
#
#        -TestPort (optional, default false): Perform a TCP socket connection test.  HostName must be supplied.  TCP socket connectivity is tested by performing the following actions:
#            1) if Port is specified, attempt a TCP socket connection to the specified Port on HostName
#            2) if Port is not specified and InstanceName is specified, retrive port for specified InstanceName using a SQL Server Brower query, and then attempt a TCP socket connection to the returned named instance port on HostName
#            3) if neither Port nor InstanceName is specified, attempt a TCP socket connection to the default port 1433 on HostName
#
#        -TestSqlServerBrowser (optional, default false):  Perform a SQL Server Browser service query.  HostName must be specified.  Query SQL Server Browser service to retrieve information for named instances by performing the following actions:
#            1) if InstanceName is specified, get named instance information for specified instance by querying the SQL Browser service on UDP port 1434 of the specified HostName
#            2) if InstanceName is not specified, get information for all named instances by querying the SQL Browser service on UDP port 1434 of the specified HostName
#
#        -TestSqlServerServiceStatus (optional, default false): Query status of SQL Server service on specified HostName to verify services is Running. The queried service name is "MSSQLSERVER" (default instance) if InstanceName is not specified, or "MSSQL$<InstanceName>" when InstanceName is specified.
#            This test requires appropriate permissions to view SQL Server services.
#
#        -TestConnectionString (optional, default false):  Perform a connection string test.  Test SQL Server connection and query by performing the following actions:
#            1) Open a connection to SQL Server using the specified connection string and provider.  The connection will be made using either SqlClient, ODBC or OLEDB according to the ProviderName specification.
#               Note that connection string keywords vary by provider.  See usage examples for sample connection strings.
#            2) Execute query "SELECT @@SERVERNAME;" and display result
#            3) Close the connection
#
#        -HostName (optional, no default): Required for all tests except TestConectionString.  Value may be either host name or IP address.
#
#        -Port (optional, no default): Required for TestPort, unless InstanceName is specified (which isses port returned by SQL Server Browser).
#
#        -InstanceName (optional, no default): Used in the following tests:
#            1) TestSqlServerBrowser to return information for a specific named instance
#            2) TestPort to determine named instance port number when Port parameter is not specified
#
#        -ConnectionString (optional, no default): Required for TestConnectionString.
#
#        -ProviderName (optional, default "SqlClient"): Name of provider associated with ConnectionString.  Used only when ConnectionString is specified.  Valid values are SqlClient, ODBC, or OLEDB.
#
#        -Verbose (optional, default false): Include informational messages for each test.
#
#
#    Usage Examples:
#
#        Resolve host name, list IP address(es), and ping host:
#            Powershell -File .\SqlConnectionTest.ps1 -HostName someserver -verbose
#
#        Resolve IP address, list IP address(es), and ping host:
#            Powershell -File .\SqlConnectionTest.ps1 -HostName 10.11.12.13 -verbose
#
#        Resolve host name, list IP address(es), ping host, and verify Port connectivity to default 1433 Port:
#            Powershell -File .\SqlConnectionTest.ps1 -TestHost -TestPort -HostName someserver -Port 1433 -verbose
#
#        Resolve host name, list IP address(es), ping host, list named instance information, and verify Port connectivity to named instance Port:
#            Powershell -File .\SqlConnectionTest.ps1 -HostName someserver -InstanceName SQLEXPRESS -verbose
#
#        Resolve host name, list IP address(es), ping host, and get default instance SQL Server service status:
#            Powershell -File .\SqlConnectionTest.ps1 -HostName someserver -GetSqlServerServiceStatus -verbose
#
#        Resolve host name, list IP address(es), ping host, list named instance information, verify Port connectivity to named instance Port, and get named instance SQL Server service status:
#            Powershell -File .\SqlConnectionTest.ps1 -HostName someserver -InstanceName SQLEXPRESS -GetSqlServerServiceStatus -verbose
#
#        Test SqlClient connection to default database with Windows authentication:
#            Powershell -File .\SqlConnectionTest.ps1 -ConnectionString "Data Source=someserver;Integrated Security=SSPI" -verbose
#
#        Test SqlClient connection to specific database with Windows authentication:
#            Powershell -File .\SqlConnectionTest.ps1 -ConnectionString "Data Source=someserver;Integrated Security=SSPI;Initial Catalog=MyDatabase" -verbose
#
#        Test SqlClient connection to specific database with SQL authentication:
#            Powershell -File .\SqlConnectionTest.ps1 -ConnectionString "Data Source=someserver;User Id=MyLogin;Password=MyLoginP@assw0rd;Initial Catalog=MyDatabase" -verbose
#
#        Test ODBC connection string using legacy WDAC SQL Server ODBC driver:
#            Powershell -File .\SqlConnectionTest.ps1 -ProviderName ODBC -ConnectionString "Driver={SQL Server};Server=someserver;Trusted_Connection=Yes" -verbose
#
#        Test ODBC connection string using SQL Server 2005 Native Client ODBC driver:
#            Powershell -File .\SqlConnectionTest.ps1 -ProviderName ODBC -ConnectionString "Driver={SQL Server Native Client};Server=someserver;Trusted_Connection=Yes" -verbose
#
#        Test ODBC connection string using SQL Server 2008 Native Client ODBC driver:
#            Powershell -File .\SqlConnectionTest.ps1 -ProviderName ODBC -ConnectionString "Driver={SQL Server Native Client 10.0};Server=someserver;Trusted_Connection=Yes" -verbose
#
#        Test ODBC connection string using SQL Server 2012 Native Client ODBC driver:
#            Powershell -File .\SqlConnectionTest.ps1 -ProviderName ODBC -ConnectionString "Driver={SQL Server Native Client 11.0};Server=someserver;Trusted_Connection=Yes" -verbose
#
#        Test ODBC connection string using SQL Server ODBC Driver 11:
#            Powershell -File .\SqlConnectionTest.ps1 -ProviderName ODBC -ConnectionString "Driver={ODBC Driver 11 for SQL Server};Server=someserver;Uid=MyLogin;Pwd=MyLoginP@assw0rd" -verbose
#
#        Test ODBC connection string using a DSN with Windows authentication:
#            Powershell -File .\SqlConnectionTest.ps1 -ProviderName ODBC -ConnectionString "DSN=SomeServerODBCDataSourceName" -verbose
#
#        Test ODBC connection string using a DSN with SQL authentication:
#            Powershell -File .\SqlConnectionTest.ps1 -ProviderName ODBC -ConnectionString "DSN=SomeServerODBCDataSourceName;Uid=MyLogin;Pwd=MyLoginP@assw0rd" -verbose
#
#        Test OLE DB connection string using legacy SQLOLEDB provider:
#            Powershell -File .\SqlConnectionTest.ps1 -ProviderName OLEDB -ConnectionString "Provider=SQLOLEDB;Data Source=someserver;Integrated Security=SSPI" -verbose
#
#        Test OLE DB connection string using SQL Server 2005 Native client provider:
#            Powershell -File .\SqlConnectionTest.ps1 -ProviderName OLEDB -ConnectionString "Provider=SQLNCLI.1;Data Source=someserver;Integrated Security=SSPI" -verbose
#
#        Test OLE DB connection string using SQL Server 2008 Native client provider:
#            Powershell -File .\SqlConnectionTest.ps1 -ProviderName OLEDB -ConnectionString "Provider=SQLNCLI10.1;Data Source=someserver;Integrated Security=SSPI" -verbose
#
#        Test OLE DB connection string using SQL Server 2012 Native client provider:
#            Powershell -File .\SqlConnectionTest.ps1 -ProviderName OLEDB -ConnectionString "Provider=SQLNCLI11.1;Data Source=someserver;Integrated Security=SSPI" -verbose

Function ValidateParameters{

    if(-not $TestSqlServerServiceStatus -and -not $TestHost -and -not $TestPort -and -not $TestSqlServerBrowser -and -not $TestConnectionString)
    {
        # at least one action must be specified to do anything useful
        WriteErrorMessage "At least one test action must be specified";
        WriteInfoMessage "Usage: PowerShell SqlConnectionTest.ps1 [-HostName <host-name>] [-Port <Port-number>] [-InstanceName <instance-name>] [-ConnectionString <connection-string>] [-ProviderName <provider-name>] [-TestHost] [-TestPort] [-TestSqlServerBrowser] [-TestConnectionString] [-TestSqlServerServiceStatus]";
        $ExitCode = 1;
        return $false;
    }

    if($TestHost -and -not $HostName)
    {
        WriteErrorMessage "HostName must be provided when TestHost is specified.";
        $ExitCode = 1;
        return $false;
    }

    if($TestPort -and -not $HostName)
    {
        WriteErrorMessage "HostName must be provided when TestPort is specified.";
        $ExitCode = 1;
        return $false;
    }


    if($TestSqlServerBrowser -and -not $HostName)
    {
        WriteErrorMessage $("HostName must be provided when TestSqlServerBrowser is specified");
        $ExitCode = 1;
        return $false;
    }

    if($TestSqlServerServiceStatus -and -not $HostName)
    {
        WriteErrorMessage $("HostName must be provided when TestSqlServerServiceStatus is specified");
        $ExitCode = 1;
        return $false;
    }

    if($TestConnectionString -and -not $ConnectionString)
    {
        WriteErrorMessage "ConnectionString must be provided when TestConnectionString is specified";
        $ExitCode = 1;
        return $false;
    }

    if($TestConnectionString -and -not $ProviderName -in "SqlClient", "ODBC", "OLEDB")
    {
        WriteErrorMessage "Unrecognized ProviderName specified.  Provider must be SqlClient, ODBC, or OLEDB.";
        $ExitCode = 1;
        return $false;
    }

    return $true;

}

# resolve host name or IP address
Function ResolveHost($HostName){
    WriteInfoMessage ("Resolving host $HostName ...");
    try
    {
        $hostEntry = [System.Net.Dns]::GetHostEntry($HostName);
        WriteInfoMessage $("Host $HostName resolved to " + $hostEntry.HostName);
        WriteInfoMessage "IP address(es):";
        foreach($ip in $hostEntry.AddressList)
        {
            WriteInfoMessage $("    $ip");
        }
        WriteSuccessMessage "ResolveHost: SUCCESS";
    }
    catch [Exception]
    {
        WriteErrorMessage $("ResolveHost FAILED: " + $_.Exception.Message);
        $ExitCode = 1;
    }
}

# ping host to verify network connectivity (assuming ICMP is enabled)
Function PingHost($HostName){
    WriteInfoMessage ("Pinging host $HostName ...");
    try
    {
        $ping = new-object Net.NetworkInformation.Ping;
        $pingResult = $ping.Send($HostName);
        if($pingResult.Status -eq [System.Net.NetworkInformation.IPStatus]::Success)
        {
            WriteInfoMessage $("Ping status: " + $pingResult.Status);
            WriteSuccessMessage "Ping: SUCCESS";
        }
        else
        {
            WriteErrorMessage $("Ping status: " + $pingResult.Status);
            $ExitCode = 1;
        }
    }
    catch [Exception]
    {
        WriteErrorMessage $("PingHost FAILED: " + $_.Exception.Message);
        $ExitCode = 1;
    }
}

# establish socket connection to host Port to verify Port connectivity
Function TestTcpPort($HostName, $Port)
{

    WriteInfoMessage ("Testing connectivity to Port $Port ...");
    try
    {
        $tcpClient = new-object Net.Sockets.TcpClient;
        $tcpClient.Connect($HostName, $Port);
        WriteInfoMessage $("Host " + $HostName + " listening on TCP Port " + $Port);
        WriteSuccessMessage $("TestTcpPort: SUCCESS");
    }
    catch [Exception]
    {
        WriteErrorMessage $("TestTcpPort FAILED: " + $_.Exception.Message);
        $ExitCode = 1;
    }

}

# query SQL Server browser to get info for this named instance and test connectivity to named instance Port
Function TestSqlServerBrowerForInstanceName($HostName, $InstanceName)
{
    WriteInfoMessage ("Retrieving information for instance $InstanceName from SQL Server Browser service on host $HostName ...");
    try
    {
        $instanceNameBytes = [System.Text.Encoding]::ASCII.GetBytes($InstanceName);
        $udpClient = new-object Net.Sockets.UdpClient($HostName, 1434);
        $bufferLength = $InstanceNameBytes.Length + 2;
        $browserQueryMessage = new-object byte[] $bufferLength;
        $browserQueryMessage[0] = 4;
        $instanceNameBytes.CopyTo($browserQueryMessage, 1);
        $browserQueryMessage[$bufferLength-1] = 0;
        $bytesSent = $udpClient.Send($browserQueryMessage, $browserQueryMessage.Length);
        $udpClient.Client.ReceiveTimeout = 10000;
        $remoteEndPoint = new-object System.Net.IPEndPoint([System.Net.IPAddress]::Broadcast, 0);
        $browserResponse = $udpClient.Receive([ref]$remoteEndPoint);
        $payloadLength = $browserResponse.Length - 3;
        $browserResponseString = [System.Text.ASCIIEncoding]::ASCII.GetString($browserResponse, 3, $payloadLength);
        $elements = $browserResponseString.Split(";");
        $namedInstancePort = "";
        WriteInfoMessage "SQL Server Browser query results:";
        for($i = 0; $i -lt $elements.Length; $i = $i + 2)
        {
            if ($elements[$i] -ne "")
            {
                WriteInfoMessage $("    " + $elements[$i] + "=" + $elements[$i+1]);
                if($elements[$i] -eq "tcp")
                {
                    $namedInstancePort = $elements[$i+1];
                }
            }
        }
        WriteSuccessMessage $("TestSqlServerBrowerForInstanceName: SUCCESS");
    }
    catch [Exception]
    {
        WriteErrorMessage $("TestSqlServerBrowerForInstanceName FAILED: " + $_.Exception.Message);
        $ExitCode = 1;
    }

}

# query SQL Server browser to get info for all instances
Function TestSqlServerBrowerForAllInstances($HostName)
{
    WriteInfoMessage ("Retrieving information from SQL Server Browser service on host $HostName ...");
    try
    {
        $udpClient = new-object Net.Sockets.UdpClient($HostName, 1434);
        $bufferLength = 1;
        $browserQueryMessage = new-object byte[] 1;
        $browserQueryMessage[0] = 2;
        $bytesSent = $udpClient.Send($browserQueryMessage, $browserQueryMessage.Length);
        $udpClient.Client.ReceiveTimeout = 10000;
        $remoteEndPoint = new-object System.Net.IPEndPoint([System.Net.IPAddress]::Broadcast, 0);
        $browserResponse = $udpClient.Receive([ref]$remoteEndPoint);
        $payloadLength = $browserResponse.Length - 3;
        $browserResponseString = [System.Text.ASCIIEncoding]::ASCII.GetString($browserResponse, 3, $payloadLength);
        $elements = $browserResponseString.Split(";");
        WriteSuccessMessage "SQL Server Browser query results:";
        WriteSuccessMessage "";
        for($i = 0; $i -lt $elements.Length; $i = $i + 2)
        {
            if ($elements[$i] -ne "")
            {
                WriteSuccessMessage $("    " + $elements[$i] + "=" + $elements[$i+1]);
            }
            else
            {
                WriteSuccessMessage "";
                $i = $i - 1;
            }
        }
        WriteSuccessMessage $("TestSqlServerBrowerForAllInstances: SUCCESS");
    }
    catch [Exception]
    {
        WriteErrorMessage $("TestSqlServerBrowerForAllInstances FAILED: " + $_.Exception.Message);
        $ExitCode = 1;
    }

}

# query SQL Server browser to get info for this named instance and test connectivity to named instance Port
Function GetNamedInstancePort($HostName, $InstanceName)
{
    try
    {
        $instanceNameBytes = [System.Text.Encoding]::ASCII.GetBytes($InstanceName);
        $udpClient = new-object Net.Sockets.UdpClient($HostName, 1434);
        $bufferLength = $InstanceNameBytes.Length + 2;
        $browserQueryMessage = new-object byte[] $bufferLength;
        $browserQueryMessage[0] = 4;
        $instanceNameBytes.CopyTo($browserQueryMessage, 1);
        $browserQueryMessage[$bufferLength-1] = 0;
        $bytesSent = $udpClient.Send($browserQueryMessage, $browserQueryMessage.Length);
        $udpClient.Client.ReceiveTimeout = 10000;
        $remoteEndPoint = new-object System.Net.IPEndPoint([System.Net.IPAddress]::Broadcast, 0);
        $browserResponse = $udpClient.Receive([ref]$remoteEndPoint);
        $payloadLength = $browserResponse.Length - 3;
        $browserResponseString = [System.Text.ASCIIEncoding]::ASCII.GetString($browserResponse, 3, $payloadLength);
        $elements = $browserResponseString.Split(";");
        $namedInstancePort = "";

        for($i = 0; $i -lt $elements.Length; $i = $i + 2)
        {
            if ($elements[$i] -ne "")
            {
                if($elements[$i] -eq "tcp")
                {
                    $namedInstancePort = $elements[$i+1];
                    WriteSuccessMessage $("GetNamedInstancePort: SUCCESS");
                }
            }
        }
        return $namedInstancePort;

    }
    catch [Exception]
    {
        WriteErrorMessage $("GetNamedInstancePort FAILED: " + $_.Exception.Message);
        $ExitCode = 1;
    }
}

# establish socket connection to host Port to verify Port connectivity
Function TestSqlServerServiceStatus($HostName, $InstanceName)
{

    if($InstanceName -and $InstanceName -ne "MSSQLSERVER")
    {
        $ServiceName = "MSSQL$" + $InstanceName;
    }
    else
    {
        $ServiceName = "MSSQLSERVER";
    }
    WriteInfoMessage ("Retrieving service status for service $ServiceName on host $HostName...");
    try
    {
        $Service = Get-Service -Name $ServiceName -ComputerName $HostName;
        WriteInfoMessage $Service;
        if($Service.Status -eq "Running")
        {
            WriteSuccessMessage "TestSqlServerServiceStatus: SUCCESS";
        }
        else
        {
            WriteErrorMessage "TestSqlServerServiceStatus: FAILED";
        }
    }
    catch [Exception]
    {
        WriteErrorMessage $("TestSqlServerServiceStatus FAILED: " + $_.Exception.Message);
        $ExitCode = 1;
    }
}

# establish socket connection to host Port to verify Port connectivity
Function TestConnectionString($ProviderName, $ConnectionString)
{

    WriteInfoMessage "Testing $ProviderName connection using connection string $ConnectionString ...";
    try
    {
        [System.Data.IDbConnection]$connection = $null;
        [System.Data.IDbCommand]$command = $null;
        $query = "SELECT @@SERVERNAME;";
        switch($ProviderName)
        {
            "SqlClient" {
                $connection = new-object System.Data.SqlClient.SqlConnection($ConnectionString);
                $command = new-object System.Data.SqlClient.SqlCommand($query, $Connection); }
            "ODBC" { 
                $connection = new-object System.Data.Odbc.OdbcConnection($ConnectionString);
                $command = new-object System.Data.Odbc.OdbcCommand($query, $Connection); }
            "OLEDB" { 
                $connection = new-object System.Data.OleDb.OleDbConnection($ConnectionString);
                $command = new-object System.Data.OleDb.OleDbCommand($query, $Connection); }
            default {
                WriteErrorMessage "Unrecognized ProviderName specified.  Provider must be SqlClient, ODBC, or OLEDB)";
                $ExitCode = 1;
                return; }
        }
        $connection.Open();
        $result = $command.ExecuteScalar();
        WriteInfoMessage "SELECT @@SERVERNAME query result is $result";
        $connection.Close();
        WriteSuccessMessage $("TestConnectionString: SUCCESS");
    }
    catch [Exception]
    {
        WriteErrorMessage $("TestConnectionString FAILED: " + $_.Exception.Message);
        $ExitCode = 1;
    }
}

# write info message
Function WriteInfoMessage($message)
{
    Write-Verbose "$message";
}

# write success message
Function WriteSuccessMessage($message)
{
    Write-Host "$message" -foregroundcolor "green";
}

# write error message
Function WriteErrorMessage($message)
{
    Write-Host "$message" -foregroundcolor "red";
}

########
# main #
########

if(ValidateParameters)
{

    if($TestHost)
    {
        # resolve host/IP and ping
        ResolveHost $HostName;
        PingHost $HostName;
     }

    if ($TestPort -and $Port)
    {
        # test network connectivity to specified host and port
        TestTcpPort $HostName $Port;
    }

    if ($TestPort -and $InstanceName)
    {
        # test network connectivity to specified host and named instance port
        $namedInstancePort = GetNamedInstancePort $HostName $InstanceName;
        TestTcpPort $HostName $namedInstancePort;
    }

    if ($TestPort -and -not $InstanceName -and -not $Port)
    {
        # test network connectivity to specified host and default port 1433
        TestTcpPort $HostName 1433;
    }

    if($TestSqlServerBrowser -and $InstanceName)
    {
        # get instance information and test named instance Port when instance name is specified
        TestSqlServerBrowerForInstanceName $HostName $InstanceName;
    }

    if($TestSqlServerBrowser -and -not $InstanceName)
    {
        # get instance information and test named instance Port when instance name is specified
        TestSqlServerBrowerForAllInstances $HostName;
    }

    if($TestSqlServerServiceStatus)
    {
        # get status of SQL Server service when GetServiceStatus is specified
        TestSqlServerServiceStatus $HostName $InstanceName;
    }

    if($TestConnectionString)
    {
        # test SQL API connectivity using connection string when connection string is specified
        TestConnectionString $ProviderName $ConnectionString;
    }

}

Exit $ExitCode;
