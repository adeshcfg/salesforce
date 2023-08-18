<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Notification_on_Insolvency_Error</fullName>
        <ccEmails>crmerrors@canaccede.com</ccEmails>
        <description>Email Notification on Insolvency Error</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Insolvency_Templates/Insolvency_Error_Template</template>
    </alerts>
    <rules>
        <fullName>Notify Users on Insolvency Error</fullName>
        <actions>
            <name>Email_Notification_on_Insolvency_Error</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Insolvency_Error__c.Action__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Notify Users on Insolvency Error</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
