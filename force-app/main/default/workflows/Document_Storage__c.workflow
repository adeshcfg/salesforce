<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Document_Storage_Number_Field_Update</fullName>
        <description>Document Storage Number Field Update</description>
        <field>Document_Storage_Number__c</field>
        <formula>Name</formula>
        <name>Document Storage Number Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Document Storage Number Field Update</fullName>
        <actions>
            <name>Document_Storage_Number_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Document_Storage__c.Document_Storage_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Document Storage Number Field Update</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
