<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Settlement_Name_Field_Update</fullName>
        <description>Settlement Name Field Update</description>
        <field>Settlement_Number__c</field>
        <formula>&apos;SC&apos;+&apos;-&apos;+TRIM(RIGHT(Name, LEN(Name)-2 ))</formula>
        <name>Settlement Name Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>approved_Date_Population</fullName>
        <field>Approved_Date__c</field>
        <formula>DATETIMEVALUE(Approved_Date_Text__c)</formula>
        <name>approved Date Population</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>rejected_Date_Population</fullName>
        <field>Rejected_Date__c</field>
        <formula>DATETIMEVALUE(Rejected_Date_Text__c )</formula>
        <name>rejected Date Population</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Settlement Number Field Update</fullName>
        <actions>
            <name>Settlement_Name_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Settlement__c.Settlement_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Settlement Number Field Update</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Approved Date</fullName>
        <actions>
            <name>approved_Date_Population</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Settlement__c.Approved_Date_Text__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Rejected Date</fullName>
        <actions>
            <name>rejected_Date_Population</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Settlement__c.Rejected_Date_Text__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
