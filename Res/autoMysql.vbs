Dim WshShell
Set WshShell=Wscript.CreateObject("Wscript.Shell")
WshShell.run("""D:\Program Files (x86)\MySQL\MySQL Server 5.5\bin\mysql.exe"" -uroot -p123456")       
Wscript.Sleep 1000
WshShell.SendKeys "source sg_orderDB.sql;"
WshShell.SendKeys "{ENTER}"
Wscript.Sleep 1000
WshShell.SendKeys "source sg_serverDB.sql;"
WshShell.SendKeys "{ENTER}"
Wscript.Sleep 3000