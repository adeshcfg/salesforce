<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Task_Number_Field_Update</fullName>
        <description>Task Number Field Update</description>
        <field>Task_Number__c</field>
        <formula>Name
/*&apos;TC&apos; + &apos;-&apos; + Placement_Agency__r.Name + &apos;-&apos; + TRIM(RIGHT(Name, LEN(Name)-3 ))*/</formula>
        <name>Task Number Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Task Number Field Update</fullName>
        <actions>
            <name>Task_Number_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Assignment__c.Task_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Task Number Field Update</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
