<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Account_Judgment_Number_Field_Update</fullName>
        <description>Account Judgment Number Field Update</description>
        <field>Account_Judgment_Number__c</field>
        <formula>Name</formula>
        <name>Account Judgment Number Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Account_Judgment_Inactive</fullName>
        <field>Status__c</field>
        <literalValue>Inactive</literalValue>
        <name>Set Account Judgment Inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Account Judgment Blank</fullName>
        <actions>
            <name>Set_Account_Judgment_Inactive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(  ISPICKVAL(Status__c,&apos;&apos;),  ISPICKVAL(Judgment__r.Legal_Sub_Status__c, &apos;Vacated&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Account Judgment Number Field Update</fullName>
        <actions>
            <name>Account_Judgment_Number_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Judgment__c.Account_Judgment_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Account Judgment Number Field Update</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
