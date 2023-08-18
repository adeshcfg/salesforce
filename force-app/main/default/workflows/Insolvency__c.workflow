<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Remove_Locked_By_User</fullName>
        <description>Remove Locked By User</description>
        <field>Record_Locked_By__c</field>
        <name>Remove Locked By User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unlock_Insolvency</fullName>
        <description>Unlock Insolvency</description>
        <field>Is_Record_Locked__c</field>
        <literalValue>0</literalValue>
        <name>Unlock Insolvency</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Insolvency Locking</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Insolvency__c.Is_Record_Locked__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Insolvency Locking</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Remove_Locked_By_User</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Unlock_Insolvency</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Insolvency__c.Trigger_Time__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
