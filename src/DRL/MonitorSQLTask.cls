Class DRL.MonitorSQLTask Extends %SYS.Task.Definition
{

Parameter TaskName = "SQL Statistics Summary";

Method OnTask() As %Status
{
    set tSC=$$$OK
    TRY {
        do ##class(DRL.MonitorSQL).Run()
    }
    CATCH exp {
        set tSC=$SYSTEM.Status.Error("Error in SQL Monitor Summary Task")
    }
    quit tSC
}

}
