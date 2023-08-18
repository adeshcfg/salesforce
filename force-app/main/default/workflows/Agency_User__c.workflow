<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_On_Agency_User</fullName>
        <description>Email Alert On Agency User</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>client.services@canaccede.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Email_For_Agency_User_Template</template>
    </alerts>
    <rules>
        <fullName>Agency User Verification Email</fullName>
        <actions>
            <name>Email_Alert_On_Agency_User</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Agency_User__c.Is_Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Agency_User__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Portal User,Agnecy Contact Portal User,Agnecy Contact Portal User,Portal User</value>
        </criteriaItems>
        <description>Agency User Verification Email</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
