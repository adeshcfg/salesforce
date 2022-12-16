/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for Generate DepositSlip implementation
 *  @author : A5E Consulting
 *  @date : 15/02/2019
 * 
 *************************************************************************************************/

@isTest
public class TestGenerateDepositProductPDFController{

    @testSetup
    static void testData(){
        
        Deposit_Slip__c dp = new Deposit_Slip__c();
        dp.recordTypeId = [select id from RecordType where SobjectType = 'Deposit_slip__C' and name like '%CCS%'].id;
        insert dp;
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(dp.Id, yesterday);
        
        Id accountTrusteeCompanyRtypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Trustee Company').getRecordTypeId();
        Account acc = new Account(Name='test', RecordTypeID = accountTrusteeCompanyRtypeId);
        insert acc;
        
         //Remittance record creation
        ID recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%CCS%'].id;
        Remittance__c remittance1 = new Remittance__c();
        remittance1.recordtypeid = recordTypeId;
        remittance1.Status__c = 'New';
        //remittance1.Email_to_Case_Reference_Number__c = caseObj.Id;
        remittance1.Trustee_name__c = acc.Id;
        remittance1.Cheque_Amount__c = 123.00;
        remittance1.Deposit_Account_Name__c = 'CIML';
        remittance1.Status__c='Processed';
        insert remittance1;
        Test.setCreatedDate(remittance1.Id, System.Today().addDays(2));
        
        //Remittance record creation
        Remittance__c remittance2 = new Remittance__c();
        remittance2.recordtypeid = recordTypeId;
        remittance2.Status__c = 'New';
        //remittance1.Email_to_Case_Reference_Number__c = caseObj.Id;
        remittance2.Trustee_name__c = acc.Id;
        remittance2.Cheque_Amount__c = 123.00;
        remittance2.Deposit_Account_Name__c = 'AFSI';
        remittance2.Status__c='Processed';
        insert remittance2;
        Test.setCreatedDate(remittance2.Id, System.Today().addDays(2));
        
        /*U //Insolvency Record
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        insert insolv1;
        */
        
        
        //Insolvency Account Record
        ID recordTypeIdProd = [select id from RecordType where SobjectType = 'Product__c' and name like '%CCS%'].id;
        Product__c insAcc1 = new Product__C();
        insAcc1.recordTypeid = recordTypeIdProd;
        /*insAcc1.Insolvency_Status__c = 'For Owner Review';
        insAcc1.Claim_Type__c = 'Unsecured';
        insAcc1.Insolvency__c = insolv1.id;*/
        insAcc1.Name = '123';
        insert insAcc1; 
        
         //Insolvency Account Record
        Product__c insAcc2 = new Product__C();
        insAcc2.recordTypeid = recordTypeIdProd;
        /*insAcc2.Insolvency_Status__c = 'For Owner Review';
        insAcc2.Claim_Type__c = 'Unsecured';
        insAcc2.Insolvency__c = insolv1.id;*/
        insAcc2.Name = '123';
        insert insAcc2; 
        
        
        //Payments
        Product_Payments__C payment1 = new Product_Payments__C();
        payment1.dividend__c = remittance1.Id;
        payment1.Payment_Amount__c = 1123.00;
        payment1.CCS_account__c = insAcc1.Id;
        insert payment1;
        
        //Payments
        Product_Payments__C payment2 = new Product_Payments__C();
        payment2.dividend__c = remittance2.Id;
        payment2.Payment_Amount__c = 1123.00;
        payment2.CCS_account__c = insAcc2.Id;
        insert payment2;
        
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
        
        INSERT depAccList;
        
        Unallocated_Payment__c unAlloc = new Unallocated_Payment__c(remittance__c = remittance1.ID, Allocated__c=false, Unallocated_Amount__c = 0.00);
        unalloc.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%ccs%'].id;
        insert unAlloc;
        Test.setCreatedDate(unAlloc.Id, System.Today().addDays(2));
    }
    
    
    //Test Controller
    static testMethod void testController(){
        ApexPages.currentPage().getParameters().put('type', 'AFF');
        GenerateDepositSlipProductPDFController obj = new GenerateDepositSlipProductPDFController();
        
        ApexPages.currentPage().getParameters().put('type', 'test');
        obj = new GenerateDepositSlipProductPDFController ();        
        
        ApexPages.currentPage().getParameters().put('type', 'AFSI');
        obj = new GenerateDepositSlipProductPDFController ();
        
        ApexPages.currentPage().getParameters().put('type', 'CLP');
        obj = new GenerateDepositSlipProductPDFController ();
        
        ApexPages.currentPage().getParameters().put('type', 'CIML');
        obj = new GenerateDepositSlipProductPDFController ();
        
        ApexPages.currentPage().getParameters().put('type', 'Canaccede_Account_Perticulars');
        obj = new GenerateDepositSlipProductPDFController ();
        
        Product_Payments__C insolvPay = [SELECT Id,Deposit_Account_Type__c FROM Product_Payments__C LIMIT 1];
        insolvPay.Deposit_Account_Type__c='AAL';
        update insolvPay;
        obj = new GenerateDepositSlipProductPDFController ();
        
        insolvPay.Deposit_Account_Type__c='ETC';
        update insolvPay;
        obj = new GenerateDepositSlipProductPDFController ();

        insolvPay.Deposit_Account_Type__c='AFF';
        update insolvPay;
        obj = new GenerateDepositSlipProductPDFController ();
        
        insolvPay.Deposit_Account_Type__c='AFL';
        update insolvPay;
        obj = new GenerateDepositSlipProductPDFController ();
        
        insolvPay.Deposit_Account_Type__c='CAL';
        update insolvPay;
        obj = new GenerateDepositSlipProductPDFController ();
        
        insolvPay.Deposit_Account_Type__c='CIH';
        update insolvPay;
        obj = new GenerateDepositSlipProductPDFController ();
        
        insolvPay.Deposit_Account_Type__c='CCL';
        update insolvPay;
        obj = new GenerateDepositSlipProductPDFController ();
        
        insolvPay.Deposit_Account_Type__c='CLP';
        update insolvPay;
        obj = new GenerateDepositSlipProductPDFController ();
        
        insolvPay.Deposit_Account_Type__c='CIA';
        update insolvPay;
        obj = new GenerateDepositSlipProductPDFController ();
    }
}