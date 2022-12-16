/**************************************************************************************************
 *
 *  Class:    TestInsolvencyViewController
 *
 *  @description : Allow team to inline edit insolvency
 *  @author : A5E Consulting
 *  @date : 07/20/2020
 
 *************************************************************************************************/
@isTest
public class TestInsolvencyViewController {
    public static testmethod void testInlineEdit(){
	Account account = new Account(name ='Grazitti');
    insert account; 
       
    Contact contact = new Contact(LastName ='testCon',AccountId = account.Id);
    insert contact; 
    
    Id profileId = [select id from profile where name='SDA Community User'].id;
     User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
                ContactId = contact.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        Insolvency__c insolv=new Insolvency__c();
		insolv.Name='1000000';
		insolv.Insolvency_Type__c='Bankruptcy';
		insolv.Insolvency_Received_Date__c=system.today();
		insolv.Insolvency_Date__c=system.today();
		insolv.Debtor_1_Mailing_State_Province__c='Ontario';
		insolv.Debtor_2_Mailing_State_Province__c='Ontario';
		insolv.Debtor_2_Estate_Number__c='10000000';
		insolv.Insolvency_Status__c='Staging';
		insolv.Debtor_1_Court_Number__c='1023';
		insolv.Court_Division_Number__c='1234';
		insolv.Court_District_Name__c='sample';
		insolv.Court_Province_Name__c='sample';
		insolv.Debtor_1_First_Name__c='sam';
		insolv.Debtor_1_Last_Name__c='samp';
		insolv.Debtor_1_Mailing_Street__c='sample address';
		insolv.Debtor_1_Mailing_City__c='city sample';
		insolv.Debtor_1_Employer_Postal_Code__c='L7S1X3';
		insolv.Debtor_1_Date_of_Birth__c=system.today();
		insolv.Debtor_1_Gender__c='male';
		insolv.Insolvency_Status_Last_Changed__c=System.now();
		insolv.Expected_Discharge_Month__c='24';
		insolv.Insolvency_Date__c=system.today();
		insert insolv;

        PageReference testPage = Page.InsolvencyView;
        Test.setCurrentPage(testPage);
        system.runAs(user) {        
            Test.StartTest();     
            ApexPages.StandardController sc = new ApexPages.StandardController(insolv);
			InsolvencyViewController controller = new InsolvencyViewController(sc);
			Test.StopTest();
            system.assertEquals(false, controller.inlineEdit);
        }
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(insolv);
		InsolvencyViewController controller1 = new InsolvencyViewController(sc1);
        system.assertEquals(true, controller1.inlineEdit);
    }
}