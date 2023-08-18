<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_When_SFDC_Issue_Has_Been_Rejected</fullName>
        <description>Email When SFDC Issue Has Been Rejected</description>
        <protected>false</protected>
        <recipients>
            <recipient>api@canaccede.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>To_Be_Decided/Email_When_SFDC_Issue_Has_Been_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Notification_when_Assigned</fullName>
        <ccEmails>mark.vanpee@canaccede.com</ccEmails>
        <ccEmails>denise.moorcraft@canaccede.com</ccEmails>
        <description>Notification when Assigned</description>
        <protected>false</protected>
        <recipients>
            <recipient>api@canaccede.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>To_Be_Decided/Email_When_SFDC_Issue_Is_Created</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_Tim_when_issue_is_ready_for_testing</fullName>
        <description>Send email to when issue is ready for testing</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>To_Be_Decided/Email_When_SFDC_Issue_is_Ready_to_be_Testing</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_owner_on_Create</fullName>
        <ccEmails>Mike@bigkiteconsulting.com</ccEmails>
        <description>Send email to owner on Create or Assigned</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>To_Be_Decided/Email_When_SFDC_Issue_Is_Created</template>
    </alerts>
    <rules>
        <fullName>Send email notification issue has been rejected</fullName>
        <actions>
            <name>Email_When_SFDC_Issue_Has_Been_Rejected</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>ISPICKVAL(Status__c, &quot;Tested and Rejected&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send email notification on create of issue</fullName>
        <actions>
            <name>Notification_when_Assigned</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>SFDC_Issue__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Send email notification to Assign Resource</fullName>
        <actions>
            <name>Notification_when_Assigned</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ischanged(Assigned__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send email notification to Astound when ready to be tested</fullName>
        <actions>
            <name>Send_email_to_Tim_when_issue_is_ready_for_testing</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Status__c, &quot;Ready for Testing&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send email notification to Team when ready to be tested</fullName>
        <actions>
            <name>Send_email_to_Tim_when_issue_is_ready_for_testing</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Status__c, &quot;Ready for Testing&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send email notification to project owner</fullName>
        <actions>
            <name>Send_email_to_owner_on_Create</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
