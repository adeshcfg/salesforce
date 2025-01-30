@isTest
public class TestStatuteDateUtilities {
	static testMethod void productBeforeUpdateTest(){
        Statute_Date_Update__mdt mdt = new Statute_Date_Update__mdt();
        mdt.Months__c = 10;
        mdt.MasterLabel = 'Manitoba';
        
                
         Pool__c pool = new Pool__c();
         //pool.Name = 'Test';
         pool.Placement_Agency__c = 89;
         Insert pool;
        
        Pool__c pool1 = new Pool__c();
         //pool.Name = 'Test';
         pool1.Placement_Agency__c = 29;
         Insert pool1;
        
        Placement__c plcgy1 = new  Placement__c();      
        plcgy1.Name='30';
        plcgy1.Agency_Email__c = 'test@gmail.com';
         insert plcgy1;
        
          Placement__c plcgy2= new  Placement__c();      
        plcgy2.Name='40';
        plcgy2.Agency_Email__c = 'test@gmail.com';
        insert plcgy2;
        
        Product__c prod = new Product__c();
        prod.name = '123451212';
        prod.Payment_Setup_Status__c = 'Automated';
        prod.Funding_Status__c = 'Released Batch';
        prod.Funding_Type__c = 'Automated';
        prod.Disbursement_Amount__c = 2000.00;
        prod.Current_Balance__c = 7000;
        prod.Current_Principal_Balance__c = 5000;
        prod.Current_Interest_Amount__c = 2000;
        prod.Current_Workflow__c = 'Collection Process';
        prod.Requested_Close_Date__c = System.Today();
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Last_Name__c = 'xyz';
        prod.Pool_Name__c = pool.id;
        prod.Collection_Agency__c = 30;
        prod.Placement_Status__c = '100010';
        prod.Purchase_Status__c = 'Buyback/Putback Initiated';
        prod.Open_Date__c = Date.newInstance(2022, 12, 5);
        prod.state__c = 'Manitoba';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId();
        insert prod;
       
        
        
        Product__c prod2= new Product__c();
        List<User> systemName=[Select Name from User where Name ='System API'];
        prod2.name = '12345';
        prod2.Internal_Status__c = 'Active';
        prod2.Payment_Setup_Status__c = 'Automated';
        prod2.Funding_Status__c = 'Funded';
        prod2.Funding_Type__c = 'Automated';
        prod2.Disbursement_Amount__c = 3000.00;
        prod2.Collection_Agency__c = 30;
        prod2.Current_Balance__c = 7730;
        prod2.Current_Principal_Balance__c = 5000;
        prod2.Current_Interest_Amount__c = 2730;
        prod2.product_status__C = '310000';
        prod2.Current_Workflow__c = 'Collection Process';
        prod2.Requested_Close_Date__c = System.Today();
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.Last_Name__c = 'xyz';
        prod2.Pool_Name__c = pool.id;
        prod2.Placement_Status__c = '100010';
        prod2.Credit_Counselling_Date__c =null;
        prod2.Purchase_Status__c = 'Buyback/Putback Submitted to Seller';
        prod2.Last_Payment_Date__c = Date.newInstance(2016, 12, 5);
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        //prod2.Insolvency_Date__c =Date.newInstance(2016, 12, 9);
        insert prod2;
    
        
        
        List<Product__c> prodList = new List<Product__c>();
   
        product__c prod3 = new product__c();
        prod3.Id = Prod2.Id;
        prod3.Collection_Agency__c = 40;
        prod3.Funding_Status__c = 'Released';
        prod3.Product_Status__c = 'Test';
        system.debug('prod2'+prod2);
        prod3.Status__c = 'In Process';
        prod3.Sub_Status__c = 'Initial Letter Sent';
        prod3.Placement_Status__c = '100010';
        prod3.Invalid_Submission__c = true;
        prod3.Refer_to_Legal__c = 'Approved';
        prod3.Last_Name__c = 'xyz';
        prod3.State__c = 'MB';
        prod3.Pool_Name__c = pool1.id;
        prod3.Collection_Sub_Status__c = 'Buy back/put back and sale categories';
        prod3.Interest_Rate__c = 5;
        prod3.Insolvency_Date__c = Date.newInstance(2016, 12, 9);
        prod3.Deceased_Date__c = Date.newInstance(2016, 12, 9);
        prod3.Credit_Counselling_Date__c = Date.newInstance(2016, 12, 9);
        prod3.Last_Payment_Date__c = Date.newInstance(2022, 8, 9);
        //prod3.Date_for_Stat_Barred_calculations__c = Date.newInstance(2022, 8, 9);
        prod3.Statute_Date__c = Date.newInstance(2022, 12, 15);
        prod3.Open_Date__c = Date.newInstance(2022, 12, 9);
        prod3.Purchase_Status__c = 'Buyback/Putback Initiated';
        prod3.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        //update prod2;
        system.debug('prod2'+prod2);
        
        product__c prod4 = new product__c();
        prod4.id = prod.ID;
        prod4.Disbursement_Amount__c = 1000.00;
        prod4.Collection_Agency__c = null;
        prod4.Placement_Status__c = 'Testing';
        prod4.Status__c = 'In Process';
        prod4.Pool_Name__c = pool.id;
        prod4.Refer_to_Legal__c = 'Declined';
        prod4.Open_Date__c = Date.newInstance(2022, 12, 9);
        prod4.Statute_Date__c = Date.newInstance(2022, 12, 15);
        prod4.State__c = 'Alberta';
        prod4.Collection_Sub_Status__c = 'Buy back/put back and sale categories';
        prod4.Purchase_Status__c = 'Buyback/Putback Initiated';
        //update prod;
        
        product__c prod5 = new product__c();
        prod5.id = prod2.ID;
        prod5.Disbursement_Amount__c = 1000.00;
        prod5.Collection_Agency__c = 40;
        prod5.Placement_Status__c = 'Testing';
        prod5.Status__c = 'In Process';
        prod5.Pool_Name__c = pool.id;
        prod5.Refer_to_Legal__c = 'Declined';
        prod5.Last_Payment_Date__c = Date.newInstance(2022, 10, 9);
        prod5.Statute_Date__c = Date.newInstance(2022, 12, 15);
        prod5.Collection_Sub_Status__c = 'Buy back/put back and sale categories';
        prod5.Purchase_Status__c = 'Buyback/Putback Initiated';
        
        
        
        prodList.add(prod3);
        prodList.add(prod5);
		prodList.add(prod4);

        StatuteDateUtilities.loadStatuteDataFromMetadata();
        StatuteDateUtilities.getStatueDate(Date.newInstance(2022, 8, 15),Date.newInstance(2022, 12, 15),Date.newInstance(2022, 12, 15),Date.newInstance(2022, 12, 15),'Manitoba');
        StatuteDateUtilities.getStatueDate(Date.newInstance(2022, 10, 15),Date.newInstance(2022, 12, 15),Date.newInstance(2022, 12, 15),Date.newInstance(2022, 12, 15),'Manitoba');
    }
    
    static testMethod void productBeforeUpdateTest1(){
        Statute_Date_Update__mdt mdt = new Statute_Date_Update__mdt();
        mdt.Months__c = 10;
        mdt.MasterLabel = 'Alberta';
        
         Pool__c pool = new Pool__c();
         //pool.Name = 'Test';
         pool.Placement_Agency__c = 89;
         Insert pool;
        
        Pool__c pool1 = new Pool__c();
         //pool.Name = 'Test';
         pool1.Placement_Agency__c = 29;
         Insert pool1;
        
        Placement__c plcgy1 = new  Placement__c();      
        plcgy1.Name='30';
        plcgy1.Agency_Email__c = 'test@gmail.com';
         insert plcgy1;
        
          Placement__c plcgy2= new  Placement__c();      
        plcgy2.Name='40';
        plcgy2.Agency_Email__c = 'test@gmail.com';
        insert plcgy2;
        
        Product__c prod = new Product__c();
        prod.name = '123451212';
        prod.Payment_Setup_Status__c = 'Automated';
        prod.Funding_Status__c = 'Released Batch';
        prod.Funding_Type__c = 'Automated';
        prod.Disbursement_Amount__c = 2000.00;
        prod.Current_Balance__c = 7000;
        prod.Current_Principal_Balance__c = 5000;
        prod.Current_Interest_Amount__c = 2000;
        prod.Current_Workflow__c = 'Collection Process';
        prod.Requested_Close_Date__c = System.Today();
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Last_Name__c = 'xyz';
        prod.Pool_Name__c = pool.id;
        prod.Collection_Agency__c = 30;
        prod.Placement_Status__c = '100010';
        prod.Purchase_Status__c = 'Buyback/Putback Initiated';
        prod.Open_Date__c = Date.newInstance(2022, 12, 5);
        prod.state__c = 'Alberta';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId();
        insert prod;
       
        
        
        Product__c prod2= new Product__c();
        List<User> systemName=[Select Name from User where Name ='System API'];
        prod2.name = '12345';
        prod2.Internal_Status__c = 'Active';
        prod2.Payment_Setup_Status__c = 'Automated';
        prod2.Funding_Status__c = 'Funded';
        prod2.Funding_Type__c = 'Automated';
        prod2.Disbursement_Amount__c = 3000.00;
        prod2.Collection_Agency__c = 30;
        prod2.Current_Balance__c = 7730;
        prod2.Current_Principal_Balance__c = 5000;
        prod2.Current_Interest_Amount__c = 2730;
        prod2.product_status__C = '310000';
        prod2.Current_Workflow__c = 'Collection Process';
        prod2.Requested_Close_Date__c = System.Today();
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.Last_Name__c = 'xyz';
        prod2.Pool_Name__c = pool.id;
        prod2.Placement_Status__c = '100010';
        prod2.Credit_Counselling_Date__c =null;
        prod2.Purchase_Status__c = 'Buyback/Putback Submitted to Seller';
        prod2.state__c = 'Alberta';
        prod2.Last_Payment_Date__c = Date.newInstance(2016, 12, 5);
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        //prod2.Insolvency_Date__c =Date.newInstance(2016, 12, 9);
        insert prod2;
    
        
        
        List<Product__c> prodList = new List<Product__c>();
   
        product__c prod3 = new product__c();
        prod3.Id = Prod2.Id;
        prod3.Collection_Agency__c = 40;
        prod3.Funding_Status__c = 'Released';
        prod3.Product_Status__c = 'Test';
        system.debug('prod2'+prod2);
        prod3.Status__c = 'In Process';
        prod3.Sub_Status__c = 'Initial Letter Sent';
        prod3.Placement_Status__c = '100010';
        prod3.Invalid_Submission__c = true;
        prod3.Refer_to_Legal__c = 'Approved';
        prod3.Last_Name__c = 'xyz';
        prod3.State__c = 'MB';
        prod3.Pool_Name__c = pool1.id;
        prod3.Collection_Sub_Status__c = 'Buy back/put back and sale categories';
        prod3.Interest_Rate__c = 5;
        prod3.Insolvency_Date__c = Date.newInstance(2016, 12, 9);
        prod3.Deceased_Date__c = Date.newInstance(2016, 12, 9);
        prod3.Credit_Counselling_Date__c = Date.newInstance(2016, 12, 9);
        prod3.Last_Payment_Date__c = Date.newInstance(2022, 8, 9);
        //prod3.Date_for_Stat_Barred_calculations__c = Date.newInstance(2022, 8, 9);
        prod3.Statute_Date__c = Date.newInstance(2022, 12, 15);
        prod3.Open_Date__c = Date.newInstance(2022, 12, 9);
        prod3.Purchase_Status__c = 'Buyback/Putback Initiated';
        prod3.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod3.state__c = 'Alberta';
        //update prod2;
        system.debug('prod2'+prod2);
        
        product__c prod4 = new product__c();
        prod4.id = prod.ID;
        prod4.Disbursement_Amount__c = 1000.00;
        prod4.Collection_Agency__c = null;
        prod4.Placement_Status__c = 'Testing';
        prod4.Status__c = 'In Process';
        prod4.Pool_Name__c = pool.id;
        prod4.Refer_to_Legal__c = 'Declined';
        prod4.Open_Date__c = Date.newInstance(2022, 12, 9);
        prod4.Statute_Date__c = Date.newInstance(2022, 12, 15);
        prod4.State__c = 'Alberta';
        prod4.Collection_Sub_Status__c = 'Buy back/put back and sale categories';
        prod4.Purchase_Status__c = 'Buyback/Putback Initiated';
        //update prod;
        
        product__c prod5 = new product__c();
        prod5.id = prod2.ID;
        prod5.Disbursement_Amount__c = 1000.00;
        prod5.Collection_Agency__c = 40;
        prod5.Placement_Status__c = 'Testing';
        prod5.Status__c = 'In Process';
        prod5.Pool_Name__c = pool.id;
        prod5.Refer_to_Legal__c = 'Declined';
        prod5.Last_Payment_Date__c = Date.newInstance(2022, 10, 9);
        prod5.Statute_Date__c = Date.newInstance(2022, 12, 15);
        prod5.Collection_Sub_Status__c = 'Buy back/put back and sale categories';
        prod5.Purchase_Status__c = 'Buyback/Putback Initiated';
        prod5.state__c = 'Alberta';
        
        
        
        prodList.add(prod3);
        prodList.add(prod5);
		prodList.add(prod4);

        
        StatuteDateUtilities.loadStatuteDataFromMetadata();
        StatuteDateUtilities.getStatueDate(Date.newInstance(2022, 8, 15),Date.newInstance(2022, 12, 15),Date.newInstance(2022, 12, 15),Date.newInstance(2022, 12, 15),'Alberta');  
    }
}