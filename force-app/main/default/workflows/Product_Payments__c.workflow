<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_Current_Balance</fullName>
        <field>Current_Balance__c</field>
        <formula>CCS_Account__r.Current_Balance__c  -  Gross_Payment_Amount__c</formula>
        <name>Change Current Balance</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>CCS_Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Created_Date_of_Product</fullName>
        <description>Payment Created Date</description>
        <field>Payment_Posting_Date__c</field>
        <formula>CreatedDate</formula>
        <name>Created Date of Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_Update</fullName>
        <field>Owner__c</field>
        <formula>CCS_Account__r.Owner_Name__c</formula>
        <name>Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Payment_Date</fullName>
        <description>Populate Payment Created Date</description>
        <field>Payment_Created__c</field>
        <formula>CreatedDate</formula>
        <name>Populate Payment Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Posting_Month_on_Insert_Product</fullName>
        <field>Payment_Posting_Month__c</field>
        <formula>TEXT(YEAR( DATEVALUE(CreatedDate) )) + if((MONTH( DATEVALUE(CreatedDate)) &lt; 10), (&quot;0&quot;+TEXT(MONTH( DATEVALUE(CreatedDate)))), TEXT(MONTH( DATEVALUE(CreatedDate))))</formula>
        <name>Posting Month on Insert Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Balance_After_Payment</fullName>
        <field>Balance_After_Payment__c</field>
        <formula>CCS_Account__r.Current_Balance__c -  Gross_Payment_Amount__c</formula>
        <name>Update Balance After Payment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Balance_on_CCS_Product</fullName>
        <field>Balance_Before_Payment__c</field>
        <formula>CCS_Account__r.Current_Balance__c</formula>
        <name>Update Balance on CCS Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Payment_Amount_on_Product</fullName>
        <description>Update Last Payment Amount on Product</description>
        <field>Last_Payment_Amount__c</field>
        <formula>Payment_Amount__c</formula>
        <name>Update Last Payment Amount on Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>CCS_Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Payment_Date_on_Product</fullName>
        <field>Last_Payment_Date__c</field>
        <formula>Payment_Created__c</formula>
        <name>Update Last Payment Date on Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>CCS_Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Payment_Created_Date</fullName>
        <field>Payment_Created__c</field>
        <formula>CreatedDate</formula>
        <name>Update Payment Created Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Total_Paid_To_Date</fullName>
        <field>Total_Paid_To_Date__c</field>
        <formula>CCS_Account__r.Total_Paid_To_Date__c  +   Payment_Amount__c</formula>
        <name>Update Total Paid To Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>CCS_Account__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Auto populate payment posting date</fullName>
        <actions>
            <name>Created_Date_of_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Product_Payments__c.Payment_Posting_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Created Date is populated on payment posting date</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Owner Field Update</fullName>
        <actions>
            <name>Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>display product owner on product payment at the time of creating product payment.</description>
        <formula>CCS_Account__r.RecordType.DeveloperName   =&apos;Distressed_Account&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Posting Month on Insert Product Payment</fullName>
        <actions>
            <name>Posting_Month_on_Insert_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Product_Payments__c.Payment_Posting_Month__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>To Populate Posting month on insert of payment</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Balance After Payment</fullName>
        <actions>
            <name>Update_Balance_After_Payment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product__c.Current_Balance__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Product__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCS Account</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Balance Before Payment</fullName>
        <actions>
            <name>Update_Balance_on_CCS_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product__c.Current_Balance__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Product__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCS Account</value>
        </criteriaItems>
        <description>Update Balance Before Payment</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Last Payment Amount on Product</fullName>
        <actions>
            <name>Update_Last_Payment_Amount_on_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product_Payments__c.Payment_Amount__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Product__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCS Account</value>
        </criteriaItems>
        <description>Update Last Payment Amount on Product</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Last Payment Date on Product</fullName>
        <actions>
            <name>Update_Last_Payment_Date_on_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product_Payments__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Product__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCS Account</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Payment Created Date</fullName>
        <actions>
            <name>Update_Payment_Created_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Product_Payments__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Total Paid To Date</fullName>
        <actions>
            <name>Update_Total_Paid_To_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product_Payments__c.Payment_Amount__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Product__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCS Account</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Updated Current bal</fullName>
        <actions>
            <name>Change_Current_Balance</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product_Payments__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCS Dividend Payment,CCS Product Payment,Balance Adjustments</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
