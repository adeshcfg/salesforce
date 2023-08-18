<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Users_for_Powercurve_Errors</fullName>
        <ccEmails>crmerrors@canaccede.com</ccEmails>
        <description>Notify Users for Powercurve Errors</description>
        <protected>false</protected>
        <recipients>
            <recipient>api@canaccede.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>To_Be_Decided/Email_When_PowerCurve_Errors_Out</template>
    </alerts>
    <rules>
        <fullName>Notify Users on PowerCurve Error</fullName>
        <actions>
            <name>Notify_Users_for_Powercurve_Errors</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Power_Curve_Error__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
