/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a controller class for Generate Deposit Slip for Product records. 
*  @author : A5E Consulting
*  @date : 10/01/2019

*************************************************************************************************/

@isTest
public class TestGenerateDepositSlipProductController {
    @testSetup
    static void testData() {
        Agency_Portal_Settings__c portalSettings = new Agency_Portal_Settings__c();
        portalSettings.Valid_Payment_Types__c = '3000,5000,1000,1001,1002,7000,4000,1003,7001,1004,4002,4003,5001,4001,3400,5003,5002';
        insert portalSettings;

        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Do_Not_Run_Payment_Validation__c = false;
        //config.Final_Deposit_Slip__c = system.today();
        insert config;

        List<Deposit_Accounts__c> depAccList = new List<Deposit_Accounts__c>();
        Deposit_Accounts__c depAcc = new Deposit_Accounts__c();
        depAcc.Name = 'CIML';
        depAcc.Account_Number__c = '1004-156';
        depAcc.Bank_Name__c = 'CIML Billing ';
        depAcc.Entity_Name__c = 'Canaccede International Management Ltd';
        depAcc.Transit_Number__c = '32162';

        Deposit_Accounts__c depAcc1 = new Deposit_Accounts__c();
        depAcc1.Name = 'CIH';
        depAcc1.Account_Number__c = '1004-877';
        depAcc1.Bank_Name__c = 'CIHI Billing';
        depAcc1.Entity_Name__c = 'Canaccede International Holdings Inc';
        depAcc1.Transit_Number__c = '32162';

        Deposit_Accounts__c depAcc2 = new Deposit_Accounts__c();
        depAcc2.Name = 'CCL';
        depAcc2.Account_Number__c = '1993-130';
        depAcc2.Bank_Name__c = 'Canaccede Credit LP Blocked ';
        depAcc2.Entity_Name__c = 'Canaccede Credit LP';
        depAcc2.Transit_Number__c = '03482';

        Deposit_Accounts__c depAcc3 = new Deposit_Accounts__c();
        depAcc3.Name = 'CAL';
        depAcc3.Account_Number__c = '1082-767';
        depAcc3.Bank_Name__c = 'CA LTD Blocked  ';
        depAcc3.Entity_Name__c = 'Canaccede Assets Ltd';
        depAcc3.Transit_Number__c = '03482';

        Deposit_Accounts__c depAcc4 = new Deposit_Accounts__c();
        depAcc4.Name = 'AAL';
        depAcc4.Account_Number__c = '1004-631';
        depAcc4.Bank_Name__c = 'AFSI Term Loan Funding';
        depAcc4.Entity_Name__c = 'Affirm Financial Services Inc';
        depAcc4.Transit_Number__c = '32162';

        Deposit_Accounts__c depAcc6 = new Deposit_Accounts__c();
        depAcc6.Name = 'AFL';
        depAcc6.Account_Number__c = '1004-631';
        depAcc6.Bank_Name__c = 'AFSI Term Loan Funding';
        depAcc6.Entity_Name__c = 'Affirm Financial Services Inc';
        depAcc6.Transit_Number__c = '32162';

        Deposit_Accounts__c depAcc5 = new Deposit_Accounts__c();
        depAcc5.Name = 'ETC';
        depAcc5.Account_Number__c = '1004-631';
        depAcc5.Bank_Name__c = 'AFSI Term Loan Funding';
        depAcc5.Entity_Name__c = 'Affirm Financial Services Inc';
        depAcc5.Transit_Number__c = '32162';

        Deposit_Accounts__c depAcc7 = new Deposit_Accounts__c();
        depAcc7.Name = 'AFF';
        depAcc7.Account_Number__c = '1004-631';
        depAcc7.Bank_Name__c = 'AFSI Term Loan Funding';
        depAcc7.Entity_Name__c = 'Affirm Financial Services Inc';
        depAcc7.Transit_Number__c = '32162';

        Deposit_Accounts__c depAcc8 = new Deposit_Accounts__c();
        depAcc8.Name = 'CLP';
        depAcc8.Account_Number__c = '1993-130';
        depAcc8.Bank_Name__c = 'Canaccede Credit LP Blocked ';
        depAcc8.Entity_Name__c = 'Canaccede Credit LP';
        depAcc8.Transit_Number__c = '03482';

        Deposit_Accounts__c depAcc9 = new Deposit_Accounts__c();
        depAcc9.Name = 'CIA';
        depAcc9.Account_Number__c = '1993-130';
        depAcc9.Bank_Name__c = 'Canaccede Credit LP Blocked ';
        depAcc9.Entity_Name__c = 'Canaccede Credit LP';
        depAcc9.Transit_Number__c = '03482';

        Deposit_Accounts__c dep = new Deposit_Accounts__c();
        dep.Name = 'AFSI';
        dep.Account_Number__c = '1993-130';
        dep.Bank_Name__c = 'Canaccede Credit LP Blocked ';
        dep.Entity_Name__c = 'Canaccede Credit LP';
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

        insert depAccList;
    }
    static testMethod void GenerateDepositSlipPDFControllerTest() {
        //Insolvency Record
        /*List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        
        
        insolvList.add(insolv1);
        INSERT insolvlist;*/

        list<RecordType> recordTypeList = new List<RecordType>([SELECT Id, Name FROM RecordType WHERE SobjectType = 'Product__C' AND name LIKE '%CCS%']);
        //Insolvency Account records
        List<Product__c> iaList = new List<Product__c>();

        Product__c ia1 = new Product__c();
        ia1.RecordTypeId = recordTypeList[0].Id;
        ia1.Name = 'Test-001';
        //ia1.Insolvency_Status__c = 'New';
        //ia1.Claim_Type__c = 'Unsecured';
        //ia1.Insolvency__c = insolv1.Id;
        //ia1.Account_Number_Without_Space__c = 'Test-001';
        ia1.Portfolio_Group_Name__c = 'CCL001';

        Product__c ia2 = new Product__c();
        ia2.RecordTypeId = recordTypeList[0].Id;
        ia2.Name = 'Test-002';
        /*ia2.Insolvency_Status__c = 'New';
        ia2.Claim_Type__c = 'Unsecured';
        ia2.Insolvency__c = insolv1.Id;
        ia2.Account_Number_Without_Space__c = 'Test-002';*/
        ia2.Portfolio_Group_Name__c = 'CIH002';

        Product__c ia3 = new Product__c();
        ia3.RecordTypeId = recordTypeList[0].Id;
        ia3.Name = 'Test-003';
        /*ia3.Insolvency_Status__c = 'New';
        ia3.Claim_Type__c = 'Unsecured';
        ia3.Insolvency__c = insolv1.Id;
        ia3.Account_Number_Without_Space__c = 'Test-003';*/
        ia3.Portfolio_Group_Name__c = 'CIA002';

        Product__c ia4 = new Product__c();
        ia4.RecordTypeId = recordTypeList[0].Id;
        ia4.Name = 'Test-004';
        /*ia4.Insolvency_Status__c = 'New';
        ia4.Claim_Type__c = 'Unsecured';
        ia4.Insolvency__c = insolv1.Id;
        ia4.Account_Number_Without_Space__c = 'Test-004';*/
        ia4.Portfolio_Group_Name__c = 'CAL004';

        Product__c ia5 = new Product__c();
        ia5.RecordTypeId = recordTypeList[0].Id;
        ia5.Name = 'Test-005';
        /*ia5.Insolvency_Status__c = 'New';
        ia5.Claim_Type__c = 'Unsecured';
        ia5.Insolvency__c = insolv1.Id;
        ia5.Account_Number_Without_Space__c = 'Test-005';*/
        ia5.Portfolio_Group_Name__c = 'ETC001';

        iaList.add(ia1);
        iaList.add(ia2);
        iaList.add(ia3);
        iaList.add(ia4);
        iaList.add(ia5);
        insert iaList;

        // Dividend records
        list<RecordType> recordTypeListDividend = new List<RecordType>(
            [SELECT Id, Name FROM RecordType WHERE SobjectType = 'remittance__c' AND name LIKE '%CCS%']
        );
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
        insert remList;

        Test.setCreatedDate(rem2.Id, System.Today().addDays(2));
        Test.setCreatedDate(rem3.Id, System.Today().addDays(2));

        // Insolvency Payment records
        List<Product_Payments__C> payList = new List<Product_Payments__C>();
        Product_Payments__C insolPay = new Product_Payments__C();
        //insolPay.Cheque_Payment_Reference_Number__c = 'Ref123';
        insolPay.CCS_Account__c = iaList[0].id;
        insolPay.Payment_Amount__c = 460.90;
        insolPay.dividend__c = remList[0].Id;
        insolPay.Payment_Posting_Date__c = System.today();
        insolPay.Payment_Type__c = '1000';
        insolPay.Payment_Source__c = '1';

        Product_Payments__C insolPay1 = new Product_Payments__C();
        //insolPay1.Cheque_Payment_Reference_Number__c = 'Ref321';
        insolPay1.CCS_Account__c = iaList[1].id;
        insolPay1.Payment_Amount__c = 909.89;
        insolPay1.dividend__c = remList[1].Id;
        insolPay1.Payment_Posting_Date__c = System.today();
        insolPay1.Payment_Type__c = '1000';
        insolPay1.Payment_Source__c = '1';

        Product_Payments__C insolPay2 = new Product_Payments__C();
        //insolPay2.Cheque_Payment_Reference_Number__c = 'Ref456';
        insolPay2.CCS_Account__c = iaList[2].id;
        insolPay2.Payment_Amount__c = 700;
        insolPay2.dividend__c = remList[2].Id;
        insolPay2.Payment_Posting_Date__c = System.today();
        insolPay2.Payment_Type__c = '1000';
        insolPay2.Payment_Source__c = '1';

        Product_Payments__C insolPay3 = new Product_Payments__C();
        //insolPay3.Cheque_Payment_Reference_Number__c = 'Ref654';
        insolPay3.CCS_Account__c = iaList[3].id;
        insolPay3.Payment_Amount__c = 800;
        insolPay3.dividend__c = remList[3].Id;
        insolPay3.Payment_Posting_Date__c = System.today();
        insolPay3.Payment_Type__c = '1000';
        insolPay3.Payment_Source__c = '1';

        Product_Payments__C insolPay4 = new Product_Payments__C();
        //insolPay4.Cheque_Payment_Reference_Number__c = 'Ref789';
        insolPay4.CCS_Account__c = iaList[4].id;
        insolPay4.Payment_Amount__c = 900;
        insolPay4.dividend__c = remList[4].Id;
        insolPay4.Payment_Posting_Date__c = System.today();
        insolPay4.Payment_Type__c = '1000';
        insolPay4.Payment_Source__c = '1';

        payList.add(insolPay);
        payList.add(insolPay1);
        payList.add(insolPay2);
        payList.add(insolPay3);
        payList.add(insolPay4);
        insert payList;

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

        insert unallocPayList;
        GenerateDepositSlipProductController genDepSlipRecCon = new GenerateDepositSlipProductController();

        //Created Deposit Slip
        Deposit_Slip__c depSlip1 = new Deposit_Slip__c();
        depSlip1.Total_Accounts__c = 5;
        depSlip1.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'Deposit_Slip__C' AND name LIKE '%CCS%'].id;
        //depSlip1.Total_CIHI_Accounts__c = 1;
        //depSlip1.Total_Equitable_Accounts__c = 1;
        //depSlip1.Total_Fortress_Accounts__c = 1;
        //depSlip1.Total_Varde_CD_Accounts__c = 1;
        insert depSlip1;

        genDepSlipRecCon = new GenerateDepositSlipProductController();

        Test.startTest();
        //GenerateDepositSlipRecordsController.fetchVardeRecords();
        //genDepSlipRecCon.fetchUnallocatedPayments();
        //genDepSlipRecCon.fetchVardeRemittance();
        //GenerateDepositSlipRecordsController.fetchRecords('CCL');
        //GenerateDepositSlipRecordsController.fetchRecords('ETC');
        genDepSlipRecCon.generateDepositSlip();
        DateTime datime = System.now();
        GenerateDepositSlipProductController.strCreatedDate(datime);

        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.CCS_Final_Deposit_Slip__c = system.today();
        update config;
        genDepSlipRecCon = new GenerateDepositSlipProductController();

        genDepSlipRecCon.generateDepositSlip();
        GenerateDepositSlipProductController.idToStringConvert(new List<String>{ 'String' });

        genDepSlipRecCon.finalDepositSlip();
        delete [SELECT id FROM Unallocated_Payment__c];
        delete [SELECT Id FROM Remittance__c];
        genDepSlipRecCon.generateDepositSlip();
        Test.stopTest();
    }
}
