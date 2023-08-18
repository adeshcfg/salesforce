<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>When_TCI_Job_isCreated_or_Updated_send_email</fullName>
        <ccEmails>TCI@affirmfinancial.ca</ccEmails>
        <description>When TCI Job is Created or Updated, send email</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Fidem_Templates/TCI_Attchement_Details</template>
    </alerts>
    <rules>
        <fullName>Attachment link for TCI Job</fullName>
        <actions>
            <name>When_TCI_Job_isCreated_or_Updated_send_email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>TCI_Job__c.TCI_CSV_Attachment_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
