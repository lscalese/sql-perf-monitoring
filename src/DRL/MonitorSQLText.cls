Class DRL.MonitorSQLText Extends %Persistent
{

/// Hash of query text
Property Hash As %String;

/// query text for hash
Property QueryText As %String(MAXLEN = 9999);

Index IndHash On Hash [ IdKey, Unique ];

Storage Default
{
<Data name="MonitorSQLTextDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>QueryText</Value>
</Value>
</Data>
<DataLocation>^DRL.MonitorSQLTextD</DataLocation>
<DefaultData>MonitorSQLTextDefaultData</DefaultData>
<IdLocation>^DRL.MonitorSQLTextD</IdLocation>
<IndexLocation>^DRL.MonitorSQLTextI</IndexLocation>
<StreamLocation>^DRL.MonitorSQLTextS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
