<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>mark_complete</fullName>
        <description>Mark campaign status as Completed</description>
        <field>Status</field>
        <literalValue>Completed</literalValue>
        <name>mark complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>uncheck</fullName>
        <description>UNcheck active</description>
        <field>IsActive</field>
        <literalValue>0</literalValue>
        <name>uncheck</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Deactivate Campaign</fullName>
        <active>false</active>
        <description>Deactivate campaign after end date.</description>
        <formula>IsActive  = TRUE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>mark_complete</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>uncheck</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Campaign.EndDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
