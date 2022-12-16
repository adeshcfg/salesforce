@isTest
private class TestGenerateDepositSlipPDFController {
    
    @testSetup
    static void testData(){
        List<Deposit_Accounts__c> depAccList = new List<Deposit_Accounts__c>();
        Deposit_Accounts__c depAcc = new Deposit_Accounts__c();
        depAcc.Name = 'CIA';
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
        depAcc4.Name = 'ETC';
        depAcc4.Account_Number__c = '1004-631';
        depAcc4.Bank_Name__c = 'AFSI Term Loan Funding';
        depAcc4.Entity_Name__c= 'Affirm Financial Services Inc';
        depAcc4.Transit_Number__c = '32162';
        
        depAccList.add(depAcc);
        depAccList.add(depAcc1);
        depAccList.add(depAcc2);
        depAccList.add(depAcc3);
        depAccList.add(depAcc4);
        
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
        
        //list<Portfolio_Name__c> portfolioNameList = new list<Portfolio_Name__c>();
        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.name = 'AFSCARDS';
        portfolioName.Account_Purchasing_Entity_ID__c ='test';
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
        
        List<Remittance__c> remList = new List<Remittance__c>();
        Remittance__c rem = new Remittance__c();
        rem.Cheque_Amount__c = 460.90;
        rem.Cheque_Payment_Reference_Number__c = 'Ref123';
        rem.Status__c = 'New';
        rem.Payment_Posting_Date__c = System.today();
        
        Remittance__c rem1 = new Remittance__c();
        rem1.Cheque_Amount__c = 909.89;
        rem1.Cheque_Payment_Reference_Number__c = 'Ref321';
        rem1.Status__c = 'New';
        rem1.Payment_Posting_Date__c = System.today();
        
        Remittance__c rem2 = new Remittance__c();
        rem2.Cheque_Amount__c = 909.89;
        rem2.Cheque_Payment_Reference_Number__c = 'Ref456';
        rem2.Status__c = 'New';
        rem2.Payment_Posting_Date__c = System.today();
        
        Remittance__c rem3 = new Remittance__c();
        rem3.Cheque_Amount__c = 345.08;
        rem3.Cheque_Payment_Reference_Number__c = 'Ref654';
        rem3.Status__c = 'New';
        rem3.Payment_Posting_Date__c = System.today();
        
        Remittance__c rem4 = new Remittance__c();
        rem4.Cheque_Amount__c = 600;
        rem4.Cheque_Payment_Reference_Number__c = 'Ref789';
        rem4.Status__c = 'New';
        rem4.Payment_Posting_Date__c = System.today();
        
        
        remList.add(rem);
        remList.add(rem1);
        remList.add(rem2);
        remList.add(rem3);
        remList.add(rem4);
        INSERT remList;
        
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
        
        payList.add(insolPay);
        payList.add(insolPay1);
        payList.add(insolPay2);
        payList.add(insolPay3);
        INSERT payList;
        
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
        
        /*
        Test.startTest();
        GenerateDepositSlipPDFController genDepSlipPDFCon = new GenerateDepositSlipPDFController(); 
        genDepSlipPDFCon.GenerateSlipController(payList, unallocPayList, 'fortress');
        genDepSlipPDFCon.GenerateSlipController(payList, unallocPayList, 'CIHI');
        genDepSlipPDFCon.GenerateSlipController(payList, unallocPayList, 'Varde');
        genDepSlipPDFCon.GenerateSlipController(payList, unallocPayList, 'VardeCD');
        genDepSlipPDFCon.GenerateSlipController(payList, unallocPayList, 'Varde_Account_Perticulars');
        genDepSlipPDFCon.GenerateSlipController(payList, unallocPayList, 'Equitable');
        genDepSlipPDFCon.getPerticularsSize();
        Test.stopTest();
        */
    }  
}