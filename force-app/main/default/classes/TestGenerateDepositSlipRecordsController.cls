/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a controller class for Generate Deposit Slip. 
*  @author : A5E Consulting
*  @date : 10/01/2019

*************************************************************************************************/

@isTest
private class TestGenerateDepositSlipRecordsController {
    
    @testSetup
    static void testData(){
       
        Application_Config_Settings__c config = new Application_Config_Settings__c(
            Run_Remittance_Validation__c = false,
            Run_Remittance_Trigger__c = true,
            Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
            Run_Insolvency_Trigger__c = false,
            Run_Insolvency_Account_Duplicate_Check__c = true,
            Run_Insolvency_Account_Trigger__c = false,
            Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',
            Run_Insolvency_Status_Validations__c = true,
            Bank_Eligible_for_Duplicate_Check__c = 'SPL',
            Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm'
        );
        insert config; 
       
         List<Deposit_Accounts__c> depAccList = new List<Deposit_Accounts__c>();
        Deposit_Accounts__c depAcc = new Deposit_Accounts__c();
        depAcc.Name = 'CIML';
        depAcc.Account_Number__c = '1004-156';
        depAcc.Bank_Name__c = 'CIML Billing ';
        depAcc.Entity_Name__c= 'Canaccede International Management Ltd';
        depAcc.Transit_Number__c = '32162';
        
        Deposit_Accounts__c depAcc1 = new Deposit_Accounts__c();
        depAcc1.Name = 'CIH';
        depAcc1.Account_Number__c = '1004-877';
        depAcc1.Bank_Name__c = 'CIHI Billing';
        depAcc1.Entity_Name__c= 'Canaccede International Holdings Inc';
        depAcc1.Transit_Number__c = '32162';
        
        Deposit_Accounts__c depAcc2 = new Deposit_Accounts__c();
        depAcc2.Name = 'CCL';
        depAcc2.Account_Number__c = '1993-130';
        depAcc2.Bank_Name__c = 'Canaccede Credit LP Blocked ';
        depAcc2.Entity_Name__c= 'Canaccede Credit LP';
        depAcc2.Transit_Number__c = '03482';
        
        Deposit_Accounts__c depAcc3 = new Deposit_Accounts__c();
        depAcc3.Name = 'CAL';
        depAcc3.Account_Number__c = '1082-767';
        depAcc3.Bank_Name__c = 'CA LTD Blocked  ';
        depAcc3.Entity_Name__c= 'Canaccede Assets Ltd';
        depAcc3.Transit_Number__c = '03482';
        
        Deposit_Accounts__c depAcc4 = new Deposit_Accounts__c();
        depAcc4.Name = 'AAL';
        depAcc4.Account_Number__c = '1004-631';
        depAcc4.Bank_Name__c = 'AFSI Term Loan Funding';
        depAcc4.Entity_Name__c= 'Affirm Financial Services Inc';
        depAcc4.Transit_Number__c = '32162';
        
        Deposit_Accounts__c depAcc6 = new Deposit_Accounts__c();
        depAcc6.Name = 'AFL';
        depAcc6.Account_Number__c = '1004-631';
        depAcc6.Bank_Name__c = 'AFSI Term Loan Funding';
        depAcc6.Entity_Name__c= 'Affirm Financial Services Inc';
        depAcc6.Transit_Number__c = '32162';
        
        Deposit_Accounts__c depAcc5 = new Deposit_Accounts__c();
        depAcc5.Name = 'ETC';
        depAcc5.Account_Number__c = '1004-631';
        depAcc5.Bank_Name__c = 'AFSI Term Loan Funding';
        depAcc5.Entity_Name__c= 'Affirm Financial Services Inc';
        depAcc5.Transit_Number__c = '32162';
        
         Deposit_Accounts__c depAcc7 = new Deposit_Accounts__c();
        depAcc7.Name = 'AFF';
        depAcc7.Account_Number__c = '1004-631';
        depAcc7.Bank_Name__c = 'AFSI Term Loan Funding';
        depAcc7.Entity_Name__c= 'Affirm Financial Services Inc';
        depAcc7.Transit_Number__c = '32162';
        
        Deposit_Accounts__c depAcc8 = new Deposit_Accounts__c();
        depAcc8.Name = 'CLP';
        depAcc8.Account_Number__c = '1993-130';
        depAcc8.Bank_Name__c = 'Canaccede Credit LP Blocked ';
        depAcc8.Entity_Name__c= 'Canaccede Credit LP';
        depAcc8.Transit_Number__c = '03482';
        
        Deposit_Accounts__c depAcc9 = new Deposit_Accounts__c();
        depAcc9.Name = 'CIA';
        depAcc9.Account_Number__c = '1993-130';
        depAcc9.Bank_Name__c = 'Canaccede Credit LP Blocked ';
        depAcc9.Entity_Name__c= 'Canaccede Credit LP';
        depAcc9.Transit_Number__c = '03482';
        
        Deposit_Accounts__c dep = new Deposit_Accounts__c();
        dep.Name = 'AFSI';
        dep.Account_Number__c = '1993-130';
        dep.Bank_Name__c = 'Canaccede Credit LP Blocked ';
        dep.Entity_Name__c= 'Canaccede Credit LP';
        dep.Transit_Number__c = '03482';
        
        
        depAccList.add(depAcc);
        depAccList.add(depAcc1);
        depAccList.add(depAcc2);
        depAccList.add(depAcc3);
        depAccList.add(depAcc4);
        depAccList.add(depAcc5);
        depAccList.add(depAcc6);
        depAccList.add(depAcc7);
        depAccList.add(depAcc8);
        depAccList.add(depAcc9);
        depAccList.add(dep);
        
        INSERT depAccList;
    }
    static testMethod void GenerateDepositSlipPDFControllerTest(){
        //Insolvency Record
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        
        
        insolvList.add(insolv1);
        INSERT insolvlist;
        
        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.Account_Purchasing_Entity_ID__c = 'test';
        portfolioName.name = 'AFSCARDS';
        insert portfolioName;
        
        list<RecordType> recordTypeList = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Insolvency_Account__c']);
        //Insolvency Account records
        List<Insolvency_Account__c> iaList = new List<Insolvency_Account__c>();
        
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = recordTypeList[1].Id;
        ia1.Name = 'Test-001';
        ia1.Insolvency_Status__c = 'New';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Insolvency__c = insolv1.Id;
        ia1.Account_Number_Without_Space__c = 'Test-001';
        ia1.Portfolio_Group_Name__c = 'CCL001';
        ia1.Investment_Group__c = 'AFFIRM';
        ia1.Portfolio_Name_Lookup__c = portfolioName.id;
        
        Insolvency_Account__c ia2 = new Insolvency_Account__c();
        ia2.RecordTypeId = recordTypeList[1].Id;
        ia2.Name = 'Test-002';
        ia2.Insolvency_Status__c = 'New';
        ia2.Claim_Type__c = 'Unsecured';
        ia2.Insolvency__c = insolv1.Id;
        ia2.Account_Number_Without_Space__c = 'Test-002';
        ia2.Portfolio_Group_Name__c = 'CIH002';
        ia2.Investment_Group__c = 'AFFIRM';
        ia2.Portfolio_Name_Lookup__c = portfolioName.id;
        
        Insolvency_Account__c ia3 = new Insolvency_Account__c();
        ia3.RecordTypeId = recordTypeList[1].Id;
        ia3.Name = 'Test-003';
        ia3.Insolvency_Status__c = 'New';
        ia3.Claim_Type__c = 'Unsecured';
        ia3.Insolvency__c = insolv1.Id;
        ia3.Account_Number_Without_Space__c = 'Test-003';
        ia3.Portfolio_Group_Name__c = 'CIA002';
        ia3.Investment_Group__c = 'AFFIRM';
        ia3.Portfolio_Name_Lookup__c = portfolioName.id;
        
        Insolvency_Account__c ia4 = new Insolvency_Account__c();
        ia4.RecordTypeId = recordTypeList[1].Id;
        ia4.Name = 'Test-004';
        ia4.Insolvency_Status__c = 'New';
        ia4.Claim_Type__c = 'Unsecured';
        ia4.Insolvency__c = insolv1.Id;
        ia4.Account_Number_Without_Space__c = 'Test-004';
        ia4.Portfolio_Group_Name__c = 'CAL004';
        ia4.Investment_Group__c = 'AFFIRM';
        ia4.Portfolio_Name_Lookup__c = portfolioName.id;
        
        Insolvency_Account__c ia5 = new Insolvency_Account__c();
        ia5.RecordTypeId = recordTypeList[1].Id;
        ia5.Name = 'Test-005';
        ia5.Insolvency_Status__c = 'New';
        ia5.Claim_Type__c = 'Unsecured';
        ia5.Insolvency__c = insolv1.Id;
        ia5.Account_Number_Without_Space__c = 'Test-005';
        ia5.Portfolio_Group_Name__c = 'ETC001';
        ia5.Investment_Group__c = 'AFFIRM';
        ia5.Portfolio_Name_Lookup__c = portfolioName.id;
        
        iaList.add(ia1);
        iaList.add(ia2);
        iaList.add(ia3);
        iaList.add(ia4);
        iaList.add(ia5);
        INSERT iaList;
        
        // Dividend records
        list<RecordType> recordTypeListDividend = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='remittance__c' and name like 'Insolvency%' ]);
        List<Remittance__c> remList = new List<Remittance__c>();
        Remittance__c rem = new Remittance__c();
        rem.recordTypeid = recordTypeListDividend[0].id;
        rem.Cheque_Amount__c = 460.90;
        rem.Cheque_Payment_Reference_Number__c = 'Ref123';
        rem.Status__c = 'Processed';
        rem.Bank_Account_Number__c = 'Canaccede Credit LP Blocked';
        rem.Deposit_Account_Name__c = 'ETC';
        rem.Payment_Posting_Date__c = System.today();
        
        Remittance__c rem1 = new Remittance__c();
        rem1.recordTypeid = recordTypeListDividend[0].id;
        rem1.Cheque_Amount__c = 909.89;
        rem1.Cheque_Payment_Reference_Number__c = 'Ref321';
        rem1.Status__c = 'Processed';
        rem1.Payment_Posting_Date__c = System.today();
        rem1.Deposit_Account_Name__c = 'AAL';
        
        
        Remittance__c rem2 = new Remittance__c();
        rem2.recordTypeid = recordTypeListDividend[0].id;
        rem2.Cheque_Amount__c = 909.89;
        rem2.Cheque_Payment_Reference_Number__c = 'Ref456';
        rem2.Status__c = 'Processed';
        rem2.Payment_Posting_Date__c = System.today();
        rem2.Deposit_Account_Name__c = 'AFSI';
        
        Remittance__c rem3 = new Remittance__c();
        rem3.recordTypeid = recordTypeListDividend[0].id;
        rem3.Cheque_Amount__c = 345.08;
        rem3.Cheque_Payment_Reference_Number__c = 'Ref654';
        rem3.Status__c = 'Processed';
        rem3.Payment_Posting_Date__c = System.today();
        rem3.Bank_Account_Number__c = 'CIML Billing';
        rem3.Deposit_Account_Name__c = 'CIML';
        
        Remittance__c rem4 = new Remittance__c();
        rem4.recordTypeid = recordTypeListDividend[0].id;
        rem4.Cheque_Amount__c = 600;
        rem4.Cheque_Payment_Reference_Number__c = 'Ref789';
        rem4.Status__c = 'Processed';
        rem4.Payment_Posting_Date__c = System.today();
        rem4.Deposit_Account_Name__c = 'AFL';
        
        
        Remittance__c rem5 = new Remittance__c();
        rem5.recordTypeid = recordTypeListDividend[0].id;
        rem5.Cheque_Amount__c = 600;
        rem5.Cheque_Payment_Reference_Number__c = 'Ref789';
        rem5.Status__c = 'Processed';
        rem5.Payment_Posting_Date__c = System.today();
        rem5.Deposit_Account_Name__c = 'CAL';
        
        
        Remittance__c rem6 = new Remittance__c();
        rem6.recordTypeid = recordTypeListDividend[0].id;
        rem6.Cheque_Amount__c = 600;
        rem6.Cheque_Payment_Reference_Number__c = 'Ref789';
        rem6.Status__c = 'Processed';
        rem6.Payment_Posting_Date__c = System.today();
        rem6.Deposit_Account_Name__c = 'CIH';
        
        
        Remittance__c rem7 = new Remittance__c();
        rem7.recordTypeid = recordTypeListDividend[0].id;
        rem7.Cheque_Amount__c = 600;
        rem7.Cheque_Payment_Reference_Number__c = 'Ref789';
        rem7.Status__c = 'Processed';
        rem7.Payment_Posting_Date__c = System.today();
        rem7.Deposit_Account_Name__c = 'CCL';
        
        
        Remittance__c rem8 = new Remittance__c();
        rem8.recordTypeid = recordTypeListDividend[0].id;
        rem8.Cheque_Amount__c = 600;
        rem8.Cheque_Payment_Reference_Number__c = 'Ref789';
        rem8.Status__c = 'Processed';
        rem8.Payment_Posting_Date__c = System.today();
        rem8.Deposit_Account_Name__c = 'CIA';
        
        remList.add(rem);
        remList.add(rem1);
        remList.add(rem2);
        remList.add(rem3);
        remList.add(rem4);
        remList.add(rem5);
        remList.add(rem6);
        remList.add(rem7);
        remList.add(rem8);
        INSERT remList;
        
        Test.setCreatedDate(rem2.Id, System.Today().addDays(2));
        Test.setCreatedDate(rem3.Id, System.Today().addDays(2));
        
        // Insolvency Payment records       
        List<Insolvency_payment__c> payList = new List<Insolvency_payment__c>();
        Insolvency_payment__c insolPay =new Insolvency_payment__c();
        insolPay.Cheque_Payment_Reference_Number__c = 'Ref123';
        insolPay.Insolvency_Account__c = iaList[0].id;
        insolPay.Payment_Amount__c = 460.90;
        insolPay.Remittance__c = remList[0].Id;
        insolPay.Payment_Posting_Date__c = System.today();
        
        Insolvency_payment__c insolPay1 =new Insolvency_payment__c();
        insolPay1.Cheque_Payment_Reference_Number__c = 'Ref321';
        insolPay1.Insolvency_Account__c = iaList[1].id;
        insolPay1.Payment_Amount__c = 909.89;
        insolPay1.Remittance__c = remList[1].Id;
        insolPay1.Payment_Posting_Date__c = System.today();
        
        Insolvency_payment__c insolPay2 =new Insolvency_payment__c();
        insolPay2.Cheque_Payment_Reference_Number__c = 'Ref456';
        insolPay2.Insolvency_Account__c = iaList[2].id;
        insolPay2.Payment_Amount__c = 700;
        insolPay2.Remittance__c = remList[2].Id;
        insolPay2.Payment_Posting_Date__c = System.today();
        
        Insolvency_payment__c insolPay3 =new Insolvency_payment__c();
        insolPay3.Cheque_Payment_Reference_Number__c = 'Ref654';
        insolPay3.Insolvency_Account__c = iaList[3].id;
        insolPay3.Payment_Amount__c = 800;
        insolPay3.Remittance__c = remList[3].Id;
        insolPay3.Payment_Posting_Date__c = System.today();
        
        Insolvency_payment__c insolPay4 =new Insolvency_payment__c();
        insolPay4.Cheque_Payment_Reference_Number__c = 'Ref789';
        insolPay4.Insolvency_Account__c = iaList[4].id;
        insolPay4.Payment_Amount__c = 900;
        insolPay4.Remittance__c = remList[4].Id;
        insolPay4.Payment_Posting_Date__c = System.today();
        
        payList.add(insolPay);
        payList.add(insolPay1);
        payList.add(insolPay2);
        payList.add(insolPay3);
        payList.add(insolPay4);
        INSERT payList;
        
        // Unallocated Payment records      
        List<Unallocated_Payment__c> unallocPayList = new List<Unallocated_Payment__c>();
        Unallocated_Payment__c unallocPay = new Unallocated_Payment__c();
        unallocPay.Unallocated_Amount__c = 100;
        unallocPay.Remittance__c = remList[0].Id;
        
        Unallocated_Payment__c unallocPay1 = new Unallocated_Payment__c();
        unallocPay1.Unallocated_Amount__c = 350;
        unallocPay1.Remittance__c = remList[1].Id;
        
        Unallocated_Payment__c unallocPay2 = new Unallocated_Payment__c();
        unallocPay2.Unallocated_Amount__c = 150.90;
        unallocPay2.Remittance__c = remList[2].Id;
        
        Unallocated_Payment__c unallocPay3 = new Unallocated_Payment__c();
        unallocPay3.Unallocated_Amount__c = 200.50;
        unallocPay3.Remittance__c = remList[3].Id;
        
        unallocPayList.add(unallocPay);
        unallocPayList.add(unallocPay1);
        unallocPayList.add(unallocPay2);
        unallocPayList.add(unallocPay3);
        
        INSERT unallocPayList;
        GenerateDepositSlipRecordsController genDepSlipRecCon = new GenerateDepositSlipRecordsController(); 
        
        //Created Deposit Slip   
        Deposit_Slip__c depSlip1 = new Deposit_Slip__c();
        depSlip1.Total_Accounts__c = 5;
        depSlip1.recordTypeId = [select id from RecordType where SobjectType = 'Deposit_Slip__C' and name like '%Insolvency%'].id;
        //depSlip1.Total_CIHI_Accounts__c = 1;
        //depSlip1.Total_Equitable_Accounts__c = 1;
        //depSlip1.Total_Fortress_Accounts__c = 1;
        //depSlip1.Total_Varde_CD_Accounts__c = 1;
        INSERT depSlip1; 
        
        genDepSlipRecCon = new GenerateDepositSlipRecordsController(); 
         
        Test.startTest();
        //GenerateDepositSlipRecordsController.fetchVardeRecords();
        //genDepSlipRecCon.fetchUnallocatedPayments();
        //genDepSlipRecCon.fetchVardeRemittance();
        //GenerateDepositSlipRecordsController.fetchRecords('CCL');
        //GenerateDepositSlipRecordsController.fetchRecords('ETC');
        genDepSlipRecCon.generateDepositSlip();
        DateTime datime = System.now();
        GenerateDepositSlipRecordsController.strCreatedDate(datime);
        
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Final_Deposit_Slip__c = system.today();
        update config;  
        genDepSlipRecCon = new GenerateDepositSlipRecordsController(); 
        
        genDepSlipRecCon.generateDepositSlip();
        GenerateDepositSlipRecordsController.idToStringConvert(new List<String>{'String'});
        
        genDepSlipRecCon.finalDepositSlip();
        delete [select id from Unallocated_Payment__c];
        delete [SELECT Id FROM Remittance__c];
        genDepSlipRecCon.generateDepositSlip();
        Test.stopTest();
        
         
    }  
}