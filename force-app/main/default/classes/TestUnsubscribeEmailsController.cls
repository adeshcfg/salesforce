/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for UnsubscribeEmailsController
 *  @author : A5E Consulting
 *  @date : 07/09/2021
 
 *************************************************************************************************/
@isTest
public class TestUnsubscribeEmailsController {
    public static testMethod void updateEmailPreferenceTest(){
        Account customerInstance = PaymentProcessorTestUtility.getDistressedAccount();
        
        PageReference pageRef = Page.UnsubscribeEmails;
        pageRef.getParameters().put('id', String.valueOf(customerInstance.Id));
        Test.setCurrentPage(pageRef);   
        
        UnsubscribeEmailsController controller = new UnsubscribeEmailsController();
        controller.updateConsent();
        controller.strEmail = 'test@testemail.com';
        controller.strFirstName = 'Anna';
        controller.strLastName = 'Stark';
        controller.updateConsent();
    }
}