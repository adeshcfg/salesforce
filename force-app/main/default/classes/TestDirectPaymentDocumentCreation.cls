@isTest(seeAllData = false)
public class TestDirectPaymentDocumentCreation {
    public static testMethod void testDirectPayment(){
        Blob paymentFile;
        String workAssignmentID;
        String TaskNumber;
        String payAgency;
        String agencyID;
        String docUrl;
        String docId;
        
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c = 100;
        insert settings;   
        
          // inset the product and product payment//
        id rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
        decimal ComissionRate = 10;
        
        Product__c prod = new Product__c();
        Id recordid= [SELECT id,RecordType.developerName from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recordid;
        prod.Name = '12345';
        prod.Current_Interest_Amount__c=123;
        prod.Current_Principal_Balance__c=123;
        prod.Current_Balance__c=123;
        prod.RecordTypeId= rtid;
        prod.Value_Tier_at_Time_of_Placement__c= 'A+';
        prod.Collection_Agency__c=null;
        prod.Collection_Sub_Status__c='Pending Recall';
        prod.Commission_Rate__c= ComissionRate;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Recoverable_Fee__c = 0;
        prod.Non_Recoverable_Fee__c = 0;
        prod.Commission_Adjustment__c= 1;
        ProductTriggerHandler.runProductTrigger = false;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True;
        
        Placement__c plcmnt= new Placement__c();      
        plcmnt.Name= '89'; 
        plcmnt.Serviceable_Province__c = 'Nova Scotia';
        plcmnt.Agency_Name__c = 'CCS Agency';
        plcmnt.Commission_Rate__c = 3;
        insert plcmnt;
        
        List<Product_Payments__c> listProdPay = new  List<Product_Payments__c>();
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c= prod.id;
        prodpay.Payment_Type__c ='1900';
        prodpay.Payment_Amount__c= 1002;
        prodpay.Agency_Calculated_Comm__c=10;
        prodpay.Payment_Posting_Date__c= System.today();
        //prodpay.Commission_Amount__c = prodpay.Payment_Amount__c * (ComissionRate);
        prodpay.Payment_Provided_Agency__c = plcmnt.id;
        prodpay.Payment_Type__c= '3000';
        prodpay.Payment_Source__c='1';
       // ProductPaymentsTriggerHandler.runProductTrigger = false;
       listProdPay.add(prodpay);
        insert listProdPay;
        
       
        
             //create work assignment record 
                Work_Assignment__c workAssignment = new Work_Assignment__c();
                workAssignment.Requested_Date__c = Date.today();
                
               // workAssignment.Title__c = 'Direct Payment Notification for Placement ' + payAgency + '('+ mapAgencyNames.get(payAgency) + ') on ' 
                    				//	+ strDate;
             //   workAssignment.Description__c = 'Total Amount received from Direct Payment on Agency ' +payAgency + ' is: '+ mapAgencyTotalPayments.get(payAgency);
                workAssignment.Assign_To__c = 'Agency';
                workAssignment.Priority__c = 'Medium';
                workAssignment.Purpose__c = 'Payment';
                workAssignment.Sub_Purpose__c = 'Payment';
               // workAssignment.Placement_Agency__c = mapAgencyID.get(payAgency);
               // workAssignment.Placement_Agency_Identifier__c = payAgency;
               // workAssignment.RecordTypeID = portalSettings.Agency_Work_Assignment_RecordTypeID__c;
                workAssignment.Status__c = 'Completed';
                workAssignment.Notification_Type__c = 'Direct Payment';
               // workAssignment.Total_Amount_of_Payments__c = mapAgencyTotalPayments.get(payAgency);
                insert workAssignment;
        
            //Document Storage Record Creation
        Document_Storage__c docStor=new Document_Storage__c();
        docStor.Product__c=prod.id;
        docStor.Work_Assignment__c = workAssignment.id;
       // docStor.Judgment__c=judg.id;
        INSERT docStor;
        //Id ccsRecordTYpeId = CustomerProcessingBatchTest.getsObjectRecordTypeId('Product__c', 'CCS Account');
        Product__c prod2 = new Product__c(
                                        Name='1234512345123451234512345123459',
                                        //RecordTypeId =  ccsRecordTYpeId,
                                        Last_Name__c = 'last name of length2',
                                        First_Name__c = 'first name of length 25 c',
                                        Disbursement_Date__c = SYSTEM.Today(),
                                        Open_Date_EQ__c = SYSTEM.Today(), 
                                        Payment_Frequency__c = 'Weekly',
                                        Monthly_Payment_Amount__c = 1252.00,
                                        Current_Balance__c = 120.00,
                                        FairShare_Percentage__c = 12,
                                        Last_Payment_Amount__c = 123.00,
                                        CCS_Stage_Last_Changed__c = SYSTEM.Today(),
                                        Last_Payment_Date__c = SYSTEM.Today(),
                                        Middle_Name__c = 'middle name length20',
                                        SIN__c = '123456789',
                                        Phone_Home__c = '1234567890',
                                        Address_Line1__c = 'address1 of length 32 characters',
                                        Address_Line2__c = 'address2 of length 32 characters',
                                        City__c = 'NEWYORK CITY OF USUS',
                                        State__c = 'A',
                                        Provinces__c = 'Nova Scotia',
                                        Zip_Code__c = '123456789',
                                        Investment_Group__c = 'BNS CCS 1',
                                        Purchase_Date__c = SYSTEM.Today()
                                        );
        insert prod2;
        List<Product__c> prodList = [Select id from Product__c ]; 

        Product_Payments__c prod1 = new Product_Payments__c();
        prod1.Payment_Source__c = '2';
        prod1.Payment_Agency__c = '61';
        prod1.CCS_Account__c = prodList[0].Id;
		insert prod1;
        /*Product_Payments__c prod3 = new Product_Payments__c();
        prod1.Payment_Source__c = '2';
        prod1.Payment_Agency__c = '61';
        prod1.CCS_Account__c = prodList[0].Id;
		insert prod3;*/
        

        
    	//Database.executeBatch(new DirectPaymentNotificationBatch(), 200);
		/* DirectPaymentDocumentCreation.postDocumentAPI(paymentFile, workAssignmentID, TaskNumber, payAgency, agencyID,
                                       docUrl, docId);*/
        
        DirectPaymentDocumentCreation job = new DirectPaymentDocumentCreation();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Test', sch, job);
        Test.startTest();
        String finalstr = 'Test string';
 	   	 blob csvBlob = Blob.valueOf(finalstr);
        Placement__c plcmnt1 = [Select id from Placement__c limit 1];
        Work_Assignment__c work = [Select id from Work_Assignment__c limit 1];
		 DirectPaymentDocumentCreation.postDocumentAPI(csvBlob,work.Id, '93903904', '89', plcmnt1.id, 'tretrtw','behgdhe');
        Test.stopTest();
       
        
        
		
    }
        
   
    
}