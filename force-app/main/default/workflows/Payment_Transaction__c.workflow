<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>One_Time_Request_Funds_Initiate_Email</fullName>
        <description>One Time Request Funds Initiate Email</description>
        <protected>false</protected>
        <recipients>
            <field>Customer_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>myaccountmanagement@canaccede.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Payment_Processor_Templates/Payment_Processor_One_Time_Request_Sent</template>
    </alerts>
    <alerts>
        <fullName>Recurring_Biweekly_Request_Funds_Initiate_Email</fullName>
        <description>Recurring Biweekly Request Funds Initiate Email</description>
        <protected>false</protected>
        <recipients>
            <field>Customer_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>myaccountmanagement@canaccede.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Payment_Processor_Templates/Payment_Processor_Biweekly_Recurring_Request_Sent</template>
    </alerts>
    <alerts>
        <fullName>Recurring_Monthly_Payment_Set_Email</fullName>
        <description>Recurring Monthly Payment Set Email</description>
        <protected>false</protected>
        <recipients>
            <field>Customer_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>myaccountmanagement@canaccede.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Payment_Processor_Templates/Payment_Processor_Monthly_Recurring_Transaction_Set</template>
    </alerts>
    <alerts>
        <fullName>Recurring_Monthly_Request_Funds_Initiate_Email</fullName>
        <description>Recurring Monthly Request Funds Initiate Email</description>
        <protected>false</protected>
        <recipients>
            <field>Customer_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>myaccountmanagement@canaccede.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Payment_Processor_Templates/Payment_Processor_Monthly_Recurring_Request_Sent</template>
    </alerts>
    <alerts>
        <fullName>Recurring_Payment_Transaction_Set</fullName>
        <description>Recurring Payment Transaction Set</description>
        <protected>false</protected>
        <recipients>
            <field>Customer_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>myaccountmanagement@canaccede.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Payment_Processor_Templates/Payment_Processor_Monthly_Recurring_Transaction_Set</template>
    </alerts>
    <alerts>
        <fullName>Recurring_Weekly_BiWeekly_Payment_Set_Email</fullName>
        <description>Recurring Weekly/Biweekly Payment Set Email</description>
        <protected>false</protected>
        <recipients>
            <field>Customer_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>myaccountmanagement@canaccede.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Payment_Processor_Templates/Payment_Processor_Weekly_BiWeekly_Recurring_Transaction_Set</template>
    </alerts>
    <alerts>
        <fullName>Recurring_Weekly_Request_Funds_Initiate_Email</fullName>
        <description>Recurring Weekly Request Funds Initiate Email</description>
        <protected>false</protected>
        <recipients>
            <field>Customer_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>myaccountmanagement@canaccede.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Payment_Processor_Templates/Payment_Processor_Weekly_Recurring_Request_Sent</template>
    </alerts>
    <alerts>
        <fullName>Send_Payment_Processor_Transaction_Error_Alert</fullName>
        <description>Send Payment Processor Transaction Error Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Customer_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>myaccountmanagement@canaccede.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Payment_Processor_Templates/Payment_Processor_Transaction_Error</template>
    </alerts>
    <alerts>
        <fullName>Send_Payment_Processor_Transaction_Success_Alert</fullName>
        <description>Send Payment Processor Transaction Success Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Customer_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>myaccountmanagement@canaccede.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Payment_Processor_Templates/Payment_Processor_Transaction_Completion</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Status_Change_Date</fullName>
        <field>Status_Change_Date__c</field>
        <formula>NOW()</formula>
        <name>Set Status Change Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Payment Processor Transaction Error</fullName>
        <actions>
            <name>Send_Payment_Processor_Transaction_Error_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (OR( RecordType.DeveloperName = &apos;One_time_Payment&apos;, RecordType.DeveloperName = &apos;Recurring_Payment_Child&apos;),   ISCHANGED(Status__c) , ISPICKVAL(Status__c , &apos;Failed&apos;), Parent__r.Product__r.Customer__r.Payment_Success_Failure_Notifications__c  == true, Parent__r.Product__r.Customer__r.PersonHasOptedOutOfEmail = false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Payment Processor Transaction Success</fullName>
        <actions>
            <name>Send_Payment_Processor_Transaction_Success_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (OR( RecordType.DeveloperName = &apos;One_time_Payment&apos;, RecordType.DeveloperName = &apos;Recurring_Payment_Child&apos;), ISCHANGED(Status__c) , ISPICKVAL(Status__c , &apos;Completed&apos;), Parent__r.Product__r.Customer__r.Payment_Success_Failure_Notifications__c  == true, Parent__r.Product__r.Customer__r.PersonHasOptedOutOfEmail = false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Biweekly Request Fund Request to Customer</fullName>
        <actions>
            <name>Recurring_Biweekly_Request_Funds_Initiate_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send Biweekly Request Fund request to Customer on payment inititation</description>
        <formula>AND(ISBLANK(PRIORVALUE( Connect_Url__c )) ,  NOT(ISBLANK(Connect_Url__c )),  Record_Type_Name__c = &apos;Request_Funds_Recurring&apos;, ISPICKVAL(  Recurrence_Type__c , &apos;Biweekly&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Monthly Recurring Payment Set to Customer</fullName>
        <actions>
            <name>Recurring_Monthly_Payment_Set_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (RecordType.DeveloperName = &apos;Recurring_Payment_Master&apos;, Parent__r.Product__r.Customer__r.Payment_Success_Failure_Notifications__c  == true, ISPICKVAL( Recurrence_Type__c , &apos;Monthly&apos;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Send Monthly Request Fund Request to Customer</fullName>
        <actions>
            <name>Recurring_Monthly_Request_Funds_Initiate_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send Monthly Request Fund request to Customer on payment inititation</description>
        <formula>AND(ISBLANK(PRIORVALUE( Connect_Url__c )) ,  NOT(ISBLANK(Connect_Url__c )),  Record_Type_Name__c = &apos;Request_Funds_Recurring&apos;, ISPICKVAL(  Recurrence_Type__c , &apos;Monthly&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send One Time Request Fund Request to Customer</fullName>
        <actions>
            <name>One_Time_Request_Funds_Initiate_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send Request Fund request to Customer on payment inititation</description>
        <formula>AND(  ISBLANK(PRIORVALUE( Connect_Url__c )) ,  NOT(ISBLANK(Connect_Url__c )), Record_Type_Name__c = &apos;Request_Funds_One_Time&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Weekly Request Fund Request to Customer</fullName>
        <actions>
            <name>Recurring_Weekly_Request_Funds_Initiate_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send Weekly Request Fund request to Customer on payment inititation</description>
        <formula>AND(ISBLANK(PRIORVALUE( Connect_Url__c )) ,  NOT(ISBLANK(Connect_Url__c )),  Record_Type_Name__c = &apos;Request_Funds_Recurring&apos;, ISPICKVAL(  Recurrence_Type__c , &apos;Weekly&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Weekly%2FBiweekly Recurring Payment Set  to Customer</fullName>
        <actions>
            <name>Recurring_Weekly_BiWeekly_Payment_Set_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send Weekly/Biweekly Recurring Payment to Customer on payment inititation</description>
        <formula>AND(Record_Type_Name__c = &apos;Recurring_Payment_Master&apos;, Parent__r.Product__r.Customer__r.Payment_Success_Failure_Notifications__c == true, OR(ISPICKVAL(  Recurrence_Type__c , &apos;Biweekly&apos;), ISPICKVAL(  Recurrence_Type__c , &apos;Weekly&apos;)))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Payment Transaction Status Change Date</fullName>
        <actions>
            <name>Set_Status_Change_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Status__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
