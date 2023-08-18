<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Authentication_Email</fullName>
        <description>Authentication Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Fidem_Templates/Authentication_Email</template>
    </alerts>
    <alerts>
        <fullName>Authentication_Email_Applicant_Type_1</fullName>
        <description>Authentication Email Applicant Type 1</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>lending@fidemfinance.ca</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>To_Be_Decided/Authentication_Email_Applicant_Type_1</template>
    </alerts>
    <alerts>
        <fullName>Authentication_Email_Applicant_Type_2</fullName>
        <description>Authentication Email Applicant Type 2</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>lending@fidemfinance.ca</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>To_Be_Decided/Authentication_Email_Applicant_Type_2</template>
    </alerts>
    <alerts>
        <fullName>Email_Canccede_Team_on_App_Creation</fullName>
        <description>Email Canccede Team on App Creation</description>
        <protected>false</protected>
        <recipients>
            <recipient>mark.vanpee@canaccede.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>wendy.jeanveau@canaccede.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>To_Be_Decided/Notification_of_App_Creation</template>
    </alerts>
    <alerts>
        <fullName>Send_Verification_Email</fullName>
        <description>Verification Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>lending@fidemfinance.ca</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Verification_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>Authorized_Credit_Check_Date</fullName>
        <field>Authorized_Credit_Check_Date__c</field>
        <formula>NOW()</formula>
        <name>Authorized Credit Check Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Application Created</fullName>
        <actions>
            <name>Email_Canccede_Team_on_App_Creation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Application__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Send Auto-Authentication Email</fullName>
        <actions>
            <name>Authentication_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>ISCHANGED( Email_Auth_Token__c ) &amp;&amp; NOT( ISBLANK( Email_Auth_Token__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Auto-Authentication Email Applicant Type 1</fullName>
        <actions>
            <name>Authentication_Email_Applicant_Type_1</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Email_Auth_Token__c )  &amp;&amp;  NOT(ISBLANK(Email_Auth_Token__c)) &amp;&amp; (OR ( (ISPICKVAL(PcoD_Bankruptcy_State__c, &quot;Traditional&quot;)),  (ISPICKVAL(PcoD_Bankruptcy_State__c, &quot;BKCP Discharged =&gt; 1 Year&quot;)), (ISPICKVAL(PcoD_Bankruptcy_State__c, &quot;BKCP Discharged &lt; 1 Year&quot;)) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Auto-Authentication Email Applicant Type 2</fullName>
        <actions>
            <name>Authentication_Email_Applicant_Type_2</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Email_Auth_Token__c )  &amp;&amp;  NOT(ISBLANK(Email_Auth_Token__c)) &amp;&amp; (ISPICKVAL(PcoD_Bankruptcy_State__c, &quot;BKCP Not Discharged&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Verification Email</fullName>
        <actions>
            <name>Send_Verification_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(  Verification_Auth_Token__c ) &amp;&amp; NOT( ISBLANK(  Verification_Auth_Token__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Credit Check Date</fullName>
        <actions>
            <name>Authorized_Credit_Check_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Application__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.Authorized_Credit_Check_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.Authorized_Credit_Check__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Stamp the credit check date on application creation.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
