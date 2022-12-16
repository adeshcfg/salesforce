@isTest
public class TestCollectionContactAccountBatch {
    @isTest
 	public static void Testcollection()
 	{
     List<RecordType> recordTypeList = [select id, name, SobjectType from RecordType where SobjectType = 'Account' and name = 'Canaccede Customer'];   
        
     List<Account> accList = new List<Account>();
	 Account acc1 = new Account();
     //acc1.Name='Test1';
     acc1.FirstName = 'Test';
     acc1.LastName = 'Name 1';
     acc1.No_of_times_contacted_for_collection__c=7;
     acc1.No_of_times_contact_collection_in_n_days__c=90;
     acc1.No_of_times_contacted__c=17;
     acc1.RecordTypeId = recordTypeList[0].id;
     accList.add(acc1);
     
     Account acc2 = new Account();
     //acc2.Name='Test2';
     acc2.FirstName = 'Test';
     acc2.LastName = 'Name 2';
     acc2.No_of_times_contacted_for_collection__c=7;
     acc2.No_of_times_contact_collection_in_n_days__c=90;
     acc2.No_of_times_contacted__c=17;
     acc2.RecordTypeId = recordTypeList[0].id;   
     accList.add(acc2);
     insert accList;

     Collection_Custom_Setting__c collCustSett = new Collection_Custom_Setting__c();
     collCustSett.Contact_Counter_Code__c='Test1,Test2,Test3';
     collCustSett.Last_n_Days__c = 5;
     insert collCustSett;
     List<String> contactCountCodeList = collCustSett.Contact_Counter_Code__c.split(',');
      
     List<Product__c> prodList = new List<Product__c>();
	 Product__c prod1 = new Product__c();
     prod1.Name='Test Product1';
     prod1.Delinquency_Cycles__c=24;
     prod1.Delinquency_Days__c=7;
     prod1.No_of_times_contacted__c=17;
     prod1.No_of_times_contacted_in_current_cycle__c=7;
     prod1.No_of_times_contact_collection_in_n_days__c=18;
     prod1.Customer__c=acc1.id;
     prodList.add(prod1);
        
     Product__c prod2 = new Product__c();
     prod2.Name='Test Product2';
     prod2.Delinquency_Cycles__c=24;
     prod2.Delinquency_Days__c=7;
     prod2.No_of_times_contacted__c=17;
     prod2.No_of_times_contacted_in_current_cycle__c=7;
     prod2.No_of_times_contact_collection_in_n_days__c=18;
     prod2.Customer__c=acc2.id;
     prodList.add(prod2);
     insert prodList;
        
     List<Task> tasks=new List<Task>();   
     Task t1=new Task();
     t1.Subject='Send Email';
     //t1.WhatId = prod1.id;
     t1.Type_of_Activity__c='Collection';
     t1.Type__c='Outgoing';
     t1.CallType='Outbound';
     t1.WhatId=acc1.Id;
     tasks.add(t1);
        
     Task t2=new Task();
     t2.WhatId = prod2.id;
     t2.Subject='Print Email';
     t2.Type_of_Activity__c='Collection';
     t2.Type__c='incoming';
     t2.CallType='Outbound';
     t2.CallClassification1__c='Test';
     //t2.WhatId=prod2.Id;
     tasks.add(t2);
     insert tasks;
        
     Test.startTest();
     
     CollectionContactAccountBatch obj = new CollectionContactAccountBatch();
     DataBase.executeBatch(obj);
	 
     Test.stopTest();

     
 	}
}