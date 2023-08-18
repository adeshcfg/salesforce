<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Users_on_MegaSys_Error</fullName>
        <ccEmails>crmerrors@canaccede.com</ccEmails>
        <description>Notify Users on MegaSys Error</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>To_Be_Decided/API_Error_Template</template>
    </alerts>
    <alerts>
        <fullName>Notify_Users_on_Power_Curve_Error</fullName>
        <ccEmails>crmerrors@canaccede.com</ccEmails>
        <description>Notify Users on Power Curve Error</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>To_Be_Decided/API_Error_Template</template>
    </alerts>
    <alerts>
        <fullName>Notify_Users_on_TransUnion_Error</fullName>
        <ccEmails>crmerrors@canaccede.com</ccEmails>
        <description>Notify Users on TransUnion Error</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>To_Be_Decided/API_Error_Template</template>
    </alerts>
    <alerts>
        <fullName>Notify_Users_on_VersaPay_Funding_Error</fullName>
        <ccEmails>crmerrors@canaccede.com</ccEmails>
        <description>Notify Users on VersaPay Funding Error</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>To_Be_Decided/API_Error_Template</template>
    </alerts>
    <alerts>
        <fullName>Notify_Users_on_VersaPay_Payment_Setup_Error</fullName>
        <ccEmails>crmerrors@canaccede.com</ccEmails>
        <description>Notify Users on VersaPay Payment Setup Error</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>To_Be_Decided/API_Error_Template</template>
    </alerts>
    <rules>
        <fullName>Notify Users on MegaSys Error</fullName>
        <actions>
            <name>Notify_Users_on_MegaSys_Error</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>API_Error__c.End_Point__c</field>
            <operation>equals</operation>
            <value>MegaSys</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Users on Power Curve Error</fullName>
        <actions>
            <name>Notify_Users_on_Power_Curve_Error</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>API_Error__c.End_Point__c</field>
            <operation>equals</operation>
            <value>PCoD</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Users on TransUnion Error</fullName>
        <actions>
            <name>Notify_Users_on_TransUnion_Error</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>API_Error__c.End_Point__c</field>
            <operation>equals</operation>
            <value>TransUnion</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Users on VersaPay Funding Error</fullName>
        <actions>
            <name>Notify_Users_on_VersaPay_Funding_Error</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>API_Error__c.End_Point__c</field>
            <operation>equals</operation>
            <value>VersaPay Funding</value>
        </criteriaItems>
        <description>Notify Users on VersaPay Funding Error</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Users on VersaPay Payment Setup Error</fullName>
        <actions>
            <name>Notify_Users_on_VersaPay_Payment_Setup_Error</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>API_Error__c.End_Point__c</field>
            <operation>equals</operation>
            <value>VersaPay Payment</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
