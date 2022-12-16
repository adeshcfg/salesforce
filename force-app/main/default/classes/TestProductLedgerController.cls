@isTest
public class TestProductLedgerController {
    public static testMethod void testLedger(){
       
        //list<Pool__c> poolList = new list<Pool__c>();
        Placement__c plcmnt= new Placement__c();      
        plcmnt.Name= '89'; 
        plcmnt.Serviceable_Province__c = 'Nova Scotia';
        plcmnt.Agency_Name__c = 'CCS Agency';
        insert plcmnt;  
        
        
        Pool__c pool = new Pool__c();
        //pool.Name = 'P0001';
        pool.Placement_Agency__c = 89;
        pool.Placement_agency_lookup__c = plcmnt.id;
        pool.Id = ApexPages.currentPage().getParameters().get('id');   
        insert pool;
        
        //Product Record Creation
        Product__c prod=new Product__C();
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c = 101;
        prod.Current_Interest_Amount__c = 1000;
        prod.Current_Balance__c = 1101;
        prod.Pool_Name__c = pool.Id;
        prod.Collection_Agency__c = 89;
        //prod.Status__c = 'ON';
        prod.Status__c = 'Pending Recall';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Collection_Agency_Placement__c = plcmnt.id;
        prod.State__c = 'Nova Scotia';
        prod.Address_Line1__c = 'Add1';
        prod.Address_Line2__c = 'Add2';
        prod.City__c = 'City';
        prod.State__c = 'State';
        prod.Zip_Code__c = 'A11';
        prod.Country__c = 'Canada';
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = Date.today().addDays(-10);
        prod.Interest_Waived_Of_End_Date__c = Date.today().addDays(-5);
        prod.Previous_Interest_Rate__c = 0.25;
        ProductTriggerHandler.runProductTrigger = false;
        insert prod;
        prod.Current_Principal_Balance__c = 100;
        prod.Current_Interest_Amount__c = 1010;
        prod.Interest_Accrued_for_the_Day__c = 2;
        prod.Current_Balance__c = 1111;
        prod.Interest_Amount_Last_Calculated_Date__c = Date.today();
        prod.Judgment_Rate__c = 10;
        update prod;
        Product__c prod2 = new Product__c();
        prod2.Current_Principal_Balance__c = 100;
        prod2.Current_Interest_Amount__c = 1010;
        prod2.Interest_Accrued_for_the_Day__c = 2;
        prod2.Current_Balance__c = 1111;
        prod2.Interest_Amount_Last_Calculated_Date__c = Date.today();
        prod2.Judgment_Rate__c = 10;
        insert prod2;
        Product__c prod3 = new Product__c();
        prod3.Current_Principal_Balance__c = 100;
        prod3.Current_Interest_Amount__c = 1010;
        prod3.Interest_Accrued_for_the_Day__c = 2;
        prod3.Current_Balance__c = 1111;
        prod3.Interest_Amount_Last_Calculated_Date__c = Date.today();
        prod3.Judgment_Rate__c = 10;
        insert prod3;
        Product__c prod4 = new Product__c();
        prod4.Current_Principal_Balance__c = 100;
        prod4.Current_Interest_Amount__c = 1010;
        prod4.Interest_Accrued_for_the_Day__c = 2;
        prod4.Current_Balance__c = 1111;
        prod4.Interest_Amount_Last_Calculated_Date__c = Date.today();
        prod4.Judgment_Rate__c = 10;
        insert prod4;
        ProductTriggerHandler.runProductTrigger = true;
        
       
        Product_Payments__c prodPay = new Product_Payments__c();
        prodPay.Payment_Amount__c = 100;
        prodPay.Payment_Agency__c = '29';
        prodPay.CCS_Account__c = prod.ID;
        prodPay.Payment_Type__c = '1000';
        prodPay.Interest_Adjustment__c = 10;
        prodPay.Pre_Pay_Principal__c = 90;
        prodPay.Pre_Pay_Interest__c = 10;
        prodPay.Post_Pay_Interest__c = 20;
        prodPay.Post_Pay_Principal__c = 110;
        prodPay.Pay_Recoverable_Fee__c = 0;
        prodPay.Pay_Non_Recoverable_Fee__c = 0;
        prodPay.Principal_Payment_Amount__c = 10;
        prodPay.Interest_Payment_Amount__c = 10;
        prodPay.Balance_After_Payment__c = 1100;
        prodPay.Pay_NSF__c = '2';
        prodPay.Balance_Before_Payment__c = 1090;
        prodPay.Payment_Source__c = '1';
        insert prodPay;
        
        
        Product_Payments__c prodPay2 = new Product_Payments__c();
        prodPay2.Payment_Amount__c = -100;
        prodPay2.Payment_Agency__c = '29';
        prodPay2.CCS_Account__c = prod.ID;
        prodPay2.Payment_Type__c = '1003';
        prodPay2.Interest_Adjustment__c = 10;
        prodPay2.Pre_Pay_Principal__c = 90;
        prodPay2.Pre_Pay_Interest__c = 10;
        prodPay2.Post_Pay_Interest__c = 20;
        prodPay2.Post_Pay_Principal__c = 110;
        prodPay2.Pay_Recoverable_Fee__c = 0;
        prodPay2.Pay_Non_Recoverable_Fee__c = 0;
        prodPay2.Principal_Payment_Amount__c = 10;
        prodPay2.Interest_Payment_Amount__c = 10;
        prodPay2.Balance_After_Payment__c = 1100;
        prodPay2.Balance_Before_Payment__c = 1090;
        prodPay2.Pay_NSF__c = '0';
        prodPay2.Payment_Source__c = '1';
        insert prodPay2;
        
        Product__History prodHistory1 = new Product__History();
        prodHistory1.Field = 'Interest_Accrued_for_the_Day__c';
        prodHistory1.ParentId = prod.Id;
        //prodHistory1.OldValue = 10;
        //prodHistory1.NewValue = 10;
        insert prodHistory1;

        Product__History prodHistory2 = new Product__History();
        prodHistory2.Field = 'Current_Interest_Amount__c';
        prodHistory2.ParentId = prod.Id;
        //prodHistory2.OldValue = 100;
        //prodHistory2.NewValue = 110;
        insert prodHistory2;
        
        
        Product__History prodHistory3 = new Product__History();
        prodHistory3.Field = 'Current_Principal_Balance__c';
        prodHistory3.ParentId = prod.Id;
        //prodHistory3.OldValue = 1000;
        //prodHistory3.NewValue = 1010;
        insert prodHistory3;
        
        
        Product__History prodHistory4 = new Product__History();
        prodHistory4.Field = 'Current_Balance__c';
        prodHistory4.ParentId = prod.Id;
        //prodHistory4.OldValue = 1100;
        //prodHistory4.NewValue = 1110;
        insert prodHistory4;
        
        Product__History prodHistory5 = new Product__History();
        prodHistory5.Field = 'Interest_Amount_Last_Calculated_Date__c';
        prodHistory5.ParentId = prod.Id;
        //prodHistory5.OldValue = Date.today().addDays(-1);
        //prodHistory5.NewValue = Date.today();
        insert prodHistory5;
        
        Product__History prodHistory6 = new Product__History();
        prodHistory6.Field = 'Previous_Interest_Rate__c';
        prodHistory6.ParentId = prod.Id;
        //prodHistory5.OldValue = Date.today().addDays(-1);
        //prodHistory5.NewValue = Date.today();
        insert prodHistory6;
        
        
        Judgment__c judgment = new Judgment__c();
        judgment.Product_1__c = prod.Name;
        judgment.Product_2__c = prod2.Name;
        judgment.Product_3__c = prod3.Name;
        judgment.Product_4__c = prod4.Name;
        judgment.Agency_Initiated_Legal_Action__c = '89';
        judgment.Legal_Agency__c = '89';
        judgment.Balance_one__c = 5000;
        judgment.Suit_Amount_1__c = 5000;
        judgment.Interest_Rate_one__c = 10;
        
        judgment.Balance_two__c = 5000;
        judgment.Suit_Amount_2__c = 5000;
        judgment.Interest_Rate_two__c = 10;
        
        
        judgment.Balance_three__c = 5000;
        judgment.Suit_Amount_3__c = 5000;
        judgment.Interest_Rate_three__c = 10;
       
        judgment.Balance_four__c = 5000;
        judgment.Suit_Amount_4__c = 5000;
        judgment.Interest_Rate_four__c = 10;
        
        judgment.Legal_Status__c = 'Judgment';
        judgment.Legal_Sub_Status__c = 'Claim Issued';
        judgment.Judgment_Balance__c = 5000;
        judgment.Judgment_Date__c = Date.today().addDays(-10);
        insert judgment;
        
        Account_Judgment__c accJudgment = new Account_judgment__c();
        accJudgment.Judgment__c = judgment.ID;
        accJudgment.Product__c = prod.ID;
        insert accJudgment;
        
        Account_Judgment__c accJudgment2 = new Account_judgment__c();
        accJudgment2.Judgment__c = judgment.ID;
        accJudgment2.Product__c = prod2.ID;
        insert accJudgment2;
        
        Account_Judgment__c accJudgment3 = new Account_judgment__c();
        accJudgment3.Judgment__c = judgment.ID;
        accJudgment3.Product__c = prod3.ID;
        insert accJudgment3;
        
        Account_Judgment__c accJudgment4 = new Account_judgment__c();
        accJudgment4.Judgment__c = judgment.ID;
        accJudgment4.Product__c = prod4.ID;
        insert accJudgment4;
        
        
        PageReference pageRef = Page.ProductLedgerPage;//Observe how we set the Page here
		Test.setCurrentPage(pageRef);//Applying page context here
        ApexPages.currentPage().getParameters().put('id', prod.id);
        
        ProductLedgerController controller = new ProductLedgerController( new ApexPages.StandardController( prod ) );
    	
        controller.startDate = Date.today().addDays(-1);
        controller.endDate = Date.today().addDays(1);
        controller.getData();
        
        ApexPages.currentPage().getParameters().put('id', prod2.id);
        
        ProductLedgerController controller2 = new ProductLedgerController( new ApexPages.StandardController( prod2 ) );
    	
        controller2.startDate = Date.today().addDays(-1);
        controller2.endDate = Date.today().addDays(1);
        controller2.getData();
        
        ApexPages.currentPage().getParameters().put('id', prod3.id);
        
        ProductLedgerController controller3 = new ProductLedgerController( new ApexPages.StandardController( prod3 ) );
    	
        controller3.startDate = Date.today().addDays(-1);
        controller3.endDate = Date.today().addDays(1);
        controller3.getData();
        
        ApexPages.currentPage().getParameters().put('id', prod4.id);
        
        ProductLedgerController controller4 = new ProductLedgerController( new ApexPages.StandardController( prod4 ) );
    	
        controller4.startDate = Date.today().addDays(-1);
        controller4.endDate = Date.today().addDays(1);
        controller4.getData();
        
        system.debug('get data in test::'+[SELECT ParentId, OldValue, NewValue, Field, CreatedById, CreatedDate 
                                                     FROM Product__History
                                                     WHERE ParentId = :prod.id
                                                     AND (Field= :'Interest_Accrued_for_the_Day__c'
                                                          OR Field= :'Current_Interest_Amount__c'
                                                          OR Field= :'Current_Principal_Balance__c'
                                                          OR Field= :'Current_Balance__c'
                                                          OR Field= :'Interest_Amount_Last_Calculated_Date__c'
                                                         )]);
    }
}