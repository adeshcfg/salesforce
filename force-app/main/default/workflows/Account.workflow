<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Account_Verification_Email</fullName>
        <description>Account Verification Email</description>
        <protected>false</protected>
        <recipients>
            <field>User_Provided_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>client.services@canaccede.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Account_Verification_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Sales_Pipeline</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Previous_Credit_Score</fullName>
        <description>Update Previous Credit Score with Current</description>
        <field>Previous_Credit_Score__pc</field>
        <formula>PRIORVALUE(Credit_Score__pc)</formula>
        <name>Update Previous Credit Score</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Previous_Credit_Score_Update_Date</fullName>
        <description>Update Previous Credit Score Updated Date from Credit Score Updated Date</description>
        <field>Previous_Credit_Score_Updated_Date__pc</field>
        <formula>PRIORVALUE(Credit_Score_Updated_Date__pc)</formula>
        <name>Update Previous Credit Score Update Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Send Account Verification Email</fullName>
        <actions>
            <name>Account_Verification_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send Account Verification Email</description>
        <formula>ISCHANGED( Verification_Auth_Token__c ) &amp;&amp; NOT( ISBLANK( Verification_Auth_Token__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Record Type</fullName>
        <actions>
            <name>Set_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Account_Record_type__c</field>
            <operation>equals</operation>
            <value>Sales Pipeline</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Previous Credit Score</fullName>
        <actions>
            <name>Update_Previous_Credit_Score</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Previous_Credit_Score_Update_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Previous Credit Score fields when Credit Score Changes</description>
        <formula>ISCHANGED(Credit_Score__pc) &amp;&amp;  !ISBLANK(Credit_Score__pc)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
