<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Created_date</fullName>
        <description>Payment created date</description>
        <field>Payment_Posting_Date__c</field>
        <formula>CreatedDate</formula>
        <name>Created date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Filed_Update_on_Insolvency_account</fullName>
        <description>insolvency payment creat time fill the payment amount that payment amount is populated on insolvency account on Insolvency Last Payment Amount</description>
        <field>Insolvency_Last_Payment_Amount__c</field>
        <formula>Payment_Amount__c</formula>
        <name>Filed Update on Insolvency account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Insolvency_Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Payment_Date</fullName>
        <description>Populate payment created date</description>
        <field>Payment_Created__c</field>
        <formula>CreatedDate</formula>
        <name>Populate Payment Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Posting_Month_on_Insert_Payment</fullName>
        <description>Populate Posting Month on Insert Payment</description>
        <field>Payment_Posting_Month__c</field>
        <formula>TEXT(YEAR( DATEVALUE(CreatedDate) )) + if((MONTH( DATEVALUE(CreatedDate)) &lt; 10), (&quot;0&quot;+TEXT(MONTH( DATEVALUE(CreatedDate)))), TEXT(MONTH( DATEVALUE(CreatedDate))))</formula>
        <name>Populate Posting Month on Insert Payment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_payment_date</fullName>
        <description>when insolvency payment is created at the time update the only last payment date field on insolvency account</description>
        <field>Insolvency_Last_Payment_Date__c</field>
        <formula>Payment_Created__c</formula>
        <name>Update Last payment date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Insolvency_Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Payment_Reversal_Date</fullName>
        <description>Update Payment Reversal Date</description>
        <field>Payment_Reversal_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Payment Reversal Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Auto Populate Payment Created Date</fullName>
        <actions>
            <name>Populate_Payment_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Insolvency_Payment__c.Payment_Created__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Auto Populate Payment Created Date</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Auto populate payment posting date</fullName>
        <actions>
            <name>Created_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Insolvency_Payment__c.Payment_Posting_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Created date is populated on payment posting date</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Payment Reversal Date on Insolvency Payment</fullName>
        <actions>
            <name>Update_Payment_Reversal_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate Payment Reversal Date from Insolvency Payment when Payment is reversed</description>
        <formula>AND ( ISBLANK( Payment_Reversal_Date__c ), ISCHANGED( Payment_Reversed__c ),  NOT( ISBLANK(TEXT(Payment_Reversed__c )) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Posting Month on Insert Payment</fullName>
        <actions>
            <name>Populate_Posting_Month_on_Insert_Payment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Insolvency_Payment__c.Payment_Posting_Month__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populate Posting Month on Insert Payment</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Insolvency Last Payment Amount on Insolvency Account</fullName>
        <actions>
            <name>Filed_Update_on_Insolvency_account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Insolvency_Payment__c.Payment_Amount__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Insolvency_Payment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Remittance,Insolvency Payment</value>
        </criteriaItems>
        <description>Update Insolvency Last Payment Amount on Insolvency Account	when insolvency payment created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Insolvency last Payment Date</fullName>
        <actions>
            <name>Update_Last_payment_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Insolvency_Payment__c.Payment_Created__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>In insolvency account object new field added that field automatically populated when insolvency payment is created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
