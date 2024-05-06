{{#apexCode}}
{{{apexCode}}}
System.debug('Executed Apex code');
{{/apexCode}}
{{#dml}}
List<SObject> recordsToInsert = new List<SObject>();
List<SObject> recordsToUpdate = new List<SObject>();
{{#dml.update}}
{{objectName}} {{recordVariableName}} = new {{objectName}}();
{{#fields}}
{{recordVariableName}}.{{fieldApiName}} = {{{fieldValue}}};
{{/fields}}
recordsToUpdate.add({{recordVariableName}});
{{/dml.update}}
{{#dml.insert}}
{{objectName}} {{recordVariableName}} = new {{objectName}}();
{{#fields}}
{{recordVariableName}}.{{fieldApiName}} = {{{fieldValue}}};
{{/fields}}
recordsToInsert.add({{recordVariableName}});
{{/dml.insert}}
try {
	if(recordsToUpdate.size() > 0){
		Database.update(recordsToUpdate);
	}
	if(recordsToInsert.size() > 0){
		Database.insert(recordsToInsert);
	}
}   
catch(DmlException ex) {
	System.debug('DMLException ' + ex.getDmlMessage(0));
}
System.debug('Executed DMLs');
{{/dml}}