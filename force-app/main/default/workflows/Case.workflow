<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>When_Case_is_Created_send_email</fullName>
        <ccEmails>client.services@canaccede.com</ccEmails>
        <description>When Case is Created, send email</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>SalesPipeline/New_Case_Creation_email_template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assign_To_Update</fullName>
        <description>Update Assign To as &quot;Canaccede&quot;</description>
        <field>Assign_To__c</field>
        <literalValue>Canaccede</literalValue>
        <name>Assign To Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Credit_pack</fullName>
        <field>Form_Types__c</field>
        <literalValue>Creditor Package</literalValue>
        <name>Credit pack</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Assignment Canaccede</fullName>
        <actions>
            <name>Assign_To_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Canaccede Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>EmailToCase</value>
        </criteriaItems>
        <description>Update field Assign To as &quot;Canaccede&quot; when created through email to Case for Canaccede</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Creation Email</fullName>
        <actions>
            <name>When_Case_is_Created_send_email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Web to Case</value>
        </criteriaItems>
        <description>Whenever a Case created, send an email</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Uberbase Credit packs</fullName>
        <actions>
            <name>Credit_pack</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>((1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9) AND 10) OR ( 11 AND 12) OR ((13 OR 14) AND 15)</booleanFilter>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>ProofofClaim@BromwichSmith.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>Fax#604-529-1047</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>POC@harrispartners.ca</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>info@rumanek.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>888-634-0945</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>pierreroy.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>rcgt.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>gothandcompany.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>bromwichsmith.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>contains</operation>
            <value>uberbase</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>creditor package</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>contains</operation>
            <value>donotreply@bankex.ca</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedName</field>
            <operation>contains</operation>
            <value>Sara Lingner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedName</field>
            <operation>contains</operation>
            <value>Nathalie Fournier</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>cred pack</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
