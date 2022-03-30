/// Summary of very low cost SQL query statistics collected in Cache 2017.1 and later. <br/>
/// Refer to documentation on "SQL Statement Details" for information on the source data. <br/>
/// Data is stored by date and time to support queries over time. <br/>
/// Typically run to summarise the SQL query data from the previous day.
Class DRL.MonitorSQL Extends %Persistent
{

/// RunDate and RunTime uniquely identify a run
Property RunDate As %Date;

/// Time the capture was started
/// RunDate and RunTime uniquely identify a run
Property RunTime As %Time;

/// Count of total hits for the time period for
Property TotalHits As %Integer;

/// Sum of pTime
Property SumPTime As %Numeric(SCALE = 4);

/// Routine where SQL is found
Property RoutineName As %String(MAXLEN = 1024);

/// Hash of query text
Property Hash As %String;

Property Variance As %Numeric(SCALE = 4);

/// Namespace where queries are run
Property Namespace As %String;

/// Default run will process the previous days data for a single day.
/// Other date range combinations can be achieved using the Capture method.
ClassMethod Run()
{
    //Each run is identified by the start date / time to keep related items together
    
    set h=$h-1
    do ..Capture(+h,+h)
}

/// Captures historic statistics for a range of dates
ClassMethod Capture(dfrom, dto)
{
    set oldstatsvalue=$system.SQL.SetSQLStatsJob(-1)
    
    set currNS=$znspace
    set tSC=##class(%SYS.Namespace).ListAll(.nsArray)
    set ns=""
    set time=$piece($h,",",2)
    kill ^||TMP.MonitorSQL
    do {
        set ns=$o(nsArray(ns))
        quit:ns=""
        use 0 write !,"processing namespace ",ns
        zn ns
        for dateh=dfrom:1:dto {
            set hash=""
            set purgedun=0
            do {
                set hash=$order(^rINDEXSQL("sqlidx",1,hash))
                continue:hash=""
                set stats=$get(^rINDEXSQL("sqlidx",1,hash,"stat",dateh))
                continue:stats=""
                set ^||TMP.MonitorSQL(dateh,ns,hash)=stats
                        
                &SQL(SELECT  Location into :tLocation FROM INFORMATION_SCHEMA.STATEMENT_LOCATIONS WHERE Statement=:hash)
                            if SQLCODE'=0 set Location=""
                            set ^||TMP.MonitorSQL(dateh,ns,hash,"Location")=tLocation
                            
                &SQL(SELECT  Statement INTO :Statement FROM INFORMATION_SCHEMA.STATEMENTS WHERE Hash=:hash)
                            if SQLCODE'=0 set Statement=""
                            set ^||TMP.MonitorSQL(dateh,ns,hash,"QueryText")=Statement
            } while hash'=""
                        
        }
    } while ns'=""

    zn currNS
    set dateh=""

    do {
        set dateh=$o(^||TMP.MonitorSQL(dateh))
        quit:dateh=""
        set ns=""
        
        do {
            set ns=$o(^||TMP.MonitorSQL(dateh,ns))
            quit:ns=""
            set hash=""
            do {
                set hash=$o(^||TMP.MonitorSQL(dateh,ns,hash))
                quit:hash=""
                set stats=$g(^||TMP.MonitorSQL(dateh,ns,hash))
                continue:stats=""
                // The first time through the loop delete all statistics for the day so it is re-runnable
                // But if we run for a day after the raw data has been purged, it will wreck eveything
                // so do it here, where we already know there are results to insert in their place.
                if purgedun=0 {
                            &SQL(DELETE FROM websys.MonitorSQL WHERE RunDate=:dateh )
                            set purgedun=1
                }
                
                set tObj=##class(DRL.MonitorSQL).%New()

                set tObj.Namespace=ns
                set tObj.RunDate=dateh
                set tObj.RunTime=time
                set tObj.Hash=hash
                set tObj.TotalHits=$listget(stats,1)
                set tObj.SumPTime=$listget(stats,2)
                set tObj.Variance=$listget(stats,3)
                set tObj.Variance=$listget(stats,3)
                
                set queryText=^||TMP.MonitorSQL(dateh,ns,hash,"QueryText")
                set tObj.RoutineName=^||TMP.MonitorSQL(dateh,ns,hash,"Location")
                
                &SQL(Select ID into :TextID from DRL.MonitorSQLText where Hash=:hash)
                if SQLCODE'=0 {
                            set textref=##class(DRL.MonitorSQLText).%New()
                            set textref.Hash=tObj.Hash
                            set textref.QueryText=queryText
                            set sc=textref.%Save()
                }                                                       
                set tSc=tObj.%Save()
                
                //avoid dupicating the query text in each record because it can be very long. Use a lookup
                //table keyed on the hash. If it doesn't exist add it.
                if $$$ISERR(tSc) do $system.OBJ.DisplayError(tSc)
                

                if $$$ISERR(tSc) do $system.OBJ.DisplayError(tSc)

            } while hash'=""
        } while ns'=""

    } while dateh'=""     
    
    do $system.SQL.SetSQLStatsJob(0)
}

Query Export(RunDateH1 As %Date, RunDateH2 As %Date) As %SQLQuery
{
    SELECT S.Hash,RoutineName,RunDate,RunTime,SumPTime,TotalHits,Variance,RoutineName,T.QueryText
    FROM DRL.MonitorSQL S LEFT JOIN DRL.MonitorSQLText T on S.Hash=T.Hash
    WHERE RunDate>=:RunDateH1 AND RunDate<=:RunDateH2
}

Storage Default
{
<Data name="MonitorSQLDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RunDate</Value>
</Value>
<Value name="3">
<Value>RunTime</Value>
</Value>
<Value name="4">
<Value>TotalHits</Value>
</Value>
<Value name="5">
<Value>SumPTime</Value>
</Value>
<Value name="6">
<Value>RoutineName</Value>
</Value>
<Value name="7">
<Value>Hash</Value>
</Value>
<Value name="8">
<Value>Variance</Value>
</Value>
<Value name="9">
<Value>Namespace</Value>
</Value>
</Data>
<DataLocation>^DRL.MonitorSQLD</DataLocation>
<DefaultData>MonitorSQLDefaultData</DefaultData>
<IdLocation>^DRL.MonitorSQLD</IdLocation>
<IndexLocation>^DRL.MonitorSQLI</IndexLocation>
<StreamLocation>^DRL.MonitorSQLS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
