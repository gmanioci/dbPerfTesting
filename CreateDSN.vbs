Const HKEY_LOCAL_MACHINE = &H80000002
Const HKEY_CURRENT_USER 	= &H80000001

strComputer = "." 
 
Set objReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & _ 
    strComputer & "\root\default:StdRegProv")
 
strKeyPath = "SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources"
strValueName = "perfmonVBS"
strValue = "SQL Server"
objReg.SetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue
 
strKeyPath = "SOFTWARE\ODBC\ODBC.INI\perfmonVBS"

objReg.CreateKey HKEY_LOCAL_MACHINE,strKeyPath

strKeyPath = "SOFTWARE\ODBC\ODBC.INI\perfmonVBS"

strValueName = "Database"
strValue = "EXPEDBA"
objReg.SetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue
 
strValueName = "Driver"
strValue = "C:\WINDOWS\System32\SQLSRV32.dll"
objReg.SetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue

strValueName = "Server"
strValue = WScript.Arguments(0) 
objReg.SetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue

strValueName = "Trusted_Connection"
strValue = "Yes"
objReg.SetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue



WScript.Arguments(0)