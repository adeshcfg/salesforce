/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a Test class for TPFidemApplicationFormController
 *  @author : A5E Consulting
 *  @date : 03/15/2025
 * 
 *************************************************************************************************/

@isTest
private class TestTPFidemApplicationFormController {
    static private Map<String, List<String>> streetAddressMap; 

    static private final String PERSON_SALLY = 'Sally';
    static private final String PERSON_ASAD = 'Asad';
    static private final String PERSON_DONNA = 'Donna';
    static private final String PERSON_ASADTest = 'Asad';
    
    //Risk Based Pricing
    static private final String CREDIT_CARD = 'Affirm Financial MasterCard';
    static private final String TERM_LOAN = 'Affirm Financial Term Loan';
    
    static {
        // Initialize streetAddressMap to return list of street name
        // and number, given a string of street number + name
        streetAddressMap = new Map<String, List<String>>();
        
        Tracking_Code__c trackCode = new Tracking_Code__c(name='record1', Param_Name__c='csTrackId', Param_Value__c='csTrackId');
        insert trackCode;        
        trackCode = new Tracking_Code__c(name='record2', Param_Name__c='acquisitionCode', Param_Value__c='acquisitionCode');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record3', Param_Name__c='offerCode', Param_Value__c='offerCode');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record4', Param_Name__c='referralId', Param_Value__c='referralId');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record5', Param_Name__c='clientIP', Param_Value__c='clientIP');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record6', Param_Name__c='firstName', Param_Value__c='firstName');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record7', Param_Name__c='lastName', Param_Value__c='lastName');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record8', Param_Name__c='poBox', Param_Value__c='poBox');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record9', Param_Name__c='streetNumber', Param_Value__c='streetNumber');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record10', Param_Name__c='streetName', Param_Value__c='streetName');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record11', Param_Name__c='unitNumber', Param_Value__c='unitNumber');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record12', Param_Name__c='city', Param_Value__c='city');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record13', Param_Name__c='province', Param_Value__c='province');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record14', Param_Name__c='postalCode', Param_Value__c='postalCode');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record15', Param_Name__c='phoneNumber', Param_Value__c='phoneNumber');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record16', Param_Name__c='email', Param_Value__c='email');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record17', Param_Name__c='referralURL', Param_Value__c='referralURL');
        insert trackCode;         
        trackCode = new Tracking_Code__c(name='record18', Param_Name__c='geoCity', Param_Value__c='geoCity');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record19', Param_Name__c='geoProvince', Param_Value__c='geoProvince');
        insert trackCode;
        trackCode = new Tracking_Code__c(name='record20', Param_Name__c='geoCountry', Param_Value__c='geoCountry');
        insert trackCode;
        
        //Add Marketing Source to Application Records 
        /*
        AC_MS_Mapping__c acMsCS = new AC_MS_Mapping__c(Name = 'qu', Campaign_Channel__c = 'Email', Campaign_Sub_Channel__c = 'Email');
        insert acMsCS;
        acMsCS = new AC_MS_Mapping__c(Name = 'UM', Campaign_Channel__c = 'Mail', Campaign_Sub_Channel__c = 'Mail');
        insert acMsCS;
        */
        }
        
    // Test the logic of the constructor
    static testMethod void testApplicationFormInitialization() {        
        // Test no id provided
        TPFidemApplicationFormController c = initializeTest();

        //System.assertEquals(false, c.PersonAlreadyLoaded);
        //System.assertEquals(null, c.PersonAccount.Id);

        // Test id provided, but Person does not exist
        ApexPages.currentPage().getParameters().put('id', 'notAnIdBlahBlahBlah');
        c = new TPFidemApplicationFormController();

        //System.assertEquals(false, c.PersonAlreadyLoaded);
        //System.assertEquals(null, c.PersonAccount.Id);

        // Test id provided for existing Person

        // Test Commission Soup Tracker Id,acquisitionCode,offerCode and referralCode
        String csTrackerId = '7V1RD3';
        String acquCode = 'acquicd';
        String offCode = 'offer123';
        String refId = 'refer123';
        String clientIP = '2001:0db8:85a3:08d3:1319:8a2e:0370:7334';
        String referralURL = 'd3d3Lmdvb2dsZS5jb20=';//www.google.com;
        String geoCity = 'Trombay';
        String geoProvince = 'Maharashtra';
        String geoCountry = 'IN - India';
        String email = 'email';
        String firstName = 'firstName';
        String lastName = 'lastName';
        String poBox = 'poBox';
        String streetNumber = 'streetNumber';
        String streetName = 'streetName';
        String unitNumber = 'unitNumber';
        String city = 'city';
        String province = 'province';
        String postalCode = 'postalCode';
        String phoneNumber = 'phoneNumber';
        //String customerlocation = 'Fidem';        
        ApexPages.currentPage().getParameters().put('csTrackId', csTrackerId);
        ApexPages.currentPage().getParameters().put('acquisitionCode', acquCode);
        ApexPages.currentPage().getParameters().put('offerCode', offCode);
        ApexPages.currentPage().getParameters().put('referralId', refId);
        ApexPages.currentPage().getParameters().put('clientIP', clientIP);
        ApexPages.currentPage().getParameters().put('referralURL', referralURL);
        ApexPages.currentPage().getParameters().put('geoCity', geoCity);
        ApexPages.currentPage().getParameters().put('geoProvince', geoProvince);
        ApexPages.currentPage().getParameters().put('geoCountry', geoCountry);
        ApexPages.currentPage().getParameters().put('email', email);
        ApexPages.currentPage().getParameters().put('firstName', firstName);
        ApexPages.currentPage().getParameters().put('lastName', lastName);
        ApexPages.currentPage().getParameters().put('poBox', poBox);
        ApexPages.currentPage().getParameters().put('streetNumber', streetNumber);
        ApexPages.currentPage().getParameters().put('streetName', streetName);
        ApexPages.currentPage().getParameters().put('firstName', firstName);
        ApexPages.currentPage().getParameters().put('lastName', lastName);
        ApexPages.currentPage().getParameters().put('unitNumber', unitNumber);
        ApexPages.currentPage().getParameters().put('city', city);
        ApexPages.currentPage().getParameters().put('province', province);
        ApexPages.currentPage().getParameters().put('postalCode', postalCode);
        ApexPages.currentPage().getParameters().put('phoneNumber', phoneNumber);
        //ApexPages.currentPage().getParameters().put('customerlocation', customerlocation);
        c = new TPFidemApplicationFormController();
      
        //System.assertEquals(csTrackerId, c.Application.Commission_Soup_Tracker_Id__c);
        //System.assertEquals(acquCode, c.Application.acquisition_Code__c);
        //System.assertEquals(offCode, c.Application.Offer_Code__c);
        //System.assertEquals(refId, c.Application.Referral_ID__c);
        //System.assertEquals(clientIP, c.Application.Client_IP__c);
        //System.assertEquals('www.google.com', c.Application.Referral_URL__c);
        
        // 1. Truncated person case (ensures no null ptrs if provided w/incomplete record)
        Account person = insertTruncatedPerson(PERSON_SALLY);
        ApexPages.currentPage().getParameters().put('id', person.Id);
        c = new TPFidemApplicationFormController();
        
        //System.assertEquals(true, c.PersonAlreadyLoaded);
        assertSameTruncatedPerson(person, c.PersonAccount);

        // 2. Full person case (ensure fields + properties set accordingly)
        person = insertFullPerson(PERSON_ASAD);
        ApexPages.currentPage().getParameters().put('id', person.Id);
        c = new TPFidemApplicationFormController();
        
        // 3. Full person case
        person = insertFullPerson(PERSON_ASADTest);
        ApexPages.currentPage().getParameters().put('id', person.Id);
        c = new TPFidemApplicationFormController();
        
        //System.assertEquals(true, c.PersonAlreadyLoaded);
        assertSameFullPerson(person, c.PersonAccount);        

        // Check that controller properties initialized via loaded Person
        assertFormInitializedViaPerson(person, c);
    }
    
    // Test step zero case where no fields entered
    static testMethod void testStepZeroBlank() {
        TPFidemApplicationFormController c = initializeTest();

        // Invoke step zero
        c.saveStepZero();

        // Assert errors -- should be 2 in straight blank case
        //System.assertEquals(2, ApexPages.getMessages().size());     
    }
    
    //Risk Based Pricing
    //Test step zero case where selHomeOwnerOptions is missing
    static testMethod void testStepZeroBlankHomeOwnerOptions() {
        TPFidemApplicationFormController c = initializeTest();

        c.SelLoanType = CREDIT_CARD;
        c.selHomeOwnerOptions = '';
        
        // Invoke step zero
        c.saveStepZero();

        // Assert errors -- should be 2 as selHomeOwnerOptions and Province are missing
        //System.assertEquals(2, ApexPages.getMessages().size());     
    }
    
    // Test step one case where no fields are entered
    static testMethod void testStepOneBlank() {
        TPFidemApplicationFormController c = initializeTest();

        // Invoke step one
        c.saveStepOne();

        // Assert errors -- should be 9 in straight blank case
        //System.assertEquals(9, ApexPages.getMessages().size());
    }
    
    static testMethod void testStepFourWithStepOneBlank() {
        TPFidemApplicationFormController c = initializeTest();

        // Invoke step one
        c.saveStepFour();

        // Assert errors
        System.assertNotEquals(0, ApexPages.getMessages().size());
    }
    
    // Test step one case where Person Record is passed into page
    static testMethod void testStepOnePersonAlreadyLoaded() {
        initializeTest();
       
        // Persist fully populated Person record
        Account person = insertFullPerson(PERSON_ASAD);
        
        // Persist fully populated Person record
        Account person_1 = insertFullPerson(PERSON_ASADTest);

        // Populate Application obj (unpersisted)
        Application__c app = populateFullApplication(person);
        Application__c app_1 = populateFullApplication(person_1);

        // Pass id into page
        ApexPages.currentPage().getParameters().put('id', person.Id);
        
        TPFidemApplicationFormController c = new TPFidemApplicationFormController();
        
        // Set step one form fields to valid values
        setStepOneFieldsPersonAlreadyLoaded(c, app); 
        setStepOneFieldsPersonAlreadyLoaded(c, app_1);

        // Invoke step one
        c.saveStepOne();

        // Assert no errors + person not found via query
        //System.assertEquals(0, ApexPages.getMessages().size());
        //System.assertEquals(false, c.PersonFoundViaQuery);
        
        // Assert that input fields get mapped to Application object
        assertStepOneFields(c, app);
        assertStepOneFields(c,app_1);
    }
    
    // Test step one cases where person is loaded via query
    static testMethod void testStepOnePersonLoadedViaQuery() {        
        initializeTest();
        ApexPages.currentPage().getParameters().put('id', null);
        
        // To isolate just the query logic, persist 'Asad'
        // -- but load form fields corresponding to another person 'Donna'
        // -- and then alter just the relevant query fields to match 'Asad'

        // Persist fully populated Person record -- ASAD
        Account person = insertFullPerson(PERSON_ASAD);
        
        Account person_1 = insertFullPerson(PERSON_ASADTest);
        
        // Populate app obj via DIFFERENT person
        Account otherPerson = populateFullPerson(PERSON_DONNA);
        Application__c app = populateFullApplication(otherPerson);

        // 1. Test Match via Last Name and SIN
        TPFidemApplicationFormController c = new TPFidemApplicationFormController();
        
        // Assert person was NOT loaded
        System.assertNotEquals(c.PersonAccount.Id, person.Id);
        
        // Overwrite fields s.t. query will match ASAD
        app.Last_Name__c = person.LastName;
        app.SIN__c = person.SIN__pc;
        
        // Overwrite fields s.t. query will match ASAD
        app.Last_Name__c = person_1.LastName;
        app.SIN__c = person_1.SIN__pc;

        // Set form fields
        setStepOneFields(c, app); 

        // Invoke step one
        c.SaveStepOne();

        // Assert no errors, person found via query, ids match
        //System.assertEquals(0, ApexPages.getMessages().size());
        //System.assertEquals(true, c.PersonFoundViaQuery);
        //System.assertEquals(c.PersonAccount.Id, person.Id);
        
        // Assert other fields
        assertStepOneFields(c, app);        
    
        // 2. Match via Last Name, Birthdate, and first letter of First Name
        c = initializeTest();
        
        // Assert person was NOT loaded
        System.assertNotEquals(c.PersonAccount.Id, person.Id);

        // Reset app to be populated by Other person
        app = populateFullApplication(otherPerson);

        // Set fields s.t. query will match
        app.Last_Name__c = person.LastName;
        app.Birth_Date__c = person.PersonBirthdate;
        app.First_Name__c = person.FirstName;
        
        // Set form fields
        setStepOneFields(c, app);

        // Invoke step one
        c.SaveStepOne();

        // Assert no errors, person found via query, ids match
        //System.assertEquals(0, ApexPages.getMessages().size());
        //System.assertEquals(true, c.PersonFoundViaQuery);
        //System.assertEquals(c.PersonAccount.Id, person.Id);
        
        // Assert other fields
        assertStepOneFields(c, app); 

        // 3. Match via Last Name, Email, and first letter of First Name
        c= initializeTest();
        
        // Assert person was NOT loaded     
        System.assertNotEquals(c.PersonAccount.Id, person.Id); 

        // Reset app to be populated by Other person
        app = populateFullApplication(otherPerson);

        // Set fields s.t. query will match
        app.Last_Name__c = person.LastName;
        app.Email_Address__c = person.PersonEmail;
        app.First_Name__c = person.FirstName.subString(0,1); // just first character
    
        // Set form fields
        setStepOneFields(c, app);

        // Invoke step one
        c.SaveStepOne();

        // Assert no errors, person found, ids match
        //System.assertEquals(0, ApexPages.getMessages().size());
        //System.assertEquals(true, c.PersonFoundViaQuery);
        //System.assertEquals(c.PersonAccount.Id, person.Id);
        
        // Assert other fields
        assertStepOneFields(c, app); 

        // 4. No match
        c = initializeTest();
        
        // Assert person was NOT loaded     
        System.assertNotEquals(c.PersonAccount.Id, person.Id); 

        // Reset app to be populated by Other person
        app = populateFullApplication(otherPerson);

        // Set form fields
        setStepOneFields(c, app); 

        // Invoke step one
        c.SaveStepOne();

        // Assert no errors, person found, ids match
        //System.assertEquals(0, ApexPages.getMessages().size());
        //System.assertEquals(false, c.PersonFoundViaQuery);
        System.assertNotEquals(c.PersonAccount.Id, person.Id);
        
        // Assert other fields
        assertStepOneFields(c, app); 

    }
    
    // Test step one age of majority success cases
    static testMethod void testStepOneAgeOfMajoritySuccess() {
        TPFidemApplicationFormController c = initializeTest();

        Account person = populateFullPerson(PERSON_ASAD);
        Application__c app = populateFullApplication(person);
        
        Account person_1 = populateFullPerson(PERSON_ASADTest);
        Application__c app_1 = populateFullApplication(person_1);

        // Overwrite birthdate to exactly age of majority -- this should pass
        app.Province__c = 'NB'; // age of majority of 18
        Date eighteenYearsAgo = Date.today().addYears(-18);     
        app.Birth_Date__c = eighteenYearsAgo;
        
        // Set form fields to valid values
        setStepOneFields(c, app);

        // Invoke step one
        c.saveStepOne();
        
        // Assert no errors, other fields
        //System.assertEquals(0, ApexPages.getMessages().size());
        assertStepOneFields(c, app); 
    }

// Test step one age of majority error cases
    static testMethod void testStepOneAgeOfMajorityError() {
        TPFidemApplicationFormController c = initializeTest();

        Account person = populateFullPerson(PERSON_ASAD);
        Application__c app = populateFullApplication(person);

        // Set fields to trigger Provice + Age restriction case        
        app.Province__c = 'NB'; // age of majority of 18
        Date tomorrow = Date.today().addDays(1);
        Date lessThanEighteenYearsAgo = tomorrow.addYears(-18);
        app.Birth_Date__c = lessThanEighteenYearsAgo;

        // Set form fields
        setStepOneFields(c, app);
        
        Account person_1 = populateFullPerson(PERSON_ASADTest);
        Application__c app_1 = populateFullApplication(person_1);

        // Set fields to trigger Provice + Age restriction case        
        app_1.Province__c = 'NB'; // age of majority of 18
        Date tomorrows = Date.today().addDays(1);
        Date lessThanEighteenYearsAgo_1 = tomorrows.addYears(-18);
        app_1.Birth_Date__c = lessThanEighteenYearsAgo_1;

        // Set form fields
        setStepOneFields(c, app_1);
        
        // Invoke step one
        c.saveStepOne();
        
        //Manitoba Disclosure
        // Assert error, error message mentions 'age of majority'
        //System.assertEquals(1, ApexPages.getMessages().size());
        //String errMessage = ApexPages.getMessages().get(0).getSummary();
        //System.assert(errMessage.toLowerCase().contains('age of majority'));
    }
    
    // Test step one order code expired error
    static testMethod void testStepOneOfferCodeExpiredError() {
        TPFidemApplicationFormController c = initializeTest();

        Account person = populateFullPerson(PERSON_ASAD);
        Application__c app = populateFullApplication(person);

        // insert expired offer campaign
        Campaign campaign = insertExpiredOfferCode();

        // Set fields to trigger error case
        //c.SelOfferCodeAvail = 'Yes';
        app.Offer_Code__c = campaign.Offer_Code__c;

        // Set form fields
        setStepOneFields(c, app);

        // Invoke step one
        c.saveStepOne();

        // Assert error, error message mentions 'offer code'
        //System.assertEquals(1, ApexPages.getMessages().size());
        //String errMessage = ApexPages.getMessages().get(0).getSummary();
        //System.assert(errMessage.toLowerCase().contains('invalid offer code'));
    }
    
    // Test step one 'disclosure terms' error case
    static testMethod void testStepOneDisclosureTermsError() {
        TPFidemApplicationFormController c = initializeTest();

        Account person = populateFullPerson(PERSON_ASAD);
        Application__c app = populateFullApplication(person);
        
        Account person_1 = populateFullPerson(PERSON_ASADTest);
        Application__c app_1 = populateFullApplication(person_1);


        // Set disclosure terms to unchecked
        app.Has_Accepted_Disclosure_Terms__c = false;
        app_1.Has_Accepted_Disclosure_Terms__c = false;
        
        // Set form fields to valid values
        setStepOneFields(c, app);
        setStepOneFields(c, app_1);
        
        // Invoke step one
        c.saveStepOne();
       
        // Assert error, error message mentions 'accept the disclosure'
        //System.assertEquals(1, ApexPages.getMessages().size());
        //String errMessage = ApexPages.getMessages().get(0).getSummary();
        //System.assert(errMessage.toLowerCase().contains('accept the disclosure'));
    }
    
    // Test step one 'authorized for credit check' error case
    static testMethod void testStepOneAuthorizedCreditCheckError() {
        TPFidemApplicationFormController c = initializeTest();

        Account person = populateFullPerson(PERSON_ASAD);
        Application__c app = populateFullApplication(person);
        
        Account person_1 = populateFullPerson(PERSON_ASADTest);
        Application__c app_1 = populateFullApplication(person_1);

        // Set authorized for credit check to false
        app.Authorized_Credit_Check__c = false;
        app_1.Authorized_Credit_Check__c = false;
        
        // Set form fields
        setStepOneFields(c, app);
        setStepOneFields(c, app_1);
        
        // Invoke step one
        c.saveStepOne();
       
        // Assert error, error message mentions 'accept the disclosure'
        //System.assertEquals(1, ApexPages.getMessages().size());
        //String errMessage = ApexPages.getMessages().get(0).getSummary();
        //System.assert(errMessage.toLowerCase().contains('must be authorized'));
    }
    
    // Test step two case where no fields are entered
    static testMethod void testStepTwoBlank() {
        TPFidemApplicationFormController c = initializeTest();

        // Populate person and application
        Account person = populateFullPerson(PERSON_ASAD);
        Application__c app = populateFullApplication(person);
        
        // Populate person and application
        Account person_1 = populateFullPerson(PERSON_ASADTest);
        Application__c app_1 = populateFullApplication(person_1);

        // Set form fields for step one as per normal
        setStepOneFields(c, app);
        setStepOneFields(c,app_1);

        // Invoke step one
        c.saveStepOne();

        // Invoke step two -- without setting step two fields
        c.saveStepTwo();

        // Assert errors -- should be 14 in straight blank case
        //System.assertEquals(14, ApexPages.getMessages().size());
    }
    
    static testMethod void testStepFourWithStepTwoBlank() {
        TPFidemApplicationFormController c = initializeTest();

        // Populate person and application
        Account person = populateFullPerson(PERSON_ASAD);
        Application__c app = populateFullApplication(person);
        
        Account person_1 = populateFullPerson(PERSON_ASADTest);
        Application__c app_1 = populateFullApplication(person_1);

        // Set form fields for step one as per normal
        setStepOneFields(c, app);
        setStepOneFields(c, app_1);

        // Invoke step one
        c.saveStepOne();

        // Invoke step two -- without setting step two fields
        c.saveStepFour();

        // Assert errors
        System.assertNotEquals(0, ApexPages.getMessages().size());
    }
    
    // Test step two case of blank form plus required
    // previous address fields
    static testMethod void testStepTwoBlankRequiredPreviousAddress() {
        TPFidemApplicationFormController c = initializeTest();

        // Populate person and application
        Account person = populateFullPerson(PERSON_ASAD);
        Application__c app = populateFullApplication(person);

        // Set form fields for step one as per normal
        setStepOneFields(c, app);

        // Invoke step one
        c.saveStepOne();

        // Set Permanent address years field to 1
        // -- this makes previous address fields required
        c.Application.Years_At_Permanent_Address__c = 1;
        c.Application.Months_At_Permanent_Address__c = 10;

        // Invoke step two -- without setting step two fields
        c.saveStepTwo();

        // Assert errors -- should be 17 in straight blank case
        //System.assertEquals(17, ApexPages.getMessages().size());
        //System.assertEquals(18, ApexPages.getMessages().size());
    }
    
    // Test that step two persists application + person record
    static testMethod void testStepTwoPersist() {
        TPFidemApplicationFormController c = initializeTest();

        Account person = populateFullPerson(PERSON_DONNA);
        Application__c app = populateFullApplication(person);

        // Set form fields to valid values
        setStepOneFields(c, app);

        // Invoke step one
        c.saveStepOne();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Set step two form fields to valid values
        setStepTwoFields(c, app);

        // Invoke step two
        c.saveStepTwo();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());
        //System.assertEquals(1, ApexPages.getMessages().size());

        // Query Person
        Account p = queryPerson(c.PersonAccount.Id);

        // Assert same person
        //System.assert(p != null);
        //assertSamePersonUpToStepTwo(person, p);

        // Query Application
        Application__c a = queryApplication(c.Application.Id);

        // Assert same application
        System.assert(a != null);
        assertSameApplicationUpToStepTwo(app, a);       
    }
    
    //Risk Based Pricing
    // Test step two with Mortgage With Missing
    static testMethod void testStepTwoWithMortgagegWithMissing() {
        TPFidemApplicationFormController c = initializeTest();

        // Populate person and application
        Account person = populateFullPerson(PERSON_ASAD);
        Application__c app = populateFullApplication(person);

        // Set form fields for step one as per normal
        setStepOneFields(c, app);

        // Invoke step one
        c.saveStepOne();

        setStepTwoFields(c, app);
        
        app.Mortgage_With__c = '';
        c.Application.Mortgage_With__c = '';        
        c.SelPermanentRentOrOwn = 'Own Property';        
        app.Housing_Costs__c = 1200;
        c.Application.Housing_Costs__c = 1200;

        // Invoke step two 
        c.saveStepTwo();

        // Assert errors -- should be 1 Mortageg With Missing
        //System.assertEquals(1, ApexPages.getMessages().size());
    }
    
    // Test step three case where no fields are entered
    static testMethod void testStepThreeBlank() {
        TPFidemApplicationFormController c = initializeTest();

        // Populate person and application
        Account person = populateFullPerson(PERSON_DONNA);
        Application__c app = populateFullApplication(person);

        // Set form fields for step one as per normal
        setStepOneFields(c, app);

        // Invoke step one
        c.saveStepOne();

        setStepTwoFields(c, app);

        // Invoke step two 
        c.saveStepTwo();

        // Invoke step three -- without setting fields
        c.saveStepThree();

        // Assert errors -- should be 9 in straight blank case
        //System.assertEquals(9, ApexPages.getMessages().size());
        //System.assertEquals(10, ApexPages.getMessages().size());
    }

    static testMethod void testStepFourWithThreeBlank() {
        TPFidemApplicationFormController c = initializeTest();

        // Populate person and application
        Account person = populateFullPerson(PERSON_DONNA);
        Application__c app = populateFullApplication(person);

        // Set form fields for step one as per normal
        setStepOneFields(c, app);

        // Invoke step one
        c.saveStepOne();

        setStepTwoFields(c, app);

        // Invoke step two 
        c.saveStepTwo();

        // Invoke step three -- without setting fields
        c.saveStepFour();

        // Assert errors
        System.assertNotEquals(0, ApexPages.getMessages().size());
    }
    
    // Test step three case where no fields are entered plus
    // -- previous employment fields are required
    static testMethod void testStepThreeBlankRequiredPreviousEmployment() {
        TPFidemApplicationFormController c = initializeTest();

        // Populate person and application
        Account person = populateFullPerson(PERSON_DONNA);
        Application__c app = populateFullApplication(person);

        // Set form fields for step one as per normal
        setStepOneFields(c, app);

        // Invoke step one
        c.saveStepOne();

        setStepTwoFields(c, app);

        // Invoke step two 
        c.saveStepTwo();

        // Set Years at Employment to 1, which makes
        // previous employment fields requirements
        c.Application.Employment_Years__c = 1;
        c.Application.Employment_Months__c = 10;

        // Invoke step three -- without setting fields
        c.saveStepThree();

        // Assert errors -- should be 16 in straight blank case
        //System.assertEquals(16, ApexPages.getMessages().size());
        //System.assertEquals(17, ApexPages.getMessages().size());
    }
    
    // Test that step three sets fields correctly
    static testMethod void testStepThree() {
        TPFidemApplicationFormController c = initializeTest();

        Account person = populateFullPerson(PERSON_DONNA);
        Application__c app = populateFullApplication(person);

        // Set form fields to valid values
        setStepOneFields(c, app);

        // Invoke step one
        c.saveStepOne();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Set step two form fields to valid values
        setStepTwoFields(c, app);

        // Invoke step two
        c.saveStepTwo();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());
        //System.assertEquals(1, ApexPages.getMessages().size());

        // Set step three fields
        setStepThreeFields(c, app);

        // Invoke step three
        c.saveStepThree();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());
        //System.assertEquals(1, ApexPages.getMessages().size());

        // Assert same application up to step three
        assertSameApplicationUpToStepThree(c.Application, app);
    }
    
    // Test step four case where no step four fields are populated
    static testMethod void testStepFourBlank() {
        TPFidemApplicationFormController c = initializeTest();
    
        Account person = populateFullPerson(PERSON_ASAD);
        Application__c app = populateFullApplication(person);
        
        Account person_1 = populateFullPerson(PERSON_ASADTest);
        Application__c app_1 = populateFullApplication(person_1);
        
        // Set form fields to valid values
        setStepZeroFields(c, app);
        setStepZeroFields(c, app_1);

        // Invoke step zero
        c.saveStepZero();
        
        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Set form fields to valid values
        setStepOneFields(c, app);

        // Invoke step one
        c.saveStepOne();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Set step two form fields to valid values
        setStepTwoFields(c, app);
        setStepTwoFields(c, app_1);
        
        // Invoke step two
        c.saveStepTwo();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Set step three fields
        setStepThreeFields(c, app);
        setStepThreeFields(c, app_1);
        
        // Invoke step three
        c.saveStepThree();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());
        
        // Invoke step four -- without setting fields
        PageReference landingPage = c.saveStepFour();

        // Assert null landing page, errors
        System.assert(landingPage == null);
        //System.assertEquals(1, ApexPages.getMessages().size()); // only 1 required field that isn't pre-populated
    }

    // Test step four case where PowerCurve returns 'Approved' decision
    static testMethod void testStepFourPowerCurveAccepted() {
        TPFidemApplicationFormController c = initializeTest();
    
        Account person = populateFullPerson(PERSON_ASAD);
        Application__c app = populateFullApplication(person);
        
        Account person_1 = populateFullPerson(PERSON_ASADTest);
        Application__c app_1 = populateFullApplication(person_1);
        
        // Set form fields to valid values
        setStepZeroFields(c, app);
        setStepZeroFields(c, app_1);
        
        // Invoke step zero
        c.saveStepZero();
        
        setStepOneFields(c, app);
        setStepOneFields(c, app_1);

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());
        
        // Invoke step one
        c.saveStepOne();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Set step two form fields to valid values
        setStepTwoFields(c, app);
        setStepTwoFields(c, app_1);

        // Invoke step two
        c.saveStepTwo();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Set step three fields
        setStepThreeFields(c, app);
        setStepThreeFields(c, app_1);

        // Invoke step three
        c.saveStepThree();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Step step four fields
        setStepFourFields(c, app);
        setStepFourFields(c, app_1);
        
        // Initialize PowerCurve mock settings
        initializePowerCurveMock();

        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockAcceptResponse());
        
        // Invoke step four
        PageReference landingPage = c.saveStepFour();

        Test.stopTest();
        
        String expectedLandingPage = '/apex/ApplicationDecision?Decision=Accepted&FirstName=' + 
                                     app.First_Name__c + '&id=' + c.Application.Id + '&LastName=' + app.Last_Name__c;
        
        String expectedLandingPage_1 = '/apex/ApplicationDecision?Decision=Accepted&FirstName=' + 
                                     app_1.First_Name__c + '&id=' + c.Application.Id + '&LastName=' + app_1.Last_Name__c;

        // Assert no errors, landing page
        //System.assertEquals(0, ApexPages.getMessages().size());
        //System.assertEquals(expectedLandingPage, landingPage.getUrl());

        // Assert other PowerCurve related fields
        //System.assertEquals('AFI1111', c.Application.Name);        
        //System.assertEquals('AFI1111', c.Application.Application_Number__c);
        //System.assertEquals('Approved', c.Application.Decision__c);
    }

    // Test step four case where PowerCurve returns 'Declined' decision
    static testMethod void testStepFourPowerCurveDeclined() {
        TPFidemApplicationFormController c = initializeTest();
    
        Account person = populateFullPerson(PERSON_ASAD);
        Application__c app = populateFullApplication(person);
        
        Account person_1 = populateFullPerson(PERSON_ASAD);
        Application__c app_1 = populateFullApplication(person_1);

        // Set form fields to valid values
        setStepZeroFields(c, app);
        setStepZeroFields(c, app_1);
        
        // Invoke step zero
        c.saveStepZero();
        
        setStepOneFields(c, app);
        setStepOneFields(c, app_1);

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());
        
        // Set step one
        setStepOneFields(c, app);
        setStepOneFields(c, app_1);

        // Invoke step one
        c.saveStepOne();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Set step two form fields to valid values
        setStepTwoFields(c, app);
        setStepTwoFields(c, app_1);

        // Invoke step two
        c.saveStepTwo();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Set step three fields
        setStepThreeFields(c, app);
        setStepThreeFields(c, app_1);

        // Invoke step three
        c.saveStepThree();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Step step four fields
        setStepFourFields(c, app);
        setStepFourFields(c, app_1);

        // Initialize PowerCurve mock settings
        initializePowerCurveMock();

        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockDeclineResponse());
        
        // Invoke step four
        PageReference landingPage = c.saveStepFour();

        Test.stopTest();
        
        String expectedLandingPage = '/apex/ApplicationDecision?Decision=Declined&FirstName=' + 
                                     app.First_Name__c + '&id=' + c.Application.Id + '&LastName=' + app.Last_Name__c;

        // Assert no errors, landing page
        //System.assertEquals(0, ApexPages.getMessages().size());
        //System.assertEquals(expectedLandingPage, landingPage.getUrl());

        // Assert other PowerCurve related fields
        //System.assertEquals('AFI2222', c.Application.Name);        
        //System.assertEquals('AFI2222', c.Application.Application_Number__c);
        //System.assertEquals('Declined', c.Application.Decision__c);
    }

    // Test step four case where PowerCurve returned 'Reviewed' decision
    static testMethod void testStepFourPowerCurveReviewed() {
        TPFidemApplicationFormController c = initializeTest();
    
        Account person = populateFullPerson(PERSON_ASAD);
        Application__c app = populateFullApplication(person);

        // Set form fields to valid values
        setStepZeroFields(c, app);
        
        // Invoke step zero
        c.saveStepZero();
        
        setStepOneFields(c, app);

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());
        
        // Set step one
        setStepOneFields(c, app);

        // Invoke step one
        c.saveStepOne();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Set step two form fields to valid values
        setStepTwoFields(c, app);

        // Invoke step two
        c.saveStepTwo();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Set step three fields
        setStepThreeFields(c, app);

        // Invoke step three
        c.saveStepThree();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Step step four fields
        setStepFourFields(c, app);

        // Initialize PowerCurve mock settings
        initializePowerCurveMock();

        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockReferResponse());
        
        // Invoke step four
        PageReference landingPage = c.saveStepFour();

        Test.stopTest();
        
        String expectedLandingPage = '/apex/ApplicationDecision?Decision=Reviewed&FirstName=' + 
                                     app.First_Name__c + '&id=' + c.Application.Id + '&LastName=' + app.Last_Name__c;

        // Assert no errors, landing page
        //System.assertEquals(0, ApexPages.getMessages().size());
        //System.assertEquals(expectedLandingPage, landingPage.getUrl());

        // Assert other PowerCurve related fields
        //System.assertEquals('AFI1332', c.Application.Name);        
        //System.assertEquals('AFI1332', c.Application.Application_Number__c);
        //System.assertEquals('Referred', c.Application.Decision__c);
    }

    // Test step four case where PowerCurve returns 'Approved' decision BUT
    //  -- offercode given, therefore landing page is offer code
    static testMethod void testStepFourPowerCurveOfferCode() {
        TPFidemApplicationFormController c = initializeTest();
    
        Account person = populateFullPerson(PERSON_ASAD);
        Application__c app = populateFullApplication(person);

        // Insert an offer code so it can be used
        Campaign campaign = insertOfferCode();

        // Set offer code fields
        //c.SelOfferCodeAvail = 'Yes';
        app.Offer_Code__c = campaign.Offer_Code__c;

        // Set form fields to valid values
        setStepZeroFields(c, app);
        
        // Invoke step zero
        c.saveStepZero();
        
        setStepOneFields(c, app);

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());
        
        // Set step one
        setStepOneFields(c, app);

        // Invoke step one
        c.saveStepOne();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Set step two form fields to valid values
        setStepTwoFields(c, app);

        // Invoke step two
        c.saveStepTwo();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Set step three fields
        setStepThreeFields(c, app);

        // Invoke step three
        c.saveStepThree();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Step step four fields
        setStepFourFields(c, app);

        // Initialize PowerCurve mock settings
        initializePowerCurveMock();

        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockAcceptResponse());
        
        // Invoke step four
        PageReference landingPage = c.saveStepFour();

        Test.stopTest();
        
        String expectedLandingPage = '/apex/ApplicationDecision?Decision=OfferCode&FirstName=' + 
                                     app.First_Name__c + '&id=' + c.Application.Id +'&LastName=' + app.Last_Name__c;

        // Assert no errors, landing page
        //System.assertEquals(0, ApexPages.getMessages().size());
        //System.assertEquals(expectedLandingPage, landingPage.getUrl());

        // Assert other PowerCurve related fields
        //System.assertEquals('AFI1111', c.Application.Name);        
        //System.assertEquals('AFI1111', c.Application.Application_Number__c);
        //System.assertEquals('Approved', c.Application.Decision__c); // Still approved
    }



    // Test step four case where PowerCurve returns 'Error' decision
    static testMethod void testStepFourPowerCurveError() {
        TPFidemApplicationFormController c = initializeTest();
    
        Account person = populateFullPerson(PERSON_ASAD);
        Application__c app = populateFullApplication(person);
        
        Account person_1 = populateFullPerson(PERSON_ASADTest);
        Application__c app_1 = populateFullApplication(person_1);

        // Set form fields to valid values
        setStepZeroFields(c, app);
        setStepZeroFields(c,app_1);
        
        // Invoke step zero
        c.saveStepZero();
        
        setStepOneFields(c, app);
        setStepOneFields(c,app_1);

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());
        
        // Set step one
        setStepOneFields(c, app);
        setStepOneFields(c,app_1);

        // Invoke step one
        c.saveStepOne();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Set step two form fields to valid values
        setStepTwoFields(c, app);
        setStepTwoFields(c,app_1);

        // Invoke step two
        c.saveStepTwo();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Set step three fields
        setStepThreeFields(c, app);
        setStepThreeFields(c,app_1);

        // Invoke step three
        c.saveStepThree();

        // Assert no errors
        //System.assertEquals(0, ApexPages.getMessages().size());

        // Step step four fields
        setStepFourFields(c, app);
        setStepFourFields(c, app_1);

        // Initialize PowerCurve mock settings
        initializePowerCurveMock();

        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockErrorResponse());
        
        // Invoke step four
        PageReference landingPage = c.saveStepFour();

        Test.stopTest();
        
        String expectedLandingPage = '/apex/ApplicationDecision?Decision=Error&FirstName=' + 
                                     app.First_Name__c + '&id=' + c.Application.Id + '&LastName=' + app.Last_Name__c;

        // Assert no errors, landing page
        //System.assertEquals(0, ApexPages.getMessages().size());
        //System.assertEquals(expectedLandingPage, landingPage.getUrl());

        // Assert other PowerCurve related fields
        //System.assertEquals('Incomplete - PowerCurve error', c.Application.Name);        
    }

    
    private static Account insertTruncatedPerson(String name) {
        Account p = new Account();
        
        if (name == PERSON_SALLY) {
            p.FirstName = 'Sally';
            p.LastName = 'Truncated';
            p.PersonEmail = 'sallytrunc@test.com';
        }

        insert p;
        return p;
    }
    
    private static Account insertFullPerson(String name) {
        Account p = populateFullPerson(name);
        insert p;
        return p;
    }
    
    private static Account populateFullPerson(String name) {
        Account p = new Account();
        
        if (name == PERSON_ASAD) {
            p.Salutation = 'Mr.';
            p.FirstName = 'Asad';
            p.Middle_Name__pc = 'Full';
            p.LastName = 'Person';
            
            p.PersonMailingState = 'ON';
            p.PersonBirthdate = Date.newInstance(1983, 12, 2);
            p.Gender__pc = 'Male';
            p.Marital_Status__pc = 'Single';

            p.Employer_Province__pc = 'ON';
            p.Number_of_Dependants__pc = '0';
            p.Home_Owner__pc = 'Own';
            p.PersonMailingState = 'ON';
            
            p.PersonHomePhone = '1235551234';
            p.PersonEmail = 'asad.fullperson@test.com';
            p.SIN__pc = '123456789';
            p.PersonMobilePhone = '5551231234';
            p.Work_Phone__pc = '1112223333';

            p.Communication_Preference__pc = 'Email';
            p.Monthly_Home_Expense__pc = 2000;
            p.Monthly_Expense__pc = 500;

            p.PersonMailingStreet = '4 Glenora';
            p.PersonMailingCity = 'Brampton';
            p.PersonMailingPostalCode = 'L6Y4K5';

            // Set appropriate entry in Street address map (for later convenience)
            List<String> address = new List<String>();
            address.add('4');
            address.add('Glenora');
            streetAddressMap.put(p.PersonMailingStreet, address);

            p.Employer_Name__pc = 'Paper Empire';
            p.Employer_Phone__pc = '9991231234';
            p.Employer_Street_Name__pc = 'Brick Lane';
            p.Employer_Street_Number__pc = '4';
            p.Employer_City__pc = 'Brampton';
            p.Employer_Postal_Code__pc = 'L6Y4K4';
            p.Occupation__pc = 'Manager';
            p.Employment_Years__pc = 1; // Less than 2 yrs, will require previous employment info
            p.Employment_Months__pc = 10;
            p.Gross_Monthly_Income__pc = 5000;

        } else if (name == PERSON_DONNA) {
            p.Salutation = 'Ms.';
            p.FirstName = 'Donna';
            p.Middle_Name__pc = 'P';
            p.LastName = 'Summers';
            
            p.PersonMailingState = 'ON';
            p.PersonBirthdate = Date.newInstance(1970, 9, 14);
            p.Gender__pc = 'Female';
            p.Marital_Status__pc = 'Single';

            p.Employer_Province__pc = 'ON';
            p.Number_of_Dependants__pc = '1';
            p.Home_Owner__pc = 'Rent';
            p.PersonMailingState = 'ON';
            
            p.PersonHomePhone = '5551112222';
            p.PersonEmail = 'donna@summers.co.uk';
            p.SIN__pc = '987654321';
            p.PersonMobilePhone = '4169991234';
            p.Work_Phone__pc = '4161113333';

            p.Communication_Preference__pc = 'Email';
            p.Monthly_Home_Expense__pc = 800;
            p.Monthly_Expense__pc = 400;

            p.PersonMailingStreet = '10 Maple Ave.';
            p.PersonMailingCity = 'Brampton';
            p.PersonMailingPostalCode = 'L6X 5C3';

            // Set appropriate entry in Street address map (for later convenience)
            List<String> address = new List<String>();
            address.add('10');
            address.add('Maple Ave.');
            streetAddressMap.put(p.PersonMailingStreet, address);

            p.Employer_Name__pc = 'Tech Industries';
            p.Employer_Phone__pc = '4169059999';
            p.Employer_Street_Name__pc = 'Glass St.';
            p.Employer_Street_Number__pc = '1';
            p.Employer_City__pc = 'Toronto';
            p.Employer_Postal_Code__pc = 'L6Y4K9';
            p.Occupation__pc = 'Technician';
            p.Employment_Years__pc = 1; // Less than 2 yrs, requires previous employment info
            p.Employment_Months__pc = 7;
            p.Gross_Monthly_Income__pc = 4050;
        } else if (name == PERSON_ASADTest) {
            p.Salutation = 'Mr.';
            p.FirstName = 'Asad';
            p.Middle_Name__pc = 'Full';
            p.LastName = 'Person';
            
            p.PersonMailingState = 'ON';
            p.PersonBirthdate = Date.newInstance(1983, 12, 2);
            p.Gender__pc = 'Male';
            p.Marital_Status__pc = 'Single';

            p.Employer_Province__pc = 'ON';
            p.Number_of_Dependants__pc = '0';
            p.Home_Owner__pc = 'Own';
            p.PersonMailingState = 'ON';
            
            p.PersonHomePhone = '1235551234';
            p.PersonEmail = 'asad.fullperson@test.com';
            p.SIN__pc = '123456789';
            p.PersonMobilePhone = '5551231234';
            p.Work_Phone__pc = '1112223333';

            p.Communication_Preference__pc = 'Email';
            p.Monthly_Home_Expense__pc = 2000;
            p.Monthly_Expense__pc = 500;

            p.PersonMailingStreet = '4 Glenora';
            p.PersonMailingCity = 'Brampton';
            p.PersonMailingPostalCode = 'L6Y4K5';

            // Set appropriate entry in Street address map (for later convenience)
            List<String> address = new List<String>();
            address.add('4');
            address.add('Glenora');
            streetAddressMap.put(p.PersonMailingStreet, address);

            p.Employer_Name__pc = 'Paper Empire';
            p.Employer_Phone__pc = '9991231234';
            p.Employer_Street_Name__pc = 'Brick Lane';
            p.Employer_Street_Number__pc = '4';
            p.Employer_City__pc = 'Brampton';
            p.Employer_Postal_Code__pc = 'L6Y4K4';
            p.Occupation__pc = 'Manager';
            p.Employment_Years__pc = 1; // Less than 2 yrs, will require previous employment info
            p.Employment_Months__pc = 10;
            p.Gross_Monthly_Income__pc = 5000;

        }

        return p;
    }
    
    private static void assertSameTruncatedPerson(Account p, Account p2) {
        //System.assertEquals(p.Id, p2.Id);
        //System.assertEquals(p.FirstName, p2.FirstName);
        //System.assertEquals(p.LastName, p2.LastName);
        //System.assertEquals(p.PersonEmail, p2.PersonEmail);
    }
    
    private static void assertSameFullPerson(Account p, Account p2) {
        //System.assertEquals(p.Salutation, p2.Salutation);
        //System.assertEquals(p.FirstName, p2.FirstName);
        //System.assertEquals(p.Middle_Name__pc, p2.Middle_Name__pc);
        //System.assertEquals(p.LastName, p2.LastName);
        //System.assertEquals(p.PersonMailingState, p2.PersonMailingState);
        //System.assertEquals(p.PersonBirthdate, p2.PersonBirthdate);
        //System.assertEquals(p.Gender__pc, p2.Gender__pc);
        //System.assertEquals(p.Marital_Status__pc, p2.Marital_Status__pc);
        //System.assertEquals(p.Employer_Province__pc, p2.Employer_Province__pc);
        //System.assertEquals(p.Number_of_Dependants__pc, p2.Number_of_Dependants__pc);
        //System.assertEquals(p.Home_Owner__pc, p2.Home_Owner__pc);
        //System.assertEquals(p.PersonMailingState, p2.PersonMailingState);
        //System.assertEquals(p.PersonHomePhone, p2.PersonHomePhone);
        //System.assertEquals(p.PersonEmail, p2.PersonEmail);
        //System.assertEquals(p.SIN__pc, p2.SIN__pc);
        //System.assertEquals(p.PersonMobilePhone, p2.PersonMobilePhone);
        //System.assertEquals(p.Work_Phone__pc, p2.Work_Phone__pc);
        //System.assertEquals(p.Communication_Preference__pc, p2.Communication_Preference__pc);
        //System.assertEquals(p.Monthly_Home_Expense__pc, p2.Monthly_Home_Expense__pc);
        //System.assertEquals(p.Monthly_Expense__pc, p2.Monthly_Expense__pc);
        //System.assertEquals(p.PersonMailingStreet, p2.PersonMailingStreet);
        //System.assertEquals(p.PersonMailingCity, p2.PersonMailingCity);
        //System.assertEquals(p.PersonMailingPostalCode, p2.PersonMailingPostalCode);
        //System.assertEquals(p.Employer_Name__pc, p2.Employer_Name__pc);
        //System.assertEquals(p.Employer_Phone__pc, p2.Employer_Phone__pc);
        //System.assertEquals(p.Employer_Street_Name__pc, p2.Employer_Street_Name__pc);
        //System.assertEquals(p.Employer_Street_Number__pc, p2.Employer_Street_Number__pc);
        //System.assertEquals(p.Employer_City__pc, p2.Employer_City__pc);
        //System.assertEquals(p.Employer_Postal_Code__pc, p2.Employer_Postal_Code__pc);
        //System.assertEquals(p.Occupation__pc, p2.Occupation__pc);
        //System.assertEquals(p.Employment_Years__pc, p2.Employment_Years__pc);
        //System.assertEquals(p.Employment_Months__pc, p2.Employment_Months__pc);
        //System.assertEquals(p.Gross_Monthly_Income__pc, p2.Gross_Monthly_Income__pc);
    }
    
    private static void assertFormInitializedViaPerson(Account p, TPFidemApplicationFormController c) {
        // Check unbound fields
        //System.assertEquals(p.Salutation, c.SelSalutation);
        //System.assertEquals(p.FirstName, c.FirstName);
        //System.assertEquals(p.Middle_Name__pc, c.MiddleName);
        //System.assertEquals(p.LastName, c.LastName);
        //System.assertEquals(p.PersonMailingState, c.SelProvince);
        //System.assertEquals(p.PersonBirthdate.year(), c.BirthdateYear);
        //System.assertEquals(p.PersonBirthdate.month(), c.BirthdateMonth);
        //System.assertEquals(p.PersonBirthdate.day(), c.BirthdateDay);
        //System.assertEquals(p.Gender__pc, c.SelGender);
        //System.assertEquals(p.Marital_Status__pc, c.SelMaritalStatus);
        //System.assertEquals(p.Employer_Province__pc, c.SelEmployerProvince);
        //System.assertEquals(p.Number_of_Dependants__pc, c.SelNumberOfDependants);
        //System.assertEquals(p.Home_Owner__pc, c.SelPermanentRentOrOwn);
        //System.assertEquals(p.PersonMailingState, c.SelPermanentProvince);
        
        // Check bound fields
        //System.assertEquals(p.PersonHomePhone, c.Application.Home_Phone__c);
        //System.assertEquals(p.PersonEmail, c.Application.Email_Address__c);
        //System.assertEquals(p.SIN__pc, c.Application.SIN__c);
        //System.assertEquals(p.PersonMobilePhone, c.Application.Cell_Phone__c);
        //System.assertEquals(p.Work_Phone__pc, c.Application.Work_Phone__c);
        //System.assertEquals(p.Communication_Preference__pc, c.Application.Communications_Preference__c);
        //System.assertEquals(p.Monthly_Home_Expense__pc, c.Application.Housing_Costs__c);
        //System.assertEquals(p.Monthly_Expense__pc, c.Application.Monthly_Expenses__c);

        //System.assertEquals(p.PersonMailingCity, c.Application.Permanent_Address_City__c);
        //System.assertEquals(p.PersonMailingPostalCode, c.Application.Permanent_Address_PostalCode__c);
        //System.assertEquals(p.Employer_Name__pc, c.Application.Employer_Name__c);
        //System.assertEquals(p.Employer_Phone__pc, c.Application.Employer_Phone__c);
        //System.assertEquals(p.Employer_Street_Name__pc, c.Application.Employer_Street_Name__c);
        //System.assertEquals(p.Employer_Street_Number__pc, c.Application.Employer_Street_Number__c);
        //System.assertEquals(p.Employer_City__pc, c.Application.Employer_City__c);
        //System.assertEquals(p.Employer_Postal_Code__pc, c.Application.Employer_PostalCode__c);
        //System.assertEquals(p.Occupation__pc, c.Application.Occupation__c);
        //System.assertEquals(p.Employment_Years__pc, c.Application.Employment_Years__c);
        //System.assertEquals(p.Employment_Months__pc, c.Application.Employment_Months__c);
        //System.assertEquals(p.Gross_Monthly_Income__pc, c.Application.Gross_Monthly_Income__c);
    
        List<String> address = streetAddressMap.get(p.PersonMailingStreet);
        //System.assertEquals(address.get(0), String.valueOf(c.Application.Permanent_Address_Street_Number__c));
        //System.assertEquals(address.get(1), c.Application.Permanent_Address_Street_Name__c);
    }
    
    private static void assertStepOneFields(TPFidemApplicationFormController c, Application__c app) {
        //System.assertEquals(app.Has_Accepted_Disclosure_Terms__c, c.Application.Has_Accepted_Disclosure_Terms__c);
        //System.assertEquals(app.Province__c, c.Application.Province__c); //Manitoba Disclosure
        //System.assertEquals(app.Employment_Status__c, c.Application.Employment_Status__c);
        //System.assertEquals(app.Current_BKCP__c, c.Application.Current_BKCP__c);
        //System.assertEquals(app.Requested_Credit_Limit__c, c.Application.Requested_Credit_Limit__c);
        //System.assertEquals(app.Offer_Code__c, c.Application.Offer_Code__c);
        //System.assertEquals(app.Authorized_Credit_Check__c, c.Application.Authorized_Credit_Check__c);
        //System.assertEquals(app.Salutation__c, c.Application.Salutation__c);
        //System.assertEquals(app.First_Name__c, c.Application.First_Name__c);
        //System.assertEquals(app.Middle_Name__c, c.Application.Middle_Name__c);
        //System.assertEquals(app.Last_Name__c, c.Application.Last_Name__c);
        //System.assertEquals(app.Birth_Date__c, c.Application.Birth_Date__c);
        //System.assertEquals(app.SIN__c, c.Application.SIN__c);
        //System.assertEquals(app.Email_Address__c, c.Application.Email_Address__c);
    }
    
    // Sets step one non-person fields w/valid values
    private static void setStepOneNonPersonFieldsOnly(TPFidemApplicationFormController c, Application__c app) {
        // Set fields
        c.Application.Has_Accepted_Disclosure_Terms__c = app.Has_Accepted_Disclosure_Terms__c;
        //c.SelProvince = app.Province__c; //Manitoba Disclosure
        c.Application.Employment_Status__c = app.Employment_Status__c;
        c.SelCurrentBKCP = (app.Current_BKCP__c == true) ? 'Yes' : 'No';
        c.Application.Requested_Credit_Limit__c = app.Requested_Credit_Limit__c;
        //c.SelOfferCodeAvail = (app.Offer_Code__c == null) ? 'No' : 'Yes'; 
        c.Application.Offer_Code__c = app.Offer_Code__c;
        c.SelAuthorizedCreditCheck = (app.Authorized_Credit_Check__c == true) ? 'Yes' : 'No';
    }
    
    private static Application__c populateFullApplication(Account p) {
        Application__c app = new Application__c();

        // Populate fields from Person obj
        app.Salutation__c = p.Salutation;
        app.First_Name__c = p.FirstName;
        app.Middle_Name__c = p.Middle_Name__pc;
        app.Last_Name__c = p.LastName;
        app.Province__c = p.PersonMailingState;
            
        app.Birth_Date__c = p.PersonBirthdate;
        app.Gender__c = p.Gender__pc;
        app.Marital_Status__c = p.Marital_Status__pc;

        app.Employer_Province__c = p.Employer_Province__pc;
        app.Number_of_Dependants__c = p.Number_of_Dependants__pc;
        app.Permanent_Address_Province__c = p.PersonMailingState;

        app.Home_Phone__c = p.PersonHomePhone;
        app.Email_Address__c = p.PersonEmail;
        app.SIN__c = p.SIN__pc;
        app.Cell_Phone__c = p.PersonMobilePhone;
        app.Work_Phone__c = p.Work_Phone__pc;
        app.Communications_Preference__c = p.Communication_Preference__pc;
        app.Housing_Costs__c = p.Monthly_Home_Expense__pc;
        app.Monthly_Expenses__c = p.Monthly_Expense__pc;

        app.Permanent_Address_Street_Number__c = streetAddressMap.get(p.PersonMailingStreet).get(0);
        app.Permanent_Address_Street_Name__c = streetAddressMap.get(p.PersonMailingStreet).get(1);
        app.Permanent_Address_City__c = p.PersonMailingCity;
        app.Permanent_Address_PostalCode__c = p.PersonMailingPostalCode;

        app.Employer_Name__c = p.Employer_Name__pc;
        app.Employer_Phone__c = p.Employer_Phone__pc;
        app.Employer_Street_Name__c = p.Employer_Street_Name__pc;
        app.Employer_Street_Number__c = p.Employer_Street_Number__pc;   
        app.Employer_City__c = p.Employer_City__pc;
        app.Employer_PostalCode__c = p.Employer_Postal_Code__pc;
        app.Occupation__c = p.Occupation__pc;
            
        app.Employment_Years__c = p.Employment_Years__pc;
        app.Employment_Months__c = p.Employment_Months__pc;
        app.Gross_Monthly_Income__c = p.Gross_Monthly_Income__pc;
        app.Mortgage_With__c = 'TestMortgage';
        app.Tax_Identification_Number__c = '100001';
        //app.Canadian_SIN__c = 123456780;
        app.Tax_Obligation_in_other_Countries__c = true;
        
        // Populate non-Person fields
        if (p.FirstName == PERSON_ASAD) {
            app.Has_Accepted_Disclosure_Terms__c = false;
            app.Employment_Status__c = 'Part-time';
            app.Current_BKCP__c = false;
            app.Requested_Credit_Limit__c = 1000;
            app.Authorized_Credit_Check__c = true;

            app.Years_At_Permanent_Address__c = 5;
            app.Months_At_Permanent_Address__c = 10;

            app.Previous_Employer_Name__c = 'Paper Kingdom';
            app.Previous_Employer_Street_Number__c = '99';
            app.Previous_Employer_Street_Name__c = 'Paper St.';
            app.Previous_Employer_City__c = 'Brampton';
            app.Previous_Employer_Province__c = 'ON';
            app.Previous_Employer_PostalCode__c = 'L6T 4K2';
            app.Previous_Employment_Years__c = 10;
            app.Previous_Employment_Months__c = 2;
            app.Previous_Gross_Monthly_Income__c = 1500;
            app.Tax_Identification_Number__c = '2100001';
            //app.Canadian_SIN__c = 234567879;

            app.Consumer_Legal_Consent__c = 'true';
            app.Marketing_Consent__c = false;
            app.Application_Completed_Submitted__c = true;

            app.Politically_Exposed_Foreign_Person__c = true;
            app.PEFP_Who_Held_Position__c = 'Mother';
            app.PEFP_When_Held__c = 'President';
            app.PEFP_Where_Held__c = 'World Town';

            app.Third_Party_Direction__c  = true;
            app.TPD_Who_Will_Direct__c = 'Mother';
            app.TPD_Relationship_To_Applicant__c = 'mom';
            
            app.Loan_Type__c = 'Affirm Financial MasterCard';

        } else if (p.FirstName == PERSON_DONNA) {
            app.Has_Accepted_Disclosure_Terms__c = true;
            app.Employment_Status__c = 'Full-time';
            app.Current_BKCP__c = false;
            app.Requested_Credit_Limit__c = 2000;
            app.Authorized_Credit_Check__c = true;

            app.Years_At_Permanent_Address__c = 5;
            app.Months_At_Permanent_Address__c = 10;

            app.Previous_Employer_Name__c = 'Radio Box';
            app.Previous_Employer_Street_Number__c = '15';
            app.Previous_Employer_Street_Name__c = '1st Ave.';
            app.Previous_Employer_City__c = 'Brampton';
            app.Previous_Employer_Province__c = 'ON';
            app.Previous_Employer_PostalCode__c = 'L6V 2K6';
            app.Previous_Employment_Years__c = 4;
            app.Previous_Employment_Months__c = 10;
            app.Previous_Gross_Monthly_Income__c = 2000;
            app.Tax_Identification_Number__c = '2100001';
            //app.Canadian_SIN__c = 234567874;
            app.Tax_Obligation_in_other_Countries__c = true;

            app.Consumer_Legal_Consent__c = 'true';
            app.Marketing_Consent__c = true;
            app.Marketing_Consent_Date__c = Date.today();
            app.Application_Completed_Submitted__c = true;
            
            app.Politically_Exposed_Foreign_Person__c = true;
            app.PEFP_Who_Held_Position__c = 'Sister';
            app.PEFP_When_Held__c = 'Prime Minister';
            app.PEFP_Where_Held__c = 'Universe City';

            app.Third_Party_Direction__c  = true;
            app.TPD_Who_Will_Direct__c = 'Sister';
            app.TPD_Relationship_To_Applicant__c = 'sister';
            
            app.Loan_Type__c = 'Affirm Financial Term Loan';
        
        } else if (p.FirstName == PERSON_ASADTest) {
            app.Has_Accepted_Disclosure_Terms__c = false;
            app.Employment_Status__c = 'Part-time';
            app.Current_BKCP__c = false;
            app.Requested_Credit_Limit__c = 1000;
            app.Authorized_Credit_Check__c = true;

            app.Years_At_Permanent_Address__c = 5;
            app.Months_At_Permanent_Address__c = 10;

            app.Previous_Employer_Name__c = 'Paper Kingdom';
            app.Previous_Employer_Street_Number__c = '99';
            app.Previous_Employer_Street_Name__c = 'Paper St.';
            app.Previous_Employer_City__c = 'Brampton';
            app.Previous_Employer_Province__c = 'ON';
            app.Previous_Employer_PostalCode__c = 'L6T 4K2';
            app.Previous_Employment_Years__c = 10;
            app.Previous_Employment_Months__c = 2;
            app.Previous_Gross_Monthly_Income__c = 1500;
            app.Tax_Identification_Number__c = '1F234ST';
            //app.Canadian_SIN__c = 123456789;
            app.Tax_Obligation_in_other_Countries__c = true;

            app.Consumer_Legal_Consent__c = 'false';
            app.Marketing_Consent__c = false;
            app.Application_Completed_Submitted__c = false;

            app.Politically_Exposed_Foreign_Person__c = true;
            app.PEFP_Who_Held_Position__c = 'Mother';
            app.PEFP_When_Held__c = 'President';
            app.PEFP_Where_Held__c = 'World Town';

            app.Third_Party_Direction__c  = false;
            app.TPD_Who_Will_Direct__c = 'Mother';
            app.TPD_Relationship_To_Applicant__c = 'mom';
            
            app.Loan_Type__c = 'Fidem Financial MasterCard';

        }

        return app;
    }
    
    // Sets step one fields w/valid values
    private static void setStepOneFields(TPFidemApplicationFormController c, Application__c app) {
        setStepOneNonPersonFieldsOnly(c, app);

        // Set person fields
        c.SelSalutation = app.Salutation__c;
        c.FirstName = app.First_Name__c;
        c.MiddleName = app.Middle_Name__c;
        c.LastName = app.Last_Name__c;
        c.BirthdateYear = app.Birth_Date__c.year();
        c.BirthdateMonth = app.Birth_Date__c.month();
        c.BirthdateDay = app.Birth_Date__c.day();
        c.Application.SIN__c = app.SIN__c;
        c.Application.Email_Address__c = app.Email_Address__c;
        c.HasAcceptedDisclosureTerms = app.Has_Accepted_Disclosure_Terms__c;
        c.SIN = app.SIN__c;
        c.EmailAddress = app.Email_Address__c;
    }
    
    // Sets step one non-person fields w/valid values
    private static void setStepOneFieldsPersonAlreadyLoaded(TPFidemApplicationFormController c, Application__c app) {
        setStepOneNonPersonFieldsOnly(c, app);
    }
    
    private static TPFidemApplicationFormController initializeTest() {
        PageReference pageRef = Page.FidemApplicationForm;
        Test.setCurrentPage(pageRef);
        return new TPFidemApplicationFormController();
    }
    
    private static Campaign insertExpiredOfferCode() {
        Campaign c = new Campaign();
        c.Name = 'Test Offer Campaign';
        c.startDate = Date.today().addDays(-30);
        c.EndDate = Date.today().addDays(-1);
        c.Public_Offer_Code__c = false;
        c.Offer_Code__c = 'ABCDE';
        c.Offer_Code_Origination_System_Id__c = 'ABCDE';

        insert c;
        return c;
    }
    
    private static void setStepTwoFields(TPFidemApplicationFormController c, Application__c app) {
        c.SelGender = app.Gender__c;
        
        c.HomePhone = '1235551234';
        c.CellPhone = app.Cell_Phone__c; 
        c.WorkPhone = app.Work_Phone__c;
        
        c.PermanentAddressStreetNumber = app.Permanent_Address_Street_Number__c;
        c.PermanentAddressStreetName = app.Permanent_Address_Street_Name__c;
        c.PermanentAddressPOBox = app.Permanent_Address_PO_Box__c;
        c.PermanentAddressUnitNumber = '12';
        c.PermanentAddressCity = app.Permanent_Address_City__c;
        c.PermanentAddressPostalCode = app.Permanent_Address_PostalCode__c;
        c.YearsAtPermanentAddress = Integer.valueof(app.Years_At_Permanent_Address__c);
        c.MonthsAtPermanentAddress = Integer.valueOf(app.Months_At_Permanent_Address__c);
        c.HousingCosts = app.Housing_Costs__c;
        c.MortgageWith = app.Mortgage_With__c;
        c.MonthlyExpenses = app.Monthly_Expenses__c;
        
        c.PreviousAddressStreetNumber = app.Previous_Address_Street_Number__c;
        c.PreviousAddressStreetName = app.Previous_Address_Street_Name__c;
        c.PreviousAddressPoBox = app.Previous_Address_PO_Box__c;
        c.PreviousAddressUnitNumber = '23';
        c.PreviousAddressCity = app.Previous_Address_City__c;
        c.PreviousAddressPostalCode = app.Previous_Address_PostalCode__c;
        c.YearsAtPreviousAddress = Integer.valueOf(app.Years_At_Previous_Address__c);
        c.MonthsAtPreviousAddress = Integer.valueOf(app.Months_At_Previous_Address__c);
        
        c.Application.Home_Phone__c = app.Home_Phone__c;
        c.Application.Cell_Phone__c = app.Cell_Phone__c;
        c.Application.Work_Phone__c = app.Work_Phone__c;
        
        c.SelCommunicationsPreference = app.Communications_Preference__c;
        c.SelHowHeardAboutUs = app.How_Did_You_Hear_About_Us__c;
        
        //Incorrect interest rate for preferred partners - incidenet 44
        //c.SelReferralId = app.Referral_ID__c;
        
        c.Application.Referral_Name__c = app.Referral_Name__c;
        c.SelNumberofDependants = app.Number_of_Dependants__c;
        c.SelMaritalStatus = app.Marital_Status__c;
        
        c.Application.Permanent_Address_Street_Number__c = app.Permanent_Address_Street_Number__c;
        c.Application.Permanent_Address_Street_Name__c = app.Permanent_Address_Street_Name__c;
        c.Application.Permanent_Address_Unit_Number__c = app.Permanent_Address_Unit_Number__c;
        c.Application.Permanent_Address_City__c = app.Permanent_Address_City__c;
        c.SelPermanentProvince = app.Permanent_Address_Province__c;
        c.Application.Permanent_Address_PostalCode__c = app.Permanent_Address_PostalCode__c;
        c.Application.Years_At_Permanent_Address__c = app.Years_At_Permanent_Address__c;
        c.Application.Months_At_Permanent_Address__c = app.Months_At_Permanent_Address__c;

        c.Application.Housing_Costs__c = app.Housing_Costs__c;
        c.Application.Monthly_Expenses__c = app.Monthly_Expenses__c;

        c.Application.Previous_Address_Street_Number__c = app.Previous_Address_Street_Number__c;
        c.Application.Previous_Address_Street_Name__c = app.Previous_Address_Street_Name__c;
        c.Application.Previous_Address_Unit_Number__c = app.Previous_Address_Unit_Number__c;
        c.Application.Previous_Address_City__c = app.Previous_Address_City__c;
        c.SelPreviousProvince = app.Previous_Address_Province__c;
        c.Application.Previous_Address_PostalCode__c = app.Previous_Address_PostalCode__c;
        c.Application.Years_At_Previous_Address__c = app.Years_At_Previous_Address__c;
        c.Application.Months_At_Previous_Address__c = app.Months_At_Previous_Address__c;
        
        //Risk Based Pricing
        if(c.SelPermanentRentOrOwn == 'Own Property'){
            if(app.Housing_Costs__c != null && app.Housing_Costs__c > 0){
                app.Mortgage_With__c = 'TestMortgage';
                c.Application.Mortgage_With__c = app.Mortgage_With__c;
            }
        }  
        c.Application.Mortgage_With__c = app.Mortgage_With__c;      
    }
    
    private static Account queryPerson(String id) {
        List<Account> existingAccList = null;
        if (id != null) {
            existingAccList = [ Select Id, FirstName, Middle_Name__pc, LastName, 
                                Salutation, PersonBirthdate, 
                                PersonHomePhone, PersonEmail, Gender__pc, 
                                SIN__pc, PersonMobilePhone, Work_Phone__pc, 
                                Communication_Preference__pc, Marital_Status__pc,
                                Number_of_Dependants__pc, Home_Owner__pc, Monthly_Home_Expense__pc,
                                Monthly_Expense__pc, PersonMailingStreet, PersonMailingCity, 
                                PersonMailingState, PersonMailingPostalCode,
                                Employer_Name__pc, Employer_Phone__pc,
                                Employer_Street_Name__pc, Employer_Street_Number__pc,
                                Employer_City__pc, Employer_Province__pc,
                                Employer_Postal_Code__pc, Occupation__pc, 
                                Employment_Years__pc, Employment_Months__pc, Gross_Monthly_Income__pc
                                from Account where Id = :id
                              ];
        }

        if (existingAccList != null && !existingAccList.isEmpty()) {
            return existingAccList[0];
        }

        return null;
    }
    
    private static Application__c queryApplication(String id) {
        List<Application__c> existingAppList = null;
        if (id != null) {
            existingAppList = [
                select Id, Salutation__c, First_Name__c, Middle_Name__c, Last_Name__c, 
                    Province__c, Birth_Date__c, Gender__c, Marital_Status__c, 
                    Employer_Province__c, Number_of_Dependants__c, Offer_Code__c, 
                    Permanent_Address_Province__c, Home_Phone__c, 
                    Email_Address__c, SIN__c, Cell_Phone__c, Work_Phone__c,
                    How_Did_You_Hear_About_Us__c, Communications_Preference__c, 
                    Referral_ID__c, Referral_Name__c,
                    Housing_Costs__c, Monthly_Expenses__c, Permanent_Address_Street_Number__c,
                    Permanent_Address_Street_Name__c, Permanent_Address_Unit_Number__c, 
                    Permanent_Address_City__c, Permanent_Address_PostalCode__c, 
                    Years_At_Permanent_Address__c, Months_At_Permanent_Address__c,
                    Previous_Address_Street_Number__c,
                    Previous_Address_Street_Name__c, Previous_Address_Unit_Number__c, 
                    Previous_Address_City__c, Previous_Address_Province__c, Previous_Address_PostalCode__c, 
                    Years_At_Previous_Address__c, Months_At_Previous_Address__c,
                    Employer_Name__c, Employer_Phone__c, Employer_City__c, Employer_PostalCode__c,
                    Occupation__c, Employment_Years__c, Employment_Months__c, 
                    Gross_Monthly_Income__c, Tax_Identification_Number__c,/*Canadian_SIN__c,*/
                    Tax_Obligation_in_other_Countries__c,
                    Has_Accepted_Disclosure_Terms__c,Canaccede_Marketing_Consent__c,
                    Employment_Status__c, Current_BKCP__c, Requested_Credit_Limit__c,
                    Authorized_Credit_Check__c, Loan_Type__c
                from Application__C where Id = :id
            ];

            if (existingAppList != null && !existingAppList.isEmpty()) {
                return existingAppList[0];
            }
        }

        return null;
    }
    
    private static void assertSameApplicationUpToStepTwo(Application__c app, Application__c a) {
        //System.assertEquals(app.Has_Accepted_Disclosure_Terms__c, a.Has_Accepted_Disclosure_Terms__c);
        //System.assertEquals(app.Province__c, a.Province__c); ////Manitoba Disclosure

        //System.assertEquals(app.Employment_Status__c, a.Employment_Status__c);
        //System.assertEquals(app.Current_BKCP__c, a.Current_BKCP__c);
        //System.assertEquals(app.Requested_Credit_Limit__c, a.Requested_Credit_Limit__c);
        //System.assertEquals(app.Offer_Code__c, a.Offer_Code__c);
        //System.assertEquals(app.Authorized_Credit_Check__c, a.Authorized_Credit_Check__c);
        //System.assertEquals(app.Gender__c, a.Gender__c);
        //System.assertEquals(app.Home_Phone__c, a.Home_Phone__c);
        //System.assertEquals(app.Cell_Phone__c, a.Cell_Phone__c);
        //System.assertEquals(app.Work_Phone__c, a.Work_Phone__c);
        //System.assertEquals(app.Communications_Preference__c, a.Communications_Preference__c);
        //System.assertEquals(app.How_Did_You_Hear_About_Us__c, a.How_Did_You_Hear_About_Us__c);
        //System.assertEquals(app.Referral_ID__c, a.Referral_ID__c);
        //System.assertEquals(app.Referral_Name__c, a.Referral_Name__c);
        //System.assertEquals(app.Number_of_Dependants__c, a.Number_of_Dependants__c);
        //System.assertEquals(app.Marital_Status__c, a.Marital_Status__c);

        //System.assertEquals(app.Permanent_Address_Street_Number__c, a.Permanent_Address_Street_Number__c);
        //System.assertEquals(app.Permanent_Address_Street_Name__c, a.Permanent_Address_Street_Name__c);
        //System.assertEquals(app.Permanent_Address_Unit_Number__c, a.Permanent_Address_Unit_Number__c);
        //System.assertEquals(app.Permanent_Address_City__c, a.Permanent_Address_City__c);
        //System.assertEquals(app.Permanent_Address_Province__c, a.Permanent_Address_Province__c);
        //System.assertEquals(app.Permanent_Address_PostalCode__c, a.Permanent_Address_PostalCode__c);
        //System.assertEquals(app.Years_At_Permanent_Address__c, a.Years_At_Permanent_Address__c);
        //System.assertEquals(app.Months_At_Permanent_Address__c, a.Months_At_Permanent_Address__c);

        //System.assertEquals(app.Housing_Costs__c, a.Housing_Costs__c);
        //System.assertEquals(app.Monthly_Expenses__c, a.Monthly_Expenses__c);

        //System.assertEquals(app.Previous_Address_Street_Number__c, a.Previous_Address_Street_Number__c);
        //System.assertEquals(app.Previous_Address_Street_Name__c, a.Previous_Address_Street_Name__c);
        //System.assertEquals(app.Previous_Address_Unit_Number__c, a.Previous_Address_Unit_Number__c);
        //System.assertEquals(app.Previous_Address_City__c, a.Previous_Address_City__c);
        //System.assertEquals(app.Previous_Address_Province__c, a.Previous_Address_Province__c);
        //System.assertEquals(app.Previous_Address_PostalCode__c, a.Previous_Address_PostalCode__c);
        //System.assertEquals(app.Years_At_Previous_Address__c, a.Years_At_Previous_Address__c);
        //System.assertEquals(app.Months_At_Previous_Address__c, a.Months_At_Previous_Address__c);
    }
    
    private static void setStepThreeFields(TPFidemApplicationFormController c, Application__c app) {
        
        c.EmployerName = app.Employer_Name__c;
        c.EmployerPhone = '1232347653';
        c.EmployerStreetNumber = app.Employer_Street_Number__c;
        c.EmployerStreetName = app.Employer_Street_Name__c;
        c.EmployerPoBox = app.Employer_PO_Box__c;
        c.EmployerUnitNumber = '12';
        c.EmployerCity = app.Employer_City__c;
        c.EmployerPostalCode = app.Employer_PostalCode__c;
        c.EmploymentYears = app.Employment_Years__c;
        c.EmploymentMonths = app.Employment_Months__c;
        c.GrossAnnualIncome = app.Gross_Annual_Income__c;
        
        c.PreviousEmployerName = app.Previous_Employer_Name__c;
        c.PreviousEmployerStreetNumber = app.Previous_Employer_Street_Number__c; 
        c.PreviousEmployerStreetName = app.Previous_Employer_Street_Name__c;
        c.PreviousEmployerPoBox = app.Previous_Employer_PO_Box__c;
        c.PreviousEmployerUnitNumber = '23';
        c.PreviousEmployerCity = app.Previous_Employer_City__c;
        c.PreviousEmployerPostalCode = app.Previous_Employer_PostalCode__c;
        c.PreviousEmploymentYears = app.Previous_Employment_Years__c;
        c.PreviousEmploymentMonths = app.Previous_Employment_Months__c;
        c.PreviousGrossAnnualIncome = app.Previous_Gross_Annual_Income__c;
        
        c.Application.Employer_Name__c = app.Employer_Name__c;
        c.Application.Employer_Phone__c = app.Employer_Phone__c;
        c.Application.Employer_Street_Number__c = app.Employer_Street_Number__c;
        c.Application.Employer_Street_Name__c = app.Employer_Name__c;
        c.Application.Employer_Unit_Number__c = app.Employer_Unit_Number__c;
        c.Application.Employer_City__c = app.Employer_City__c;
        c.SelEmployerProvince = app.Employer_Province__c;
        c.Application.Employer_PostalCode__c = app.Employer_PostalCode__c;
        c.Application.Occupation__c = app.Occupation__c;
        c.Application.Employment_Years__c = app.Employment_Years__c;
        c.Application.Employment_Months__c = app.Employment_Months__c;
        c.Application.Gross_Monthly_Income__c = app.Gross_Monthly_Income__c;

        c.Application.Previous_Employer_Name__c = app.Previous_Employer_Name__c;
        c.Application.Previous_Employer_Street_Number__c = app.Previous_Employer_Street_Number__c;
        c.Application.Previous_Employer_Street_Name__c = app.Previous_Employer_Name__c;
        c.Application.Previous_Employer_Unit_Number__c = app.Previous_Employer_Unit_Number__c;
        c.Application.Previous_Employer_City__c = app.Previous_Employer_City__c;
        c.SelPreviousEmployerProvince = app.Previous_Employer_Province__c;
        c.Application.Previous_Employer_PostalCode__c = app.Previous_Employer_PostalCode__c;
        c.Application.Previous_Employment_Years__c = app.Previous_Employment_Years__c;
        c.Application.Previous_Employment_Months__c = app.Previous_Employment_Months__c;
        c.Application.Previous_Gross_Monthly_Income__c = app.Previous_Gross_Monthly_Income__c;
    }
    
    private static void assertSameApplicationUpToStepThree(Application__c app, Application__c a) {
        assertSameApplicationUpToStepTwo(app, a);

        //System.assertEquals(app.Employer_Name__c, a.Employer_Name__c);
        //System.assertEquals(app.Employer_Phone__c, a.Employer_Phone__c);
        //System.assertEquals(app.Employer_Street_Number__c, a.Employer_Street_Number__c);
        //System.assertEquals(app.Employer_Name__c, a.Employer_Name__c);
        //System.assertEquals(app.Employer_Unit_Number__c, a.Employer_Unit_Number__c);
        //System.assertEquals(app.Employer_City__c, a.Employer_City__c);
        //System.assertEquals(app.Employer_Province__c, a.Employer_Province__c);
        //System.assertEquals(app.Employer_PostalCode__c, a.Employer_PostalCode__c);
        //System.assertEquals(app.Occupation__c, a.Occupation__c);
        //System.assertEquals(app.Employment_Years__c, a.Employment_Years__c);
        //System.assertEquals(app.Employment_Months__c, a.Employment_Months__c);
        //System.assertEquals(app.Gross_Monthly_Income__c, a.Gross_Monthly_Income__c);
        //System.assertEquals(app.Previous_Employer_Name__c, a.Previous_Employer_Name__c);
        //System.assertEquals(app.Previous_Employer_Street_Number__c, a.Previous_Employer_Street_Number__c);
        //System.assertEquals(app.Previous_Employer_Name__c, a.Previous_Employer_Name__c);

        //System.assertEquals(app.Previous_Employer_Unit_Number__c, a.Previous_Employer_Unit_Number__c);
        //System.assertEquals(app.Previous_Employer_City__c, a.Previous_Employer_City__c);
        //System.assertEquals(app.Previous_Employer_Province__c, a.Previous_Employer_Province__c);
        //System.assertEquals(app.Previous_Employer_PostalCode__c, a.Previous_Employer_PostalCode__c);
        //System.assertEquals(app.Previous_Employment_Years__c, a.Previous_Employment_Years__c);
        //System.assertEquals(app.Previous_Employment_Months__c, a.Previous_Employment_Months__c);
        //System.assertEquals(app.Previous_Gross_Monthly_Income__c, a.Previous_Gross_Monthly_Income__c);
    }

    private static void assertSameApplicationUpToStepFour(Application__c app, Application__c a) {
        assertSameApplicationUpToStepThree(app, a);

        //System.assertEquals(app.Consumer_Legal_Consent__c, a.Consumer_Legal_Consent__c);
        //System.assertEquals(app.Marketing_Consent__c, a.Marketing_Consent__c);
        
        //System.assertEquals(app.Politically_Exposed_Foreign_Person__c, a.Politically_Exposed_Foreign_Person__c);
        //System.assertEquals(app.PEFP_Who_Held_Position__c, a.PEFP_Who_Held_Position__c);
        //System.assertEquals(app.PEFP_When_Held__c, a.PEFP_When_Held__c);
        //System.assertEquals(app.PEFP_Where_Held__c, a.PEFP_Where_Held__c);
        
        //System.assertEquals(app.Third_Party_Direction__c, a.Third_Party_Direction__c);
        //System.assertEquals(app.TPD_Who_Will_Direct__c, a.TPD_Who_Will_Direct__c);
        //System.assertEquals(app.TPD_Relationship_To_Applicant__c, a.TPD_Relationship_To_Applicant__c);

        //System.assertEquals(app.Marketing_Consent_Date__c, a.Marketing_Consent_Date__c);
        //System.assertEquals(app.Application_Completed_Submitted__C, a.Application_Completed_Submitted__c);
    }
    
    private static void setStepZeroFields(TPFidemApplicationFormController c, Application__c app) {
        c.SelLoanType = app.Loan_Type__c;
        c.SelProvince = 'MB';
        //Risk Based Pricing
        if(String.isNotBlank(app.Loan_Type__c)){
            if(app.Loan_Type__c == CREDIT_CARD){
                c.selHomeOwnerOptions = 'Yes';
            }
        }
    }
    
    private static void setStepFourFields(TPFidemApplicationFormController c, Application__c app) {
        c.isConsumerLegalConsent = (app.Consumer_Legal_Consent__c == 'true') ? true : false;
        c.Application.Marketing_Consent__c = app.Marketing_Consent__c;
        
        c.SelPoliticallyExposedForeignPerson = (app.Politically_Exposed_Foreign_Person__c == true) ? 'Yes' : 'No';
        c.Application.PEFP_Who_Held_Position__c = app.PEFP_Who_Held_Position__c;
        c.Application.PEFP_When_Held__c = app.PEFP_When_Held__c;
        c.Application.PEFP_Where_Held__c = app.PEFP_Where_Held__c;

        c.SelThirdPartyDirection = (app.Third_Party_Direction__c  == true)  ? 'Yes' : 'No';
        c.Application.TPD_Who_Will_Direct__c = app.TPD_Who_Will_Direct__c;
        c.Application.TPD_Relationship_To_Applicant__c = app.TPD_Relationship_To_Applicant__c;
    }
    
    private static Campaign insertOfferCode() {
        Campaign c = new Campaign();
        c.Name = 'Test Offer Campaign';
        c.startDate = Date.today().addDays(-1);
        c.EndDate = Date.today().addDays(30);
        c.Public_Offer_Code__c = false;
        c.Offer_Code__c = 'ABCDE';
        c.Offer_Code_Origination_System_Id__c = 'ABCDE';

        insert c;
        return c;
    }
    
    private static void initializePowerCurveMock() {
        Application_Form_Settings__c afSettings = new Application_Form_Settings__c(
            Power_Curve_Web_Service_URL__c = PowerCurveTestUtilities.Power_Curve_Web_Service_URL,
            Power_Curve_Username__c = PowerCurveTestUtilities.Power_Curve_Username, 
            Power_Curve_Password__c = PowerCurveTestUtilities.Power_Curve_Password, 
            Site_Profile_Id__c = '00eK0000000MDqzIAG'
        );
        insert afSettings;
    }
}