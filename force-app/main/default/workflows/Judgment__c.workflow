<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Field_Update_Defended_Action</fullName>
        <field>Defended_Action__c</field>
        <literalValue>1</literalValue>
        <name>Field Update (Defended Action)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Judgment_Number_Field_Update</fullName>
        <description>Judgment Number Field Update</description>
        <field>Judgment_Number__c</field>
        <formula>&apos;JC&apos;+&apos;-&apos;+Name</formula>
        <name>Judgment Number Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Record_Type_Post_Judgment_Vacated</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Post_Judgment_Vacated</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Record Type Post-Judgment-Vacated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Judgment Number Field Update</fullName>
        <actions>
            <name>Judgment_Number_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Judgment__c.Judgment_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Judgment Number Field Update</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Post-Judgment-Vacated</fullName>
        <actions>
            <name>Set_Record_Type_Post_Judgment_Vacated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Judgment__c.Legal_Status__c</field>
            <operation>equals</operation>
            <value>Post-Judgment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Judgment__c.Legal_Sub_Status__c</field>
            <operation>equals</operation>
            <value>Vacated</value>
        </criteriaItems>
        <description>Change Page layout to Post-Judgment-Vacated with all fields read-only</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Defended Action</fullName>
        <actions>
            <name>Field_Update_Defended_Action</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Judgment__c.Legal_Status__c</field>
            <operation>equals</operation>
            <value>Pre-Judgment,Judgment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Judgment__c.Legal_Sub_Status__c</field>
            <operation>equals</operation>
            <value>Defended Action</value>
        </criteriaItems>
        <description>Update Defended Action</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
