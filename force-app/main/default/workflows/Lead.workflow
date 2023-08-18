<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>When_Lead_is_created_send_email</fullName>
        <description>When Lead is created, send email</description>
        <protected>false</protected>
        <recipients>
            <recipient>Lead_Notification_Users</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>marketing@canaccede.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SalesPipeline/New_Lead_Creation_Email_Template</template>
    </alerts>
    <rules>
        <fullName>Lead Creation Email</fullName>
        <actions>
            <name>When_Lead_is_created_send_email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>equals</operation>
            <value>Web</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
