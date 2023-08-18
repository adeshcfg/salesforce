<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Distressed_Note_Number_Field_Update</fullName>
        <description>Distressed Note Number Field Update</description>
        <field>Distressed_Notes_Number__c</field>
        <formula>Name</formula>
        <name>Distressed Note Number Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Distressed Note Number Field Update</fullName>
        <actions>
            <name>Distressed_Note_Number_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Distressed_notes__c.Distressed_Notes_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Distressed Note Number Field Update</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
