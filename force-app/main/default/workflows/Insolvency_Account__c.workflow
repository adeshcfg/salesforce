<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Putback_BuyBack_Complated_Date</fullName>
        <field>Putback_Buyback_Completed_Date__c</field>
        <formula>TODAY()</formula>
        <name>Putback/BuyBack Complated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Statement_Requested_Update</fullName>
        <field>Statements_Requested_Date__c</field>
        <formula>NOW()</formula>
        <name>Statement Requested_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Auto populate Putback%2FBuyback Complated Date</fullName>
        <actions>
            <name>Putback_BuyBack_Complated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED(Asset_Status__c),
OR(ISPICKVAL(Asset_Status__c, &apos;Putback&apos;),
ISPICKVAL(Asset_Status__c, &apos;Buyback&apos;))
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Statement Requested Workflow</fullName>
        <actions>
            <name>Statement_Requested_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Statements_Requested__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
