/**************************************************************************************************
 *
 *  Class:   ProductUtil
 *
 *  @description : This is a test class for ProductUtil
 *  @author : A5E Consulting
 *  @date : 20/02/2018
 * 
 *************************************************************************************************/
@isTest
public class TestProductUtil{

    static testMethod void testMethodProductutl(){
        
        //insert Product record
        Product__c producData = new Product__c();
        producData.Last_Name__c = 'Subba';
        producData.First_Name__c = 'Reddy';
        producData.Email_Address__c = 'subba.reddy@gmail.com';
        producData.Date_of_Birth__c = system.today();
        producData.SIN__c = 'test';
        producData.Address_Line1__c = 'Hightech City';
        producData.Address_Line2__c = 'Gachi Bowli';
        producData.City__c = 'Hyderabad';
        producData.Zip_Code__c = '500001';
        //producData.State__c = 'Andhra PParadesh';
        producData.Phone_Home__c = '3456756789';
        producData.Phone_Work__c = '2345675678';
        producData.Phone_Other__c = '5678756789';
        producData.Address_Last_Changed_Date__c = system.today();
        insert producData;
        
        list<Product__c> productList = new list<Product__c>();
        productList.add(producData);
        
        //insert account record
        Account accountData = new Account();
        accountData.LastName = producData.Last_Name__c;
        accountData.FirstName = producData.First_Name__c;
        accountData.PersonEmail = producData.Email_Address__c;
        accountData.PersonBirthdate = producData.Date_of_Birth__c;
        accountData.SIN__pc = producData.SIN__c;
        accountData.PersonMailingStreet = producData.Address_Line1__c;
        accountData.PersonMailingCity = producData.City__c;
        accountData.PersonMailingPostalCode = producData.Zip_Code__c;
        //accountData.PersonMailingState = producData.State__c;
        accountData.PersonHomePhone = producData.Phone_Home__c;
        accountData.Work_Phone__pc = producData.Phone_Work__c;
        accountData.PersonOtherPhone = producData.Phone_Other__c;
        accountData.Address_Last_Changed_Date__c = producData.Address_Last_Changed_Date__c;
        insert accountData;
        
      //  ProductUtil classObj = new ProductUtil();
        ProductUtil.createCustomer(producData, 'Fidem Customer');
        ProductUtil.queryCustomer(producData, 'Fidem Customer');
            
   
    }

    public static Product__c createProduct(){

       
      //insert Product record
        Product__c producData = new Product__c();
        producData.Last_Name__c = 'Subba';
        producData.First_Name__c = 'Reddy';
        producData.Email_Address__c = 'subba.reddy@gmail.com';
        producData.Date_of_Birth__c = system.today();
        producData.SIN__c = 'test';
        producData.Address_Line1__c = 'Hightech City';
        producData.Address_Line2__c = 'Gachi Bowli';
        producData.City__c = 'Hyderabad';
        producData.Zip_Code__c = '500001';
        //producData.State__c = 'Andhra PParadesh';
        producData.Phone_Home__c = '3456756789';
        producData.Phone_Work__c = '2345675678';
        producData.Phone_Other__c = '5678756789';
        producData.Address_Last_Changed_Date__c = system.today();
        
        insert producData;

        //insert account record
        Account accountData = new Account();
        accountData.LastName = producData.Last_Name__c;
        accountData.FirstName = producData.First_Name__c;
        accountData.PersonEmail = producData.Email_Address__c;
        accountData.PersonBirthdate = producData.Date_of_Birth__c;
        accountData.SIN__pc = producData.SIN__c;
        accountData.PersonMailingStreet = producData.Address_Line1__c;
        accountData.PersonMailingCity = producData.City__c;
        accountData.PersonMailingPostalCode = producData.Zip_Code__c;
        //accountData.PersonMailingState = producData.State__c;
        accountData.PersonHomePhone = producData.Phone_Home__c;
        accountData.Work_Phone__pc = producData.Phone_Work__c;
        accountData.PersonOtherPhone = producData.Phone_Other__c;
        accountData.Address_Last_Changed_Date__c = producData.Address_Last_Changed_Date__c;
        insert accountData;

      producData.Customer__c = accountData.Id;
      update producData;

      return producData;

    }

    /*
    public static Judgment__c createJudgment(){

       
      //insert Product record
        Product__c producData = new Product__c();
        producData.Last_Name__c = 'Subba';
        producData.First_Name__c = 'Reddy';
        producData.Email_Address__c = 'subba.reddy@gmail.com';
        producData.Date_of_Birth__c = system.today();
        producData.SIN__c = 'test';
        producData.Address_Line1__c = 'Hightech City';
        producData.Address_Line2__c = 'Gachi Bowli';
        producData.City__c = 'Hyderabad';
        producData.Zip_Code__c = '500001';
        producData.State__c = 'Andhra PParadesh';
        producData.Phone_Home__c = '3456756789';
        producData.Phone_Work__c = '2345675678';
        producData.Phone_Other__c = '5678756789';
        producData.Address_Last_Changed_Date__c = system.today();
        
        insert producData;

        //insert account record
        Account accountData = new Account();
        accountData.LastName = producData.Last_Name__c;
        accountData.FirstName = producData.First_Name__c;
        accountData.PersonEmail = producData.Email_Address__c;
        accountData.PersonBirthdate = producData.Date_of_Birth__c;
        accountData.SIN__pc = producData.SIN__c;
        accountData.PersonMailingStreet = producData.Address_Line1__c;
        accountData.PersonMailingCity = producData.City__c;
        accountData.PersonMailingPostalCode = producData.Zip_Code__c;
        accountData.PersonMailingState = producData.State__c;
        accountData.PersonHomePhone = producData.Phone_Home__c;
        accountData.Work_Phone__pc = producData.Phone_Work__c;
        accountData.PersonOtherPhone = producData.Phone_Other__c;
        accountData.Address_Last_Changed_Date__c = producData.Address_Last_Changed_Date__c;
        insert accountData;

      producData.Customer__c = accountData.Id;
      update producData;
      
      
       Judgment__c judg = new Judgment__c(Judgment_Date__c = System.TODAY());
       insert judg;

       Account_Judgment__c accJudg= new Account_Judgment__c();
       accJudg.Product__c = producData.Id;
       accJudg.Judgment__c = judg.Id;
       accJudg.Status__c = 'Active';
       insert accJudg;
      return judg;
      

    }

    public static Settlement__c createSettlement(){

       
      //insert Product record
        Product__c producData = new Product__c();
        producData.Last_Name__c = 'Subba';
        producData.First_Name__c = 'Reddy';
        producData.Email_Address__c = 'subba.reddy@gmail.com';
        producData.Date_of_Birth__c = system.today();
        producData.SIN__c = 'test';
        producData.Address_Line1__c = 'Hightech City';
        producData.Address_Line2__c = 'Gachi Bowli';
        producData.City__c = 'Hyderabad';
        producData.Zip_Code__c = '500001';
        producData.State__c = 'Andhra PParadesh';
        producData.Phone_Home__c = '3456756789';
        producData.Phone_Work__c = '2345675678';
        producData.Phone_Other__c = '5678756789';
        producData.Address_Last_Changed_Date__c = system.today();
        
        insert producData;

        //insert account record
        Account accountData = new Account();
        accountData.LastName = producData.Last_Name__c;
        accountData.FirstName = producData.First_Name__c;
        accountData.PersonEmail = producData.Email_Address__c;
        accountData.PersonBirthdate = producData.Date_of_Birth__c;
        accountData.SIN__pc = producData.SIN__c;
        accountData.PersonMailingStreet = producData.Address_Line1__c;
        accountData.PersonMailingCity = producData.City__c;
        accountData.PersonMailingPostalCode = producData.Zip_Code__c;
        accountData.PersonMailingState = producData.State__c;
        accountData.PersonHomePhone = producData.Phone_Home__c;
        accountData.Work_Phone__pc = producData.Phone_Work__c;
        accountData.PersonOtherPhone = producData.Phone_Other__c;
        accountData.Address_Last_Changed_Date__c = producData.Address_Last_Changed_Date__c;
        insert accountData;

      producData.Customer__c = accountData.Id;
      update producData;
       
       
       Judgment__c judg = new Judgment__c(Judgment_Date__c = System.TODAY());
       insert judg;

       Account_Judgment__c accJudg= new Account_Judgment__c();
       accJudg.Product__c = producData.Id;
       accJudg.Judgment__c = judg.Id;
       accJudg.Status__c = 'Active';
       insert accJudg;

       Settlement__c  settlement = new Settlement__c();
       settlement.Product__c = producData.Id;
       insert settlement;
      return settlement;
      
      
    }
    */
}