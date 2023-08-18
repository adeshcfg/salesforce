<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Remitted_back_to_value</fullName>
        <field>Remitted_Back_to_Formula__c</field>
        <formula>IF(Remitted_Back_To__r.Name == NULL, &apos;Scotia&apos;, Remitted_Back_To__r.Name)</formula>
        <name>Remitted back to value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Calculate remitted back to value</fullName>
        <actions>
            <name>Remitted_back_to_value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Unallocated_Payment__c.Unallocated_Amount__c</field>
            <operation>notEqual</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
