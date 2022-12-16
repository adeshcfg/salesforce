/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class for Third Party Referral Fidem Application Form. 
 *  @author : A5E Consulting
 *  @date : 03/15/2022
 * 
 *************************************************************************************************/

public without sharing class TPFidemApplicationFormController {

    public Application_Form_Settings__c AppFormSettings {get;set;}
    public Application_Form_Configuration__c afSettings{get;set;}
    public Account PersonAccount {get;set;}
    public Application__c Application {get;set;} 
    public Boolean Showpopup{get;set;}
    public Boolean PersonAlreadyLoaded {get;set;}
    public Boolean PersonFoundViaQuery {get;set;}
    public Boolean PersonInserted {get;set;}
    public String imageURL{get;set;}
    public List<SelectOption> LoanTypeOptions {get;set;}
    public List<SelectOption> LoanTypeOptions2 {get;set;}
    public String SelLoanType {get;set;}
    public String SelLoanType2 {get;set;}
    //public Boolean IsLoan {get;set;}
    public String wouldYouLikeToApply{get;set;}
    public List<SelectOption> wouldYouLikeToApplyOptions{get;set;}
    public String birthDateApplication{get;set;}
    public String insolvencyDateApplication{get;set;}
    public String trusteeCompanyName{get;set;}
    //public String otherTrusteeName{get;set;}
    public String stringOccupation{get;set;}
    public String industryValue{get;set;}
    public String jobDescriptionValue{get;set;}
    public String Origination = 'Trustee Product';
    
    //recordType for application
    private list<RecordType> listProductRecordType;
    
    //To Manage dependent picklist vlaues
    public Map<String, List<String>> mapDependentPicklist;
    List<SelectOption> derivedJobDescriptionList = new List<SelectOption>();
    
    public List<SelectOption> SalutationOptions {get;set;}
    public String SelSalutation {get;set;}
    
    public List<SelectOption> BorrowAmountOptions {get;set;}
    public string SelBorrowAmount {get;set;}
    
    public List<SelectOption> PrimaryPhoneOptions {get;set;}
    public string SelPrimaryPhone {get;set;}
    
    public String PlaceholderFirstName {get;set;}
    public String PlaceholderMiddleName {get;set;}
    public String PlaceholderLastName {get;set;}
    
    public Integer BirthdateYear {get;set;}
    public Integer BirthdateMonth {get;set;}
    public Integer BirthdateDay {get;set;}
    
    public String PlaceholderBirthdateYear {get;set;}
    public String PlaceholderBirthdateMonth {get;set;}
    public String PlaceholderBirthdateDay {get;set;}
    
    public List<SelectOption> ProvinceOptions {get;set;}
    public String SelProvince {get;set;}
    
    public List<SelectOption> CurrentBKCPOptions {get;set;}
    public String SelCurrentBKCP {get;set;}
    
    //Trustee dropdown list
    //public List<SelectOption> TrusteeNameOptions {get;set;}
    //public String SelTrusteeName {get;set;}
    
    //public List<SelectOption> OfferCodeAvailOptions {get;set;}
    //public String SelOfferCodeAvail {get;set;}
    
    public List<SelectOption> AuthorizedCreditCheckOptions {get;set;}
    public String SelAuthorizedCreditCheck {get;set;}
    
    //Employment dropdown list
    public List<SelectOption> EmploymentStatusOptions {get;set;}
    public String SelEmploymentStatus {get;set;}
    
    public List<SelectOption> GenderOptions {get;set;}
    public String SelGender {get;set;}
    
    public List<SelectOption> CommunicationsPreferenceOptions {get;set;}
    public String SelCommunicationsPreference {get;set;}
    
    public List<SelectOption> HowHeardAboutUsOptions {get;set;}
    public String SelHowHeardAboutUs {get;set;}
    
    public List<SelectOption> ReferralIdOptions {get;set;}
    
    //Incorrect interest rate for preferred partners - incidenet 44
    //public String SelReferralId {get;set;}
    
    public List<SelectOption> NumberOfDependantsOptions {get;set;}
    public String SelNumberOfDependants {get;set;}
    
    public List<SelectOption> primaryPhoneNumber {get;set;}
    public String selPrimaryPhoneNumber {get;set;}
    
    public List<SelectOption> MaritalStatusOptions {get;set;}
    public String SelMaritalStatus {get;set;}
    
    public List<SelectOption> PermanentProvinceOptions {get;set;}
    public String SelPermanentProvince {get;set;}
    
    public List<SelectOption> PermanentRentOrOwnOptions {get;set;}
    public String SelPermanentRentOrOwn {get;set;}
    
    public List<SelectOption> PreviousProvinceOptions {get;set;}
    public String SelPreviousProvince {get;set;}
    
    public List<SelectOption> EmployerProvinceOptions {get;set;}
    public String SelEmployerProvince {get;set;}
    
    public List<SelectOption> PreviousEmployerProvinceOptions {get;set;}
    public String SelPreviousEmployerProvince {get;set;}
    
    public Boolean isConsumerLegalConsent {get;set;}
    
    public List<SelectOption> FATCATsxObligationOptions{get;set;}
    public String SelFATCATsxObligation {get;set;}
    
    public List<SelectOption> PoliticallyExposedForeignPersonOptions {get;set;}
    public String SelPoliticallyExposedForeignPerson {get;set;}
    
    public List<SelectOption> ThirdPartyDirectionOptions {get;set;}
    public String SelThirdPartyDirection {get;set;}
    
    public List<SelectOption> SoleApplicantOptions {get;set;}
    public String SelSoleApplicant {get;set;}
    
    // Offer Code related fields
    //public Boolean isValidOfferCode {get;set;}
    //public String nonCampaignMemberMessage {get;set;}
    
    // Disclosure URLs
    public String CreditCardDisclosureURL {get;set;}
    //public String LoanDisclosureURL {get;set;}
    
    //Risk Based Pricing
    public String creditCardRentalDisclosureURL {get;set;}
    
    private RecordType personAccRecType;
    private String personAccSFID;
    private final String NONE_SEL_TEXT = '--None--';
    private final String PLEASE_SEL_TEXT = 'Please Select';
    private final String YES_SEL_TEXT = 'Yes';
    private final String NO_SEL_TEXT = 'No';
    private final String RENT_SEL_TEXT = 'Rent';
    private final String OWN_SEL_TEXT = 'Own Property';
    private final String TRUE_TEXT = 'true';
    private final String FALSE_TEXT = 'false';
    private final String CREDIT_CARD = 'Fidem Finance MasterCard';
    private final String TERM_LOAN = 'Fidem Finance Term Loan';
    private final String VERIFICATION_STATUS_EMAIL_SENT_SYSTEM = 'Email Sent – System';
    
    private Map<String, Integer> provinceToAgeOfMajorityMap;
    
    private final String APP_NAME_INCOMPLETE = 'Incomplete';
    //private final String APP_NAME_INCOMPLETE_POWER_CURVE_ERR = 'Incomplete';
    
    // Error Messages
    // Step Zero messages
    //private final String ERR_LOAN_TYPE = 'You must select a Loan Type.';
    private final String ERR_HOME_OWNER = 'Please specify if you are a Home Owner.';
    
    // Step One messages
    private final String ERR_AGE_OF_MAJORITY = 'You must be at the age of Majority before you may apply for Credit in this Province.';
    private final String ERR_HAS_ACCEPTED_DISCLOSURE_TERMS = 'You must accept the disclosure terms to proceed.';    
    private final String ERR_SALUTATION = 'You must provide a valid salutation.';
    private final String ERR_FIRST_NAME = 'You must provide a first name.';
    private final String ERR_MIDDLE_NAME = 'You must provide a middle name.';
    private final String ERR_LAST_NAME = 'You must provide a last name.';
    private final String ERR_PROVINCE = 'You must select a valid province.';
    private final String ERR_BIRTH_DATE = 'You must provide a valid birth date.';
    private final String ERR_SIN = 'Please provide a valid SIN.';
    private final String ERR_EMAIL_ADDRESS = 'Please provide a valid email address';
    private final String ERR_EMPLOYMENT_STATUS = 'You must provide a valid employment status.';
    private final String ERR_EMPLOYMENT_STATUS_UNQUALIFIED = 'Fidem application cannot proceed due to your employment status.';
    private final String ERR_CURRENT_BKCP = 'You must answer the bankruptcy question.';
    private final String ERR_REQUESTED_CREDIT_LIMIT = 'You must provide how much you wish to borrow.';
    private final String ERR_AUTHORIZED_CREDIT_CHECK = 'Fidem application must be authorized to perform a credit check to proceed.';
    private final String ERR_SOLE_APPLICANT_CHECK = 'To proceed, you must confirm you are the sole applicant.';
    private final String ERR_OTHER_TRUSTEE_CHECK = 'To proceed you must provide the value';
    private final String ERR_INSOLVENCY_DATE = 'You must provide a Insolvency Date';
    //private final String ERR_INVALID_OFFER_CODE = 'Invalid offer code.';
    
    //Manitoba Updates
    private final String ERR_HAS_ACCEPTED_PERSONAL_CONSENT = 'Please accept the terms to proceed.';   
    
    // Step Two messages
    private final String ERR_GENDER = 'You must select a gender.';
    private final String ERR_HOME_PHONE = 'You must provide your home phone number.';
    private final String ERR_CELL_PHONE = 'Please provide a valid cell phone number.';
    private final String ERR_WORK_PHONE = 'You must provide your work phone number.';
    private final String ERR_COMMUNICATIONS_PREFERENCE = 'Please select a valid communications preference.';
    private final String ERR_HOW_HEARD_ABOUT_US = 'Please select a valid answer to how you heard about us.';
    private final String ERR_REFERRAL_ID = 'Please select a valid referral Id.';
    private final String ERR_NUMBER_OF_DEPENDANTS = 'You must select your number of dependants.';
    private final String ERR_MARITAL_STATUS = 'You must select a valid marital status';
    private final String ERR_PERMANENT_ADDRESS_STREET_NUMBER = 'You must provide your street number';
    private final String ERR_PERMANENT_ADDRESS_STREET_NAME = 'You must provide your street name';
    private final String ERR_PERMANENT_ADDRESS_CITY = 'You must provide the city you live in';
    private final String ERR_PERMANENT_ADDRESS_PROVINCE = 'You must provide the province you live in';
    private final String ERR_PERMANENT_ADDRESS_POSTAL_CODE = 'You must provide a valid postal code';
    private final String ERR_HOW_LONG = 'You must provide how long you lived at your current address.';
    
    private final String ERR_PERMANENT_RENT_OR_OWN = 'You must answer whether you rent or own.';
    private final String ERR_HOUSING_COSTS = 'You must provide a valid amount for your housing costs';
    private final String ERR_MORTGAGE_WITH = 'Please specify who is your mortgage with.';
    private final String ERR_MONTHLY_EXPENSES = 'You must provide a valid amount for your monthly expenses';
    private final String ERR_PREVIOUS_ADDRESS_STREET_NUMBER = 'You must provide your previous street number';
    private final String ERR_PREVIOUS_ADDRESS_STREET_NAME = 'You must provide your previous street name';
    private final String ERR_PREVIOUS_ADDRESS_CITY = 'You must provide the previous city you lived in';
    private final String ERR_PREVIOUS_ADDRESS_PROVINCE = 'You must provide the previous province you lived in';
    private final String ERR_PREVIOUS_ADDRESS_POSTAL_CODE = 'You must provide a valid previous postal code';
    private final String ERR_PREVIOUS_ADDRESS_HOW_LONG = 'You must provide how long you lived at your previous address.';
    private final String ERR_POSTALCODE_PROVINCE = 'Postal Code does not match selected province.';
    
    // Step Three messages
    private final String ERR_EMPLOYER_NAME = 'You must provide your employer name.';
    private final String ERR_EMPLOYER_PHONE = 'You must provide your employer phone number.';
    private final String ERR_EMPLOYER_STREET_NUMBER = 'You must provide your employer street number.';
    private final String ERR_EMPLOYER_STREET_NAME = 'You must provide your employer street name.';
    private final String ERR_EMPLOYER_CITY = 'You must provide your employer city.';
    private final String ERR_EMPLOYER_PROVINCE = 'You must provide your employer province.';
    private final String ERR_EMPLOYER_OCCUPATION = 'You must select your occupation.';
    private final String ERR_EMPLOYER_INDUSTRY = 'You must select industry you work in.';
    private final String ERR_EMPLOYER_JOB_DESCRIPTION = 'You must select your job description.';
    private final String ERR_EMPLOYER_POSTAL_CODE = 'You must provide your employer postal code.';
    private final String ERR_HOW_LONG_EMPLOYER = 'You must provide how long you worked at your employer.';
    private final String ERR_GROSS_MONTHLY_INCOME = 'You must provide your gross monthly income.';
    private final String ERR_GROSS_ANNUAL_INCOME = 'You must provide your gross annual income.';
    
    private final String ERR_PREVIOUS_EMPLOYER_NAME = 'You must provide your previous employer name.';
    private final String ERR_PREVIOUS_EMPLOYER_STREET_NUMBER = 'You must provide your previous employer street number.';
    private final String ERR_PREVIOUS_EMPLOYER_STREET_NAME = 'You must provide your previous employer street name.';
    private final String ERR_PREVIOUS_EMPLOYER_CITY = 'You must provide your previous employer city.';
    private final String ERR_PREVIOUS_EMPLOYER_PROVINCE = 'You must provide your previous employer province.';
    private final String ERR_PREVIOUS_EMPLOYER_POSTAL_CODE = 'You must provide your previous employer postal code.';
    private final String ERR_HOW_LONG_PREVIOUS_EMPLOYER = 'You must provide how long you worked at your previous employer.';
    private final String ERR_PREVIOUS_GROSS_MONTHLY_INCOME = 'You must provide your previous gross monthly income.';
    private final String ERR_PREVIOUS_GROSS_ANNUAL_INCOME = 'You must provide your previous gross annual income.';
    
    // Step Four message
    private final String ERR_HOW_CONSUMER_LEGAL_CONSENT = 'Fidem cannot proceed without your consent.';    
    private final String ERR_POLITICALLY_EXPOSED_FOREIGN_PERSON = 'You must answer the question regarding foreign politically relatives.';
    private final String ERR_THIRD_PARTY_DIRECTION = 'You must answer the question regarding third party direction.';
    private final String ERR_SOLE_APPLICANT = 'You must answer the question regarding sole applicant for the card.';
    // private final String ERR_AFFRIM_SYSTEM_ERROR = 'System is unavailable currently. Please try again later or contact a representative.';
    
    //Disclosure Statements Presented
    //private final String CC_HOME_OWNER_DISCLOSURE_STMT = 'Fidem Finance MasterCard - 34.99%';
    //private final String CC_RENTAL_DISCLOSURE_STMT = 'Affirm Financial MasterCard - 34.99%';
    //private final String CC_RENTAL_DISCLOSURE_STMT = 'Fidem Finance MasterCard - 39.99%';
    private final String CC_HOME_OWNER_DISCLOSURE_STMT = 'Third Party MasterCard - Home Owner';
    private final String CC_RENTAL_DISCLOSURE_STMT = 'Third Party MasterCard - Rental';
        
    private final String DECISION_DECLINED = 'Rejected';
    private final String DECISION_Rejected = 'Rejected';
    
    // Decision params for landing page
    private final String DECISION_PARAM_ERROR = 'Error';
    //private final String DECISION_PARAM_OFFER = 'OfferCode';
    private final String DECISION_PARAM_ACCEPTED = 'Approved';
    private final String DECISION_PARAM_DECLINED = 'Rejected';
    private final String DECISION_PARAM_REVIEWED = 'Reviewed';
    
    // Landing page
    private final String LANDING_PAGE = '/apex/ApplicationDecision?_iframeDomain=https://fidemfinance.ca';
    
    // Regexes for validation
    private final String REGEX_PHONE_NUMBER = '^\\(?([0-9]{3})\\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$';
    private final String REGEX_EMAIL_ADDRESS = '^\\w+([\\.-]?\\w+)*@\\w+([\\.-]?\\w+)*(\\.\\w{2,3})+$';
    private final String REGEX_POSTAL_CODE = '^[abceghjklmnprstvxyABCEGHJKLMNPRSTVXY]{1}\\d{1}[a-zA-Z]{1} *\\d{1}[a-zA-Z]{1}\\d{1}$';
    //private final String REGEX_CURRENCY= '^([0-9]+)(\\.[0-9][0-9])?$'; // no commas
    private final String REGEX_STREET_ADDRESS = '^(\\d+)?\\s+(.*?)$';
        
    //Risk Based Pricing
    public List<SelectOption> homeOwnerOptions {get;set;}
    public String selHomeOwnerOptions {get;set;}
    
    //to avoid Incomplete Application
    private Boolean avoidIncompleteApplication;
    
    //Variables Added for preProcessing form
    public String FirstNamecust {get;set;}
    public String FirstName2 {get;set;}
    public String MailingStreet2 {get;set;}
    public String MailingProvince2 {get;set;}
    public String PrimaryphoneNumber2 {get;set;}
    public String MiddleName {get;set;}
    public String FirstName {get;set;}
    public String LastName {get;set;}
    public String LastNamecust {get;set;}
    public String LastName2 {get;set;}
    public String FirstNamepre {get;set;}
    public String LastNamepre {get;set;}
        
    //Variables Added for preProcessing form
    public String Uniqueid{ get; set; }
    public String Address{ get; set; }
    public String Addresspre{ get; set; }
    public String Email{ get; set; }
    public String Emailpre{ get; set; }
    
    public String BillingCountry {get;set;}
    public String BillingPostalCode  {get;set;}
    public String BillingCity  {get;set;}
    public String BillingState {get;set;}
    
    //Application Form 1st page.
    public Boolean HasAcceptedDisclosureTerms {get;set;}
    public String SIN{get;set;}
    public String EmailAddress {get;set;}
    
    //Application Form 2nd page.
    public String HomePhone {get;set;}
    public String CellPhone {get;set;}
    public String WorkPhone {get;set;}
    public String PermanentAddressStreetNumber {get;set;}
    public String PermanentAddressStreetName {get;set;}
    public String PermanentAddressPOBox {get;set;}
    public String PermanentAddressUnitNumber {get;set;}
    public String PermanentAddressCity {get;set;}
    public String PermanentAddressPostalCode {get;set;}
    public Integer YearsAtPermanentAddress {get;set;}
    public Integer MonthsAtPermanentAddress {get;set;}
    public Double HousingCosts {get;set;}
    public String MortgageWith {get;set;}
    public Double MonthlyExpenses {get;set;}
    public String PreviousAddressStreetNumber {get;set;}
    public String PreviousAddressStreetName {get;set;}
    public String PreviousAddressPoBox {get;set;}
    public String PreviousAddressUnitNumber {get;set;}
    public String PreviousAddressCity {get;set;}
    public String PreviousAddressPostalCode {get;set;}
    public Integer YearsAtPreviousAddress {get;set;}
    public Integer MonthsAtPreviousAddress {get;set;}
    
    //Application Form 3rd page
    //Application Form Employer Details.
    public String EmployerName {get;set;}
    public String EmployerPhone {get;set;}
    public String EmployerStreetNumber {get;set;}
    public String EmployerStreetName {get;set;}
    public String EmployerPoBox {get;set;}
    public String EmployerUnitNumber {get;set;}
    public String EmployerCity {get;set;}
    public String EmployerPostalCode {get;set;}
    public Decimal EmploymentYears {get;set;}
    public Decimal EmploymentMonths {get;set;}
    public Double GrossAnnualIncome {get;set;} 
    //Application Form Previous Employer Details
    public String PreviousEmployerName {get;set;}
    public String PreviousEmployerStreetNumber {get;set;}
    public String PreviousEmployerStreetName {get;set;}
    public String PreviousEmployerPoBox {get;set;}
    public String PreviousEmployerUnitNumber {get;set;}
    public String PreviousEmployerCity {get;set;}
    public String PreviousEmployerPostalCode {get;set;}
    public Decimal PreviousEmploymentYears {get;set;}
    public Decimal PreviousEmploymentMonths {get;set;}
    public Double PreviousGrossAnnualIncome {get;set;}
    public String NameofJurisdictions {get;set;}
    
    //Application Form 4th page
    public Boolean MarketingConsent{get;set;}
    public Boolean PaperlessStatement{get;set;}
    public Boolean PrivacyStatementAccepted{get;set;}
    public String PEFPWhoHeldPosition {get;set;}
    public String PEFPWhenHeld {get;set;}
    public String PEFPWhereHeld {get;set;}
    public String TPDWhoWillDirect {get;set;}
    public String TPDRelationshipToApplicant {get;set;}
    public String TaxIdentificationNumber {get;set;}
    public Boolean CanaccedeMarketingConsent {get;set;}
    public String CanadianSIN{get;set;}
    public String URLReferral{get;set;}
    
    public TPFidemApplicationFormController() {
        
        //to avoid adjudicated application to be in incomplete application name
        avoidIncompleteApplication = false;
                
        personAccRecType = [
            select Id from RecordType where IsPersonType = true and SObjectType = 'Account' and DeveloperName = 'Fidem_Customer'
        ];
        
        AppFormSettings = Application_Form_Settings__c.getOrgDefaults();
        afSettings = Application_Form_Configuration__c.getOrgDefaults();
        
        Application = new Application__c();
        //Application.Parent_Page_URL__c = URLReferral;
        listProductRecordType = [select Id, name from RecordType where SObjectType = 'Application__c' and DeveloperName like 'Fidem%'];
        
        // Set disclosure URLs
        CreditCardDisclosureURL = AppFormSettings.Credit_Card_Disclosure_URL__c;
        
        //Risk Based Pricing
        creditCardRentalDisclosureURL = AppFormSettings.Credit_Card_Rental_Disclosure_URL__c;
        
        // Page needs access to placeholder values
        PlaceholderFirstName = 'First Name';
        PlaceholderMiddleName = 'Middle Name';
        PlaceholderLastName = 'Last Name';
        PlaceholderBirthdateYear = 'YYYY';
        PlaceholderBirthdateMonth = 'MM';
        PlaceholderBirthdateDay = 'DD';
        
        wouldYouLikeToApplyOptions = getEligibleProductOptions2();
        
        // Build Salutation select list
        SalutationOptions = getSelectOptions(Contact.Salutation.getDescribe(), true, false);
        GenderOptions = getSelectOptions(Application__c.Gender__c.getDescribe(), false, true);
        
        // Build static Current BKCP select list
        CurrentBKCPOptions = getYesNoSelectOptionsBkcp();
        
        //Build trustee selectlist
        //TrusteeNameOptions = getTrusteeNames();
        
        // Build static Offer Code Available select list
        //OfferCodeAvailOptions = getYesNoSelectOptions();
        //SelOfferCodeAvail = NO_SEL_TEXT; // set default
        
        // Build static Authorized Credit Check select list
        AuthorizedCreditCheckOptions = getYesNoSelectOptions();
        
        //Build Primary Phone Number options select list
        primaryPhoneNumber = getPrimaryPhoneOptions();
        
        // Build Communications Preference select list
        CommunicationsPreferenceOptions = getSelectOptions(Application__c.Communications_Preference__c.getDescribe(), false, true);
        
        // Build How Heard About Us select list
        HowHeardAboutUsOptions = getSelectOptions(Application__c.How_Did_You_Hear_About_Us__c.getDescribe(), false, true);
        
        // Build Referral Id select list
        ReferralIdOptions = getSelectOptions(Application__c.Referral_ID__c.getDescribe(), false, true);
        
        // Build Number of Dependants select list
        NumberOfDependantsOptions = getSelectOptions(Application__c.Number_of_Dependants__c.getDescribe(), false, true);
        
        // Build Number of Dependants select list
        MaritalStatusOptions = getSelectOptions(Application__c.Marital_Status__c.getDescribe(), false, true);
        
        //Build Employment Status select list
        EmploymentStatusOptions = getSelectOptions(Application__c.Employment_Status__c.getDescribe(), false, true);
        
        // Build static Permanent Rent or Own select list
        PermanentRentOrOwnOptions = getPermanentRentOrOwnSelectOptions();
        
        //Risk Based Pricing
        //SelPermanentRentOrOwn = RENT_SEL_TEXT; // set default
        
        //Risk based pricing
        homeOwnerOptions = getYesNoSelectOptions();
        //selHomeOwnerOptions = NO_SEL_TEXT;
        
        // Build static Province select list
        ProvinceOptions = getProvinceSelectOptions();
        
        // Build static Permanent Province select list
        PermanentProvinceOptions = getProvinceSelectOptions();
        
        
        // Build static Previous Province select list
        //PreviousProvinceOptions = getProvinceSelectOptions();
        PreviousProvinceOptions = getProvinceSelectOptionsWithQC();
        
        // Build static Employer Province select list
        //EmployerProvinceOptions = getProvinceSelectOptions();
        EmployerProvinceOptions = getProvinceSelectOptionsWithQC();
        
        // Build static Previous Employer Province select list
        //PreviousEmployerProvinceOptions = getProvinceSelectOptions();
        PreviousEmployerProvinceOptions = getProvinceSelectOptionsWithQC();
        
        //build static FATCA select list
        FATCATsxObligationOptions = getYesNoSelectOptions();
        SelFATCATsxObligation = NO_SEL_TEXT; // set default
        
        // Build static Politically Exposed select list
        PoliticallyExposedForeignPersonOptions = getYesNoSelectOptions();
        SelPoliticallyExposedForeignPerson = NO_SEL_TEXT; // set default
        
        // Build static Third Party Direction select list
        ThirdPartyDirectionOptions = getYesNoSelectOptions();
        SelThirdPartyDirection = NO_SEL_TEXT; // set default
        
        // Build static Sole Applicant select list
        SoleApplicantOptions = getYesNoSelectOptions();
        SelSoleApplicant = YES_SEL_TEXT; // set default
        
        //To set PaperStatement as false
        PaperlessStatement = false;
        
        // Create Province to Age Of Majority Map
        provinceToAgeOfMajorityMap = new Map<String, Integer>();
        provinceToAgeOfMajorityMap.put('AB', 18);
        provinceToAgeOfMajorityMap.put('BC', 19);
        provinceToAgeOfMajorityMap.put('MB', 18);
        provinceToAgeOfMajorityMap.put('NB', 18);
        provinceToAgeOfMajorityMap.put('NL', 19);
        provinceToAgeOfMajorityMap.put('NT', 19);
        provinceToAgeOfMajorityMap.put('NS', 19);
        provinceToAgeOfMajorityMap.put('NU', 19);
        provinceToAgeOfMajorityMap.put('ON', 18);
        provinceToAgeOfMajorityMap.put('PE', 18);
        //provinceToAgeOfMajorityMap.put('Quebec', 18); TODO: No Quebec?
        provinceToAgeOfMajorityMap.put('SK', 18);
        provinceToAgeOfMajorityMap.put('YT', 19);
        
        
        // Initialize variables related to Person Record state
        PersonAlreadyLoaded = false; 
        PersonFoundViaQuery = false;
        PersonInserted = false;
        Showpopup = true;
        // logic for checking the showpopup render condition.
        String customerlocation = ApexPages.currentPage().getParameters().get('customerlocation');
        String firstnameparam= ApexPages.currentPage().getParameters().get('firstnameparam');
        String lastnameparam= ApexPages.currentPage().getParameters().get('lastnameparam');
        String emailparam = ApexPages.currentPage().getParameters().get('emailparam');
        String phoneparam = ApexPages.currentPage().getParameters().get('phoneparam');
        String dobparam = ApexPages.currentPage().getParameters().get('dobparam');
        String consentparam = ApexPages.currentPage().getParameters().get('consentparam');
        if(customerlocation=='Fidem'){
            Showpopup = false;
            FirstName = firstnameparam;
            LastName = lastnameparam;
            EmailAddress = emailparam;
            CellPhone = phoneparam;
            birthDateApplication = dobparam;
            CanaccedeMarketingConsent = Boolean.valueOf(consentparam);
              
            system.debug('firstnameparam :' + firstnameparam);
                
         }
         else{
             Showpopup = true;
         }
        
        System.debug('Checkshowpopup' +  Showpopup);
        
        // Load account, if id is passed
        List<Account> existingAccList = null;
        String accountId = ApexPages.currentPage().getParameters().get('id');
        if (accountId != null) {
            existingAccList = [
                Select Id, FirstName, Middle_Name__pc, LastName, SF_ID__c,
                Salutation,BillingCountry,BillingState,BillingCity,BillingPostalCode, PersonBirthdate, 
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
                from Account where Id = :accountId 
            ];
        }
        
        if (existingAccList != null && !existingAccList.isEmpty()) {
            PersonAccount = existingAccList[0];
            personAccSFID = PersonAccount.SF_ID__c;
            PersonAlreadyLoaded = true;
            
            /* logic Added for pre population of  pre processing fields */
            
            FirstNamecust = PersonAccount.FirstName;
            LastNamecust = PersonAccount.LastName;
            FirstName2 = PersonAccount.FirstName;
            lastname2 = PersonAccount.LastName;
            BillingCountry = PersonAccount.BillingCountry;
            BillingCountry = PersonAccount.BillingState;
            BillingCountry = PersonAccount.BillingCity;
            BillingCountry = PersonAccount.BillingPostalCode;
            MailingStreet2 = PersonAccount.PersonMailingStreet;
            PrimaryphoneNumber2 = PersonAccount.PersonMobilePhone;
            
            // Populate non-bound fields
            SelSalutation = PersonAccount.Salutation;
            FirstName = PersonAccount.FirstName;
            MiddleName = PersonAccount.Middle_Name__pc;
            LastName = PersonAccount.LastName;
            SelProvince = PersonAccount.PersonMailingState;
            
            if (PersonAccount.PersonBirthdate != null) {
                BirthdateYear = PersonAccount.PersonBirthdate.year();
                BirthdateMonth = PersonAccount.PersonBirthdate.month();
                BirthdateDay = PersonAccount.PersonBirthdate.day(); 
            }
            
            SelGender = PersonAccount.Gender__pc;
            SelMaritalStatus = PersonAccount.Marital_Status__pc;
            SelEmployerProvince = PersonAccount.Employer_Province__pc;
            SelNumberOfDependants = PersonAccount.Number_of_Dependants__pc;
            //SelPermanentRentOrOwn = PersonAccount.Home_Owner__pc;
            SelPermanentProvince = PersonAccount.PersonMailingState;
            
            // Other PersonAccount fields
            HomePhone = PersonAccount.PersonHomePhone;
            EmailAddress = PersonAccount.PersonEmail;
            SIN = PersonAccount.SIN__pc;
            CellPhone = PersonAccount.PersonMobilePhone;
            WorkPhone = PersonAccount.Work_Phone__pc;
            Application.Communications_Preference__c = PersonAccount.Communication_Preference__pc;
            HousingCosts = PersonAccount.Monthly_Home_Expense__pc;
            MonthlyExpenses = PersonAccount.Monthly_Expense__pc;
            //Application.Requested_Credit_Limit__c = Integer.valueOf(SelBorrowAmount);
            
            // PersonMailingStreet is a compound field (street # and name)
            if (PersonAccount.PersonMailingStreet != null) {
                Pattern streetPattern = Pattern.compile(REGEX_STREET_ADDRESS);
                Matcher streetMatcher = streetPattern.matcher(PersonAccount.PersonMailingStreet);
                
                if (streetMatcher.matches()) {
                    PermanentAddressStreetNumber = streetMatcher.group(1);
                    PermanentAddressStreetName = streetMatcher.group(2);
                } 
            }
            
            PermanentAddressCity = PersonAccount.PersonMailingCity;
            PermanentAddressPostalCode = PersonAccount.PersonMailingPostalCode;
            
            
            EmployerName = PersonAccount.Employer_Name__pc;
            EmployerPhone = PersonAccount.Employer_Phone__pc;
            EmployerStreetName = PersonAccount.Employer_Street_Name__pc;
            EmployerStreetNumber = PersonAccount.Employer_Street_Number__pc;
            EmployerCity = PersonAccount.Employer_City__pc;
            EmployerPostalCode = PersonAccount.Employer_Postal_Code__pc;
            Application.Occupation_Dropdown__c = PersonAccount.Occupation__pc;
            EmploymentYears = PersonAccount.Employment_Years__pc;
            EmploymentMonths = PersonAccount.Employment_Months__pc;
           // Application.Gross_Monthly_Income__c = PersonAccount.Gross_Monthly_Income__pc;
            
        } else {
            PersonAlreadyLoaded = false;
            PersonAccount = new Account(RecordTypeId = personAccRecType.Id);
        }
        
        /*
        //Third Party Trustee Code
        String urlTrusteeCode = ApexPages.currentPage().getParameters().get('trusteecode');
        
        System.debug('urlTrusteeCode :'+urlTrusteeCode);        
        
        if(!String.isBlank(urlTrusteeCode)){
            application.Trustee_Referral_Code__c = urlTrusteeCode;
            Fidem_Application_Referral__c referralCS = Fidem_Application_Referral__c.getInstance(urlTrusteeCode);
            
            System.debug('urlTrusteeCode :'+urlTrusteeCode);
            System.debug('application.Trustee_Referral_Code__c :'+application.Trustee_Referral_Code__c);
            System.debug('referralCS :'+referralCS);
            
            if(referralCS != null){
                String trusteeCompanyName = referralCS.Trustee_Company_Name__c;
                application.Trustee_Company_Name__c = trusteeCompanyName;
                
                System.debug('trusteeCompanyName :'+trusteeCompanyName);
                System.debug('referralCS.Trustee_Company_Name__c :'+referralCS.Trustee_Company_Name__c);
                
            }
        }
        */
    }
    
    public PageReference saveStepZero() {
        
        if(avoidIncompleteApplication == true){
            return urlForDecisionPage();
        }
        
        Boolean noValidationErrors = validateStepZero();
        
        // Return if any validation errors exist
        if (noValidationErrors == false) {
            return null;
        }
        
        //Risk Based Pricing
        Boolean HasAcceptedDisclosureTerm = false;
        
        //Manitoba Updates
        Application.Has_Accepted_Personal_Consent_Terms__c = false;
        
        //Fidem form Origination
        Application.Origination__c = Origination; 
        
        system.debug(Application.Loan_Type__c);
        
        return null;
    }
    
    public PageReference saveStepOne() {
        
        if(avoidIncompleteApplication == true){
            return urlForDecisionPage();
        }
        
        Boolean noValidationErrors = validateStepOne();
        
        // Return if any validation errors exist
        if (noValidationErrors == false) {
            return null;
        }
        
        // Query for existing customer, if not already loaded
        PersonFoundViaQuery = false;
        if (PersonAlreadyLoaded == false ) {
            
            //Exact Match           
            List<Account> exactMatchList = PotentialMatchUtil.getExactMatchList(Application);   
            if (!exactMatchList.isEmpty()){
                
                if(exactMatchList.size() > 1){
                    Application.Needs_Manual_Review__c = true;
                    Application.Manual_Review_Reason__c = PotentialMatchUtil.MANUAL_REVIEW_REASON_MULTIPLE_EXACT_MATCHES;
                }  
                
                //Assign the Application to latest Account
                PersonFoundViaQuery = true;
                PersonAccount.Id = exactMatchList[0].Id; 
                personAccSFID = exactMatchList[0].SF_ID__c;            
            } 
            else{
                //Uncertain Match
                List<Account> uncertainMatchList = PotentialMatchUtil.getUncertainMatchList(Application);
                
                if (!uncertainMatchList.isEmpty()){
                    Application.Needs_Manual_Review__c = true;
                    Application.Manual_Review_Reason__c = PotentialMatchUtil.MANUAL_REVIEW_REASON_MULTIPLE_UNCERTAIN_MATCHES;
                    
                    //Assign the Application to latest Account
                    PersonFoundViaQuery = true;
                    PersonAccount.Id = uncertainMatchList[0].Id; 
                    personAccSFID = uncertainMatchList[0].SF_ID__c; 
                }               
            } 
        }
        
        if(selHomeOwnerOptions == YES_SEL_TEXT){
            SelPermanentRentOrOwn = OWN_SEL_TEXT;
        }else if(selHomeOwnerOptions == NO_SEL_TEXT){
            SelPermanentRentOrOwn = RENT_SEL_TEXT;
        }
        
        //System.debug('PermanentRentOrOwnOptions__' +  PermanentRentOrOwnOptions);
        //System.debug('SelPermanentRentOrOwn__' +  SelPermanentRentOrOwn); 
        
        return null;        
    }
    
    public PageReference saveStepTwo() {
        
        if(avoidIncompleteApplication == true){
            return urlForDecisionPage();
        }
        
        
        //Third party card
        Decimal CC_HOME_OWNER_INTEREST_RATE = AppFormSettings.TP_Refer_HO_Interest_Rate__c; //29.99
        Decimal CC_RENTAL_INTEREST_RATE = AppFormSettings.TP_Refer_NHO_Interest_Rate__c; //34.99
        String CC_HOME_OWNER_INTEREST_RATE_CODE = AppFormSettings.TP_Refer_HO_Interest_Rate_Code__c; //2910
        String  CC_RENTAL_INTEREST_RATE_CODE = AppFormSettings.TP_Refer_NHO_Interest_Rate_Code__c; //3410
        
        if(!String.isBlank(selHomeOwnerOptions)){
            if(selHomeOwnerOptions == YES_SEL_TEXT){
                SelPermanentRentOrOwn = OWN_SEL_TEXT;           
            }
            else if(selHomeOwnerOptions == NO_SEL_TEXT){
                SelPermanentRentOrOwn = RENT_SEL_TEXT;
            }   
        } 
        
        // Validate variables, and if okay, bind any unbound variables to appropriate object fields
        Boolean noValidationErrors = validateStepTwo();
        
        // If no validation errors, and Person Account not already loaded upon initialization
        // and not found via query in Step One, and not already inserted (if re-doing Step Two) 
        
        Application.Primary_Phone_Number__c = selPrimaryPhoneNumber;
        
        // -- create Person Account based on input thus far
        if (noValidationErrors && PersonAlreadyLoaded == false && PersonFoundViaQuery == false && PersonInserted == false) {
            
            // Initialize record
            PersonAccount.Salutation = Application.Salutation__c;
            PersonAccount.FirstName = Application.First_Name__c;
            PersonAccount.Middle_Name__pc = Application.Middle_Name__c;
            PersonAccount.LastName = Application.Last_Name__c;
            PersonAccount.PersonBirthdate = Application.Birth_Date__c;
            PersonAccount.PersonMailingState = Application.Province__c;
            PersonAccount.PersonEmail = EmailAddress;
            PersonAccount.SIN__pc = SIN;
            PersonAccount.Gender__pc = Application.Gender__c;
            PersonAccount.PersonHomePhone = HomePhone;
            PersonAccount.PersonMobilePhone = CellPhone;
            PersonAccount.Work_Phone__pc = WorkPhone;
            PersonAccount.Communication_Preference__pc = Application.Communications_Preference__c;
            PersonAccount.Number_of_Dependants__pc = Application.Number_of_Dependants__c;
            PersonAccount.Marital_Status__pc = Application.Marital_Status__c;
            PersonAccount.Home_Owner__pc = Application.Home_Owner__c;
            PersonAccount.Monthly_Home_Expense__pc = HousingCosts;
            PersonAccount.Monthly_Expense__pc = MonthlyExpenses;
            PersonAccount.PersonMailingStreet = PermanentAddressStreetNumber + 
                ' ' + PermanentAddressStreetName;
            PersonAccount.PersonMailingCity = PermanentAddressCity;
            PersonAccount.PersonMailingState = Application.Permanent_Address_Province__c;
            PersonAccount.PersonMailingPostalCode = PermanentAddressPostalCode;
            
            insert PersonAccount;
            
            // We need to retrieve the SF_ID__c field, which we need to send to PowerCurve at a later step
            Account temp = [select SF_ID__c from Account where Id =: PersonAccount.Id];
            personAccSFID = temp.SF_ID__c;
            PersonInserted = true;     
        }
        
        // Set Internal or External
        Application.Application_Completed_From__c = Utilities.getInternalOrExternal();
        
        // Link Application to Person Account
        Application.Customer__c = PersonAccount.Id;
        Application.Name = 'Incomplete';          
        
        //home owner and non home owner related interest rate and interest rate code values
        if(SelPermanentRentOrOwn == OWN_SEL_TEXT){
            Application.Disclosure_Statement_Presented__c = CC_HOME_OWNER_DISCLOSURE_STMT;
            Application.Interest_Rate__c = CC_HOME_OWNER_INTEREST_RATE;
            Application.Interest_Rate_Code__c = CC_HOME_OWNER_INTEREST_RATE_CODE;
            
        }
        else{
            Application.Disclosure_Statement_Presented__c = CC_RENTAL_DISCLOSURE_STMT;
            Application.Interest_Rate__c = CC_RENTAL_INTEREST_RATE;
            Application.Interest_Rate_Code__c = CC_RENTAL_INTEREST_RATE_CODE;
        }
        
        //Set record type value for application
        for(RecordType recordTypeValue : listProductRecordType){
            if((recordTypeValue.name).contains('Card')){
                system.debug('Map value : ' + recordTypeValue.id);
                system.debug('Map value : ' + application.recordTypeid);
                application.recordTypeid = recordTypeValue.id;
            }
        }
        
        if(null != SIN){
            Application.SIN__c = SIN.trim();
        }
        Application.Email_Address__c = EmailAddress;
        Application.Has_Accepted_Disclosure_Terms__c = HasAcceptedDisclosureTerms;
        
        if(null != HomePhone){
            Application.Home_Phone__c = HomePhone.trim();
        }
        if(null != CellPhone){
            Application.Cell_Phone__c  = CellPhone.trim(); 
        }
        if(null != WorkPhone){
            Application.Work_Phone__c = WorkPhone.trim(); 
        }
        
        if(null != PermanentAddressStreetNumber){
            Application.Permanent_Address_Street_Number__c = PermanentAddressStreetNumber.trim();
        }
        Application.Permanent_Address_Street_Name__c = PermanentAddressStreetName;
        Application.Permanent_Address_PO_Box__c = PermanentAddressPOBox;
        if(null != PermanentAddressUnitNumber){
            Application.Permanent_Address_Unit_Number__c = PermanentAddressUnitNumber.trim();
        }
        Application.Permanent_Address_City__c = PermanentAddressCity;
        Application.Permanent_Address_PostalCode__c = PermanentAddressPostalCode;
        Application.Years_At_Permanent_Address__c = YearsAtPermanentAddress;
        Application.Months_At_Permanent_Address__c = MonthsAtPermanentAddress;
        Application.Housing_Costs__c = HousingCosts;
        Application.Mortgage_With__c = MortgageWith;
        Application.Monthly_Expenses__c = MonthlyExpenses;
        
        if(PreviousAddressStreetNumber != null){
            
            if(null != PreviousAddressStreetNumber){
                Application.Previous_Address_Street_Number__c = PreviousAddressStreetNumber.trim();
            }
            Application.Previous_Address_Street_Name__c = PreviousAddressStreetName;
            Application.Previous_Address_PO_Box__c = PreviousAddressPoBox;
            Application.Previous_Address_Unit_Number__c = PreviousAddressUnitNumber;
            Application.Previous_Address_City__c = PreviousAddressCity;
            Application.Previous_Address_PostalCode__c = PreviousAddressPostalCode;
            Application.Years_At_Previous_Address__c = YearsAtPreviousAddress;
            Application.Months_At_Previous_Address__c = MonthsAtPreviousAddress;
            
        }
        
        /*
        Application.Parent_Page_URL__c = URLReferral;
        system.debug('URLReferral in step 2: '+URLReferral);
        */
        
        //Third party trustee product
        Application.Campaign_Code__c = 'TrusteeProduct';
        
        ApplicationTriggerHandler.runApplicationLoadTrigger = false;
        
        upsert Application;
        
        ApplicationTriggerHandler.runApplicationLoadTrigger = true;
        
        mapDependentPicklist = getDependentPicklistValues(Application__c.Job_Description__c);
        
        return null;
    }
    
    public PageReference saveStepThree() {
        
        if(avoidIncompleteApplication == true){
            return urlForDecisionPage();
        }
        
        // Validate variables, and if okay, bind any unbound variables to appropriate object fields
        Boolean noValidationErrors = validateStepThree();
        
        //calculate monthly income
        
        if(GrossAnnualIncome != null){
            Application.Gross_Monthly_Income__c = GrossAnnualIncome / 12;
        }
        if(PreviousGrossAnnualIncome != null){
            Application.Previous_Gross_Monthly_Income__c = PreviousGrossAnnualIncome / 12;
        }       
    
        
        Application.Employer_Name__c = EmployerName;
        if(null != EmployerPhone){
            Application.Employer_Phone__c = EmployerPhone.trim();
        }
        if(null != EmployerStreetNumber){
            Application.Employer_Street_Number__c = EmployerStreetNumber.trim();
        }
        Application.Employer_Street_Name__c = EmployerStreetName;
        Application.Employer_PO_Box__c = EmployerPoBox;
        if(null != EmployerUnitNumber){
            Application.Employer_Unit_Number__c = EmployerUnitNumber.trim();
        }
        Application.Employer_City__c = EmployerCity;
        Application.Employer_PostalCode__c = EmployerPostalCode;
        Application.Employment_Years__c = EmploymentYears;
        Application.Employment_Months__c = EmploymentMonths;
        Application.Gross_Annual_Income__c = GrossAnnualIncome;
   
        
        if(PreviousEmployerName != null){
        
            Application.Previous_Employer_Name__c = PreviousEmployerName;
            if(null != PreviousEmployerStreetNumber){
                Application.Previous_Employer_Street_Number__c = PreviousEmployerStreetNumber.trim(); 
            }
            Application.Previous_Employer_Street_Name__c = PreviousEmployerStreetName;
            Application.Previous_Employer_PO_Box__c = PreviousEmployerPoBox;
            if(null != PreviousEmployerUnitNumber){
                Application.Previous_Employer_Unit_Number__c = PreviousEmployerUnitNumber.trim();
            }
            Application.Previous_Employer_City__c = PreviousEmployerCity;
            Application.Previous_Employer_PostalCode__c = PreviousEmployerPostalCode;
            Application.Previous_Employment_Years__c = PreviousEmploymentYears;
            Application.Previous_Employment_Months__c = PreviousEmploymentMonths;
            Application.Previous_Gross_Annual_Income__c = PreviousGrossAnnualIncome;
            
        }
        
        
        ApplicationTriggerHandler.runApplicationLoadTrigger = false;
        
        try{
            update application;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Techincal issue : please try to cheeck if data is correct'));
            noValidationErrors = false; 
        }
        
        ApplicationTriggerHandler.runApplicationLoadTrigger = true;
        
        return null;
    }
    
    public PageReference saveStepFour() {
        // Validate variables, and if okay, bind any unbound variables to appropriate
        //   object fields
        System.debug('CheckGroosmonthlyIncome ' + Application.Gross_Monthly_Income__c);   
        if(avoidIncompleteApplication == true){
            return urlForDecisionPage();
        }
        
        Boolean noValidationErrors = validateStepZero() && validateStepOne() && validateStepTwo() && validateStepThree();
        
        // Consumer Legal Consent
        if (isConsumerLegalConsent == true) {
            Application.Consumer_Legal_Consent__c = TRUE_TEXT;
            Application.Consumer_Legal_Consent_Date__c = system.Today();
        } 
        else {
            /*
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_HOW_CONSUMER_LEGAL_CONSENT));
            noValidationErrors = false;
            */
            Application.Consumer_Legal_Consent__c = FALSE_TEXT;
        }
        
        //Privacy policy validation
        if (PrivacyStatementAccepted == true) {
            
            Application.Privacy_Statement_Accepted_Date__c = system.now();
        } 
        else {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please accept the privacy policy'));
            noValidationErrors = false;
        }
        
        //FATCA fields
        if (String.isNotBlank(SelFATCATsxObligation) && 
            validateSelectValue(getYesNoSelectOptions(), SelFATCATsxObligation) &&  
            SelFATCATsxObligation == YES_SEL_TEXT && String.isNotBlank(NameofJurisdictions) &&
            String.isNotBlank(TaxIdentificationNumber) && null != CanadianSIN
            ) {
            system.debug('Canadian SIN length = ' + (''+CanadianSIN).length());
            if(SIN.isNumeric() == false && (''+CanadianSIN).length() != 9 ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter valid SIN'));
                noValidationErrors = false;
            }else{
                Application.Tax_Obligation_in_other_Countries__c = SelFATCATsxObligation == YES_SEL_TEXT ? true : false;  
            }
        }
        else if(SelFATCATsxObligation == YES_SEL_TEXT && (String.isBlank(NameofJurisdictions) || 
            String.isBlank(TaxIdentificationNumber) || null == CanadianSIN)){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill in all FATCA fields as they are mandatory'));
            noValidationErrors = false; 
        }
        
        // Politically Exposed Foreign Person
        system.debug('intialval' +  PEFPWhoHeldPosition);
        system.debug('intialval01' +  PEFPWhenHeld);
        system.debug('intialval02' +  PEFPWhereHeld);
        
        if (String.isNotBlank(SelPoliticallyExposedForeignPerson) && 
            validateSelectValue(getYesNoSelectOptions(), SelPoliticallyExposedForeignPerson) &&  
            SelPoliticallyExposedForeignPerson==YES_SEL_TEXT && String.isNotBlank(PEFPWhoHeldPosition) &&
            String.isNotBlank(PEFPWhenHeld) && String.isNotBlank(PEFPWhereHeld)) {
                
                Application.Politically_Exposed_Foreign_Person__c = SelPoliticallyExposedForeignPerson == YES_SEL_TEXT ? true : false;  
            }
            else if(SelPoliticallyExposedForeignPerson==YES_SEL_TEXT && (String.isBlank(PEFPWhoHeldPosition) || String.isBlank(PEFPWhenHeld) || String.isBlank(PEFPWhereHeld))){
                system.debug('Checkprateek' + PEFPWhoHeldPosition);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Fill in all Position held Fields as they are mandatory'));
                noValidationErrors = false; 
            }
                        
        // Sole Applicant for Card
        if (String.isNotBlank(SelSoleApplicant) && 
            validateSelectValue(getYesNoSelectOptions(), SelSoleApplicant)) {
                
            Application.Is_Sole_Applicant_for_Card__c = SelSoleApplicant == YES_SEL_TEXT ? true : false;
                
        }else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_SOLE_APPLICANT_CHECK));
            noValidationErrors = false;
        }
        
        // Return if validation errors
        if (noValidationErrors == false) {
            return null;
        }
        
        Application.Marketing_Consent__c = MarketingConsent;
        Application.Paperless_Statement__c = PaperlessStatement;
        Application.Privacy_Statement_Accepted__c =PrivacyStatementAccepted;
        Application.Name_of_Jurisdictions__c = NameofJurisdictions;
        Application.Tax_Identification_Number__c = TaxIdentificationNumber;
        Application.Canadian_SIN__c = CanadianSIN;
        Application.PEFP_Who_Held_Position__c = PEFPWhoHeldPosition;
        Application.PEFP_When_Held__c = PEFPWhenHeld;
        Application.PEFP_Where_Held__c = PEFPWhereHeld;
        Application.TPD_Who_Will_Direct__c = TPDWhoWillDirect;
        Application.TPD_Relationship_To_Applicant__c = TPDRelationshipToApplicant;
        
        
        // Added By A5E Consulting PVT LTD
        // Appilcation Workflow and Data Sync         
        Utilities.updateFixedApplicationData(application);
        
        /*
        //Third Party Trustee Code
        String urlTrusteeCode = ApexPages.currentPage().getParameters().get('trusteecode');
        
        System.debug('URLReferral :'+URLReferral);
        System.debug('urlTrusteeCode :'+urlTrusteeCode);        
        
        if(!String.isBlank(urlTrusteeCode)){
            application.Trustee_Referral_Code__c = urlTrusteeCode;
            Fidem_Application_Referral__c referralCS = Fidem_Application_Referral__c.getInstance(urlTrusteeCode);
            
            System.debug('urlTrusteeCode :'+urlTrusteeCode);
            System.debug('application.Trustee_Referral_Code__c :'+application.Trustee_Referral_Code__c);
            System.debug('referralCS :'+referralCS);
            
            if(referralCS != null){
                String trusteeCompanyName = referralCS.Trustee_Company_Name__c;
                application.Trustee_Company_Name__c = trusteeCompanyName;
                
                System.debug('trusteeCompanyName :'+trusteeCompanyName);
                System.debug('referralCS.Trustee_Company_Name__c :'+referralCS.Trustee_Company_Name__c);
                
            }
        }
        */
        
        PageReference p = new PageReference(LANDING_PAGE);
        Map<String, String> params = p.getParameters();
        
        avoidIncompleteApplication = true;  
        
        DecisionWSUtil.IntegrationResponse intResponse = new DecisionWSUtil.IntegrationResponse();
        Boolean flagSIN = false;
        
        //Employment length check
        Boolean flagEmployment = false;        
        
        try{
            //submit to adjudication engine
            //if((Application.SIN__c).startsWith('9'))
            if(null != application.SIN__c && (application.SIN__c).startsWith('9')){
                flagSIN = true;
            } 
            
            //Employment length check
            if(DecisionWS.getGreaterOfEmpLength(Application) < (AppFormSettings.Minimum_Employment_Length__c + 1)){
                flagEmployment = true;
            }
            
            if(Application.CurrentBKCP__c != 'None' && flagSIN == false && flagEmployment == false){
                intResponse = DecisionWS.submit(application, afSettings);
                
                Application.Webservice_Request__c = intResponse.request;
                Application.Webservice_Response__c = intResponse.response;
                Application.Adjudication_Response__c = intResponse.adjudicationResponse;
                Application.AML_Response__c = intResponse.amlResponse;
                
                system.debug('Attachment data' + intResponse.adjudicationFile);
                //Attach the adjudication and AML response to application
                if(String.isNotBlank(intResponse.adjudicationFile)){
                    
                    Attachment adjudicationAttach = new Attachment();
                    adjudicationAttach.Body = Blob.valueOf(intResponse.adjudicationFile);
                    adjudicationAttach.Name = 'Adjudication - Response.txt';
                    adjudicationAttach.ParentId = Application.ID;
                    insert adjudicationAttach;
                }
            }
        }
        catch(Exception e){
            //Application.Name = APP_NAME_INCOMPLETE_POWER_CURVE_ERR;
            Application.Application_Status_Last_Changed_Date__c = system.now();
            Application.Application_Status__c = 'Needs Review';
            Application.CSR_Manual_Review_Reason__c = 'System Exception';
            
            try{
                API_Error__c apiError = new API_Error__c(
                    Application__c = application.Id, End_Point__c = 'A', Action__c = 'Application update failed'
                );
                apiError.error__c = e.getMessage();
            
                insert apiError;
            }
            catch(Exception expApi){
                System.debug('Exception creating API Error record');
            }   
        }
        
        //Set all time stamps
        Application.Application_Status_Last_Changed_Date__c = system.now();
        Application.Decision_Timestamp__c = system.now();
        Application.Adjudication_Decision_Last_Changed_Date__c = system.now();
        Application.AML_Decision_Last_Changed_Date__c = system.now();
        Application.AML_Decision_Timestamp__c = System.now();
        
        //Fetch auto number field to populate on the records
        String ApplicationAutoNumberValue = [SELECT id, Fidem_Application_Number__c from Application__c where id =: application.id].Fidem_Application_Number__c;
        Application.Name = ApplicationAutoNumberValue;
        
        System.debug('intResponse  : '+ intResponse );
        //if current BKCP value is selected as None
        if(Application.CurrentBKCP__c == 'None'){
            
            //Application.Application_Status_Last_Changed_Date__c = system.now();
            Application.Application_Status__c = 'System Declined';
            Application.Decision_Summary__c = 'User is not currently or have not been in a bankruptcy or consumer proposal process within the last 7 years';
        }
        else if(flagSIN == true){
            //Application.Application_Status_Last_Changed_Date__c = system.now();
            Application.Application_Status__c = 'System Declined';
            Application.Decision_Summary__c = 'User is not permanent resident of Canada';
        }
        //Employment length failed
        else if(flagEmployment == true){
            Application.Application_Status__c = 'System Declined';
            Application.Decision_Summary__c = 'Current and Previous Employment Length Failed';
        }
        else if (null == intResponse || String.isBlank(Application.Webservice_Response__c)) {
            // due to exception returned null
            
            //Application.Application_Status_Last_Changed_Date__c = system.now();
            Application.Application_Status__c = 'Needs Review';
            Application.CSR_Manual_Review_Reason__c = 'System Not Reachable – Adjudication';
            Application.Decision__c = 'Needs Review';
            //Application.Decision_Timestamp__c = system.now();
            //Application.Adjudication_Decision_Last_Changed_Date__c = system.now();
        } 
        else {
            // Set decision-related fields on Application
            //Adjudication
            Application.Decision__c = intResponse.adjudicationStatus;
            Application.Decline_Reason__c = intResponse.declineReason;
            
            Application.Credit_Score__c = null==intResponse.creditScore?'':(''+intResponse.creditScore);
            Application.Bankruptcies__c = intResponse.totalNumberofBankrupcies;
            Application.Decision_Summary__c = intResponse.decisionSummary;
            Application.Lender_Approved_Amount__c = intResponse.approvedAmount;
            
            //Application.Interest_Rate__c = fidemAppRef.Interest_Rate__C;
            
            //AML
            Application.AML_Decision__c = intResponse.amlStatus;
           
            Application.Fraud_Flag__c = null;
            if(intResponse.fraudFlag == 'N'){
                Application.Fraud_Flag__c = 'No';
            }
            else if(intResponse.fraudFlag == 'Y'){
                Application.Fraud_Flag__c = 'Yes';
            }
            Application.AML_Decision_Summary__c = intResponse.amlSummary;
            Application.AML_Declined_Reason__c = intResponse.amlDeclineReason;
            Application.Unique_ID_AML__c = intResponse.amlUniqueNumber;
            
            Application.CSR_Manual_Review_Reason__c = intResponse.needsReviewReason;
            
            //Calculate application status
            if(Application.Decision__c == 'Approved' && Application.AML_Decision__c == 'Approved'){
                Application.Application_Status__c = 'System Approved';
                
            }
            else if(Application.Decision__c == 'Needs Review' || Application.AML_Decision__c == 'Needs Review'){
                Application.Application_Status__c = 'Needs Review';
                
            }
            else if(Application.Decision__c == 'Declined' || Application.AML_Decision__c == 'Declined'){
                Application.Application_Status__c = 'System Declined';
                
            }else if(Application.Decision__c == 'Approved' && String.isBlank(Application.AML_Decision__c)){
                Application.Application_Status__c = 'Needs Review';
                
            }
        }
        
        //Calculate DSR Score
        Application.DSR_Score__c = ((HousingCosts + MonthlyExpenses) / Application.Gross_Monthly_Income__c)*100;
        Application.DSR_Timestamp__c = system.now();
        
        //Send verification email to customer if status is approved
        if(Application.Application_Status__c == 'System Approved'){
            Datetime current = Datetime.now();
            String hashString = application.Id + current.formatGmt('yyyyMMddHHmmssSSS');
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));            
            application.Verification_Auth_Token__c = EncodingUtil.convertToHex(hash);
               
            // Update verification status          
            application.Verification_Sent_Date__c = current;
            application.Verification_Status__c = VERIFICATION_STATUS_EMAIL_SENT_SYSTEM;  
            
            // Calculate expiration date
            Integer expiryDays = Integer.valueOf(appFormSettings.Verification_Expiration_Days__c);
            application.Verification_Expiration_Date__c = current.addDays(expiryDays);
         
        }
        
        Application.Application_Completed_Submitted__c = true;    
        
        // Update Application
        if (MarketingConsent == true) {
            Application.Marketing_Consent_Date__c = Date.today();
        }       
        
        application.Parent_Page_URL__c = URLReferral;
                
        String urlTrusteeCode = ApexPages.currentPage().getParameters().get('trusteecode');
        
        System.debug('URLReferral :'+URLReferral);
        System.debug('urlTrusteeCode :'+urlTrusteeCode);        
        
        if(!String.isBlank(urlTrusteeCode)){
            application.Trustee_Referral_Code__c = urlTrusteeCode;
            Fidem_Application_Referral__c referralCS = Fidem_Application_Referral__c.getInstance(urlTrusteeCode);
            
            System.debug('urlTrusteeCode :'+urlTrusteeCode);
            System.debug('application.Trustee_Referral_Code__c :'+application.Trustee_Referral_Code__c);
            System.debug('referralCS :'+referralCS);
            
            if(referralCS != null){
                String trusteeCompanyName = referralCS.Trustee_Company_Name__c;
                application.Trustee_Company_Name__c = trusteeCompanyName;
                
                System.debug('trusteeCompanyName :'+trusteeCompanyName);
                System.debug('referralCS.Trustee_Company_Name__c :'+referralCS.Trustee_Company_Name__c);
                
            }
        }
                    
        ApplicationTriggerHandler.runApplicationLoadTrigger = false;    
        try{
            update application;           
        }
        catch(Exception e){
            try{
                API_Error__c apiError = new API_Error__c(
                        Application__c = application.Id, End_Point__c = 'A', Action__c = 'Application update failed'
                );
                apiError.error__c = e.getMessage();
            
                insert apiError;
            }
            catch(Exception expApi){
                System.debug('Exception creating API Error record');
            }                
        }
        
        ApplicationTriggerHandler.runApplicationLoadTrigger = true;
        
        params.put('id', Application.Id);
        params.put('Decision', Application.Application_Status__c);
        params.put('FirstName', FirstName);
        params.put('LastName', LastName);
        p.setRedirect(true);        
        
        return p;
    }
    
    private Boolean validateStepZero() {
        Boolean noValidationErrors = true;
        
        if (String.isNotBlank(wouldYouLikeToApply) && validateSelectValue(wouldYouLikeToApplyOptions, wouldYouLikeToApply) && wouldYouLikeToApply == 'Yes') {
            Application.Loan_Type__c = CREDIT_CARD;             
        } 
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Yes to proceed'));
            noValidationErrors = false;
        }
        
        //Risk Based Pricing
        if((String.isNotBlank(SelLoanType)) && (SelLoanType == CREDIT_CARD)){
            if(String.isBlank(selHomeOwnerOptions)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_HOME_OWNER));
                noValidationErrors = false;
            }
        }
        
        // Province
        if (String.isNotBlank(SelProvince) && validateSelectValue(getProvinceSelectOptions(), SelProvince)) {
            Application.Province__c = SelProvince;              
        } 
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PROVINCE));
            noValidationErrors = false; 
        }
        
        return noValidationErrors;
    }
    
    private Boolean validateStepOne() {
        // For bound fields, only validate that a value is provided (if required)
        // For unbound fields, enforce field-specific constraints and then assign to appropriate object fields
        
        Boolean noValidationErrors = true;
        
        // Validate fields, and assign them  to appropriate object fields if unbound
        
        // Has Accepted Disclosure Terms
        if (HasAcceptedDisclosureTerms != true) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_HAS_ACCEPTED_DISCLOSURE_TERMS));
            noValidationErrors = false;
        }
        
        // Salutation
        if (String.isNotBlank(SelSalutation) && validateSelectValue(Contact.Salutation.getDescribe(), SelSalutation)) {
            Application.Salutation__c = SelSalutation;              
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_SALUTATION));
            noValidationErrors = false; 
        }
        
        // First Name
        if (String.isNotBlank(FirstName)) {
            Application.First_Name__c = FirstName.trim();
        }         
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_FIRST_NAME));
            noValidationErrors = false;     
        }
        
        // Middle Name (not required, just assign it if it's not blank)
        if (String.isNotBlank(MiddleName)) {
            Application.Middle_Name__c = MiddleName.trim();
        } 
        
        // Last Name
        if (String.isNotBlank(LastName)) {
            Application.Last_Name__c = LastName.trim();
        } 
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_LAST_NAME));
            noValidationErrors = false;     
        }
        
        if(null != birthDateApplication ){
            try {
                List<String> birthdateList = birthDateApplication.split('-');
                Application.Birth_Date__c = Date.newInstance(Integer.valueof(birthdateList[2]), Integer.valueof(birthdateList[0]), Integer.valueof(birthdateList[1]));
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_BIRTH_DATE));
                noValidationErrors = false; 
            }
        } 
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_BIRTH_DATE));
            noValidationErrors = false; 
        }
            
        if(String.isBlank(birthDateApplication)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_BIRTH_DATE));
            noValidationErrors = false;
        }
        
        //Insolvency Date
        if(SelCurrentBKCP == 'Bankruptcy' || SelCurrentBKCP == 'Consumer Proposal'){
            if(insolvencyDateApplication!=null){
                    try{            
                    List<String> insolvencyDateList = insolvencyDateApplication.split('-');
                    if(insolvencyDateList.size() > 0){
                        Date insolvDate = Date.newInstance(Integer.valueof(insolvencyDateList[2]), Integer.valueof(insolvencyDateList[0]), Integer.valueof(insolvencyDateList[1]));
                        if(insolvDate <= Date.today()){
                        Application.Insolvency_Date__c = insolvDate;
                        }else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insolvency Date cannot be in Future'));
                        noValidationErrors = false;
                        }            
                    }
                   }catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_INSOLVENCY_DATE));
                    noValidationErrors = false; 
                   } 
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_INSOLVENCY_DATE));
                noValidationErrors = false;
            }
       }     
        
        //Trustee Company Name          
        /*
        if(SelCurrentBKCP == 'Bankruptcy' || SelCurrentBKCP == 'Consumer Proposal'){
            if(SelTrusteeName!='Other') {
                    Application.Trustee_Company_Name__c = SelTrusteeName;             
            } else{
                    if(String.isNotBlank(otherTrusteeName)){
                        Application.Trustee_Company_Name__c = otherTrusteeName; 
                    }else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Other field must contain a value'));
                        noValidationErrors = false; 
                    }     
            }
        }
        */
        
        // SIN (optional)
        //   if entered, validate that it is all numbers
        if (String.isNotBlank(SIN) && 
            (SIN.isNumeric() == false || SIN.length() != 9)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_SIN));
                noValidationErrors = false; 
            }
        
        
        // Email Address (required)
        Pattern emailPattern = Pattern.compile(REGEX_EMAIL_ADDRESS);
        if (String.isNotBlank(EmailAddress) &&
            emailPattern.matcher(EmailAddress).matches() == false) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_EMAIL_ADDRESS));
                noValidationErrors = false;     
            }
        
        // Employment status (required)
        Application.Employment_Status__c = SelEmploymentStatus;
        if (String.isBlank(Application.Employment_Status__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_EMPLOYMENT_STATUS));
            noValidationErrors = false;     
        } 
        else if (Application.Employment_Status__c == 'Unemployed' || Application.Employment_Status__c == 'Student') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_EMPLOYMENT_STATUS_UNQUALIFIED));
            noValidationErrors = false;     
        }
        
        // Current Bankruptcy
        if (String.isNotBlank(SelCurrentBKCP) && validateSelectValue(getYesNoSelectOptionsBkcp(), SelCurrentBKCP)) {
            system.debug('CheckSelvalue' + SelCurrentBKCP);
            if (SelCurrentBKCP == 'Bankruptcy') {
                Application.CurrentBKCP__c = 'BK'; 
            } 
            else if(SelCurrentBKCP == 'Consumer Proposal'){
                Application.CurrentBKCP__c = 'CP';
            }
            else if(SelCurrentBKCP == 'None'){
                Application.CurrentBKCP__c = 'None';
                
            }
        } 
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_CURRENT_BKCP));
            noValidationErrors = false;
        }
        
        
        
        // Authorized credit check
        if (String.isNotBlank(SelAuthorizedCreditCheck) && SelAuthorizedCreditCheck == YES_SEL_TEXT) {
            Application.Authorized_Credit_Check__c = true;
        } 
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_AUTHORIZED_CREDIT_CHECK));
            noValidationErrors = false;
        }
        
        // Validate Province + Age
        if (Application.Birth_Date__c != null && Application.Province__c != null) {
            Integer ageOfMajority = provinceToAgeOfMajorityMap.get(Application.Province__c);
            Date thresholdDate = Application.Birth_Date__c.addYears(ageOfMajority);
            
            if (Date.today() < thresholdDate) {
                // Return error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_AGE_OF_MAJORITY));
                novalidationErrors = false;
            }           
        }
        
        return noValidationErrors;
    }
    
    private Boolean validateStepTwo() {
                
        Boolean noValidationErrors = true;
        // Gender
        if (String.isNotBlank(SelGender) && validateSelectValue(Application__c.Gender__c.getDescribe(), SelGender)) {
            Application.Gender__c = SelGender;              
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_GENDER));
            noValidationErrors = false;             
        }
        
        Pattern phonePattern = Pattern.compile(REGEX_PHONE_NUMBER);
        
        // Home Phone
        if ((selPrimaryPhoneNumber == 'Home Phone' && String.isBlank(HomePhone)) || (String.isnotBlank(HomePhone) && phonePattern.matcher(HomePhone).matches() == false)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_HOME_PHONE));
            noValidationErrors = false;   
        }
        
        // Cell Number (not required)
        if ((selPrimaryPhoneNumber == 'Mobile Phone' && String.isBlank(CellPhone)) || (String.isnotBlank(CellPhone) && phonePattern.matcher(CellPhone).matches() == false)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_CELL_PHONE));
            noValidationErrors = false;       
        }
        
        // Work Phone
        if ((selPrimaryPhoneNumber == 'Work Phone' && String.isBlank(WorkPhone)) || (String.isnotBlank(WorkPhone) && phonePattern.matcher(WorkPhone).matches() == false)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_WORK_PHONE));
            noValidationErrors = false; 
        }
        
        // Communications Preference (not required)
        if (String.isNotBlank(SelCommunicationsPreference)) {
            if (validateSelectValue(Application__c.Communications_Preference__c.getDescribe(), SelCommunicationsPreference)) {
                Application.Communications_Preference__c = SelCommunicationsPreference; 
            } 
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_COMMUNICATIONS_PREFERENCE));
                noValidationErrors = false;  
                
            }
        }  
        
        // How did you hear about us (not required)
        if (String.isNotBlank(SelHowHeardAboutUs)) { 
            if (validateSelectValue(Application__c.How_Did_You_Hear_About_Us__c.getDescribe(), SelHowHeardAboutUs)) {
                Application.How_Did_You_Hear_About_Us__c = SelHowHeardAboutUs;
            } 
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_HOW_HEARD_ABOUT_US));
                noValidationErrors = false;
            }
        } 
                
        // Number of Dependants
        if (String.isNotBlank(SelNumberOfDependants) && 
            validateSelectValue(Application__c.Number_of_Dependants__c.getDescribe(), SelNumberOfDependants)) {
                Application.Number_of_Dependants__c = SelNumberOfDependants;                
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_NUMBER_OF_DEPENDANTS));
                noValidationErrors = false;
            }
        
        // Marital Status
        if (String.isNotBlank(SelMaritalStatus) && 
            validateSelectValue(Application__c.Marital_Status__c.getDescribe(), SelMaritalStatus)) {
                Application.Marital_Status__c = SelMaritalStatus;               
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_MARITAL_STATUS));
                noValidationErrors = false; 
            }
        
        // Permanent Address Street Number
        if (String.isBlank(PermanentAddressStreetNumber)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PERMANENT_ADDRESS_STREET_NUMBER));
            noValidationErrors = false;  
        }
        
        // Permanent Address Street Name
        if (String.isBlank(PermanentAddressStreetName)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PERMANENT_ADDRESS_STREET_NAME));
            noValidationErrors = false; 
        }
        
        // Permanent Address City
        if (String.isBlank(PermanentAddressCity)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PERMANENT_ADDRESS_CITY));
            noValidationErrors = false; 
        }
        
        // Permanent Address Province
        if (String.isNotBlank(SelPermanentProvince) && 
            validateSelectValue(getProvinceSelectOptions(), SelPermanentProvince)) {
                Application.Permanent_Address_Province__c = SelPermanentProvince;               
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PERMANENT_ADDRESS_PROVINCE));
                noValidationErrors = false; 
            }
        
        Pattern postalCodePattern = Pattern.compile(REGEX_POSTAL_CODE);
        
        // Permanent Address Postal Code
        if (String.isBlank(PermanentAddressPostalCode) || 
            postalCodePattern.matcher(PermanentAddressPostalCode).matches() == false) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PERMANENT_ADDRESS_POSTAL_CODE));
                noValidationErrors = false; 
            }
        
        Boolean validatePreviousAddress = false;
        
        // Years and Months at Permanent Address
        
        if ((YearsAtPermanentAddress == 0 && MonthsAtPermanentAddress == 0) || 
            YearsAtPermanentAddress == null || MonthsAtPermanentAddress == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_HOW_LONG));
                noValidationErrors = false;      
            } else if (YearsAtPermanentAddress < 2) {
                validatePreviousAddress = true;
            }
        
        // Permanent Rent or Own
        system.debug('Checkoooo22o' + selHomeOwnerOptions + 'checkii0'+ SelPermanentRentOrOwn);
        if (String.isNotBlank(SelPermanentRentOrOwn) && validateSelectValue(getPermanentRentOrOwnSelectOptions(), SelPermanentRentOrOwn)) {
                if(String.isNotBlank(selHomeOwnerOptions) && selHomeOwnerOptions=='Y' && SelPermanentRentOrOwn==RENT_SEL_TEXT){
                    system.debug('Checkooooo' + selHomeOwnerOptions + 'checkii'+ SelPermanentRentOrOwn);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Own Property option  as you have mentioned that you are a home owner choosen initially in application by you'));
                    noValidationErrors = false; 
                }else if (String.isNotBlank(selHomeOwnerOptions) && selHomeOwnerOptions=='N' && SelPermanentRentOrOwn==OWN_SEL_TEXT){
                    system.debug('Checkoooo2o' + selHomeOwnerOptions + 'checki2i'+ SelPermanentRentOrOwn);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Rent option as you have mentioned that you are not a home owner choosen initially in application by you'));
                    noValidationErrors = false; 
                }
                else {
                    Application.Home_Owner__c = SelPermanentRentOrOwn;
                }
            } 
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PERMANENT_RENT_OR_OWN));
                noValidationErrors = false; 
            }
        
        // Housing Costs
        if (HousingCosts == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_HOUSING_COSTS));
            noValidationErrors = false;   
        }
        
        //Risk Based Pricing
        if((SelLoanType != CREDIT_CARD) && (String.isNotBlank(SelPermanentRentOrOwn)) && (SelPermanentRentOrOwn == OWN_SEL_TEXT)){          
            if(HousingCosts != null && HousingCosts > 0){               
                if(String.isBlank(MortgageWith)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_MORTGAGE_WITH));
                    noValidationErrors = false;
                }               
            }
        }
        
        //Risk Based Pricing
        if((SelLoanType == CREDIT_CARD) && (String.isNotBlank(selHomeOwnerOptions)) && (selHomeOwnerOptions == YES_SEL_TEXT)){          
            if(HousingCosts != null && HousingCosts > 0){               
                if(String.isBlank(MortgageWith)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_MORTGAGE_WITH));
                    noValidationErrors = false;
                }               
            }
        }
        
        // Monthly Expenses
        if (MonthlyExpenses == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_MONTHLY_EXPENSES));
            noValidationErrors = false;    
        }
        
        if (validatePreviousAddress) {
            
            // Previous Address Street Number
            if (String.isBlank(PreviousAddressStreetNumber)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PREVIOUS_ADDRESS_STREET_NUMBER));
                noValidationErrors = false;     
            }
            
            // Previous Address Street Name
            if (String.isBlank(PreviousAddressStreetName)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PREVIOUS_ADDRESS_STREET_NAME));
                noValidationErrors = false;     
            }
            
            // Previous Address City
            if (String.isBlank(PreviousAddressCity)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PREVIOUS_ADDRESS_CITY));
                noValidationErrors = false;     
            }
            
            // Previous Address Province
            if (String.isNotBlank(SelPreviousProvince) && 
                validateSelectValue(getProvinceSelectOptionsWithQC(), SelPreviousProvince)) {
                    Application.Previous_Address_Province__c = SelPreviousProvince;             
                } 
                else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PREVIOUS_ADDRESS_PROVINCE));
                    noValidationErrors = false; 
                }
            
            // Previous Address Postal Code
            if (String.isBlank(PreviousAddressPostalCode) || 
                postalCodePattern.matcher(PreviousAddressPostalCode).matches() == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PREVIOUS_ADDRESS_POSTAL_CODE));
                    noValidationErrors = false;     
                }
            
            // Years and Months at Previous Address
            if (YearsAtPreviousAddress == 0 && MonthsAtPreviousAddress == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PREVIOUS_ADDRESS_HOW_LONG));
                noValidationErrors = false;         
            } 
        } 
        else {
            // Clear out Previous address info as it was collected incidentally
            PreviousAddressStreetNumber = null;
            PreviousAddressStreetName = null;
            PreviousAddressUnitNumber = null;
            PreviousAddressCity = null;
            PreviousAddressPostalCode = null;
            YearsAtPreviousAddress = null;
            MonthsAtPreviousAddress = null;
        }
        
        //check whether postalcode valid or not as per province     
        validatePostalCodeProvince(PermanentAddressPostalCode, Application.Permanent_Address_Province__c );        
        validatePostalCodeProvince(PreviousAddressPostalCode, Application.Previous_Address_Province__c );
        
        return noValidationErrors;
    }
    
    private Boolean validateStepThree() {
        Boolean noValidationErrors = true;
        
        // Employer Name
        if (String.isBlank(EmployerName)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_EMPLOYER_NAME));
            noValidationErrors = false;     
        }
        
        // Employer Phone
        Pattern phonePattern = Pattern.compile(REGEX_PHONE_NUMBER);
        if (String.isBlank(EmployerPhone) || phonePattern.matcher(EmployerPhone).matches() == false) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_EMPLOYER_PHONE));
            noValidationErrors = false;     
        }
        
        // Employer Street Number
        if (String.isBlank(EmployerStreetNumber)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_EMPLOYER_STREET_NUMBER));
            noValidationErrors = false;     
        }
        
        // Employer Street Name
        if (String.isBlank(EmployerStreetName)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_EMPLOYER_STREET_NAME));
            noValidationErrors = false;     
        }
        
        // Employer City
        if (String.isBlank(EmployerCity)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_EMPLOYER_CITY));
            noValidationErrors = false;     
        }
        
        // Employer Province
        if (String.isNotBlank(SelEmployerProvince) && 
            validateSelectValue(getProvinceSelectOptionsWithQC(), SelEmployerProvince)) {
                Application.Employer_Province__c = SelEmployerProvince;             
        } 
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_EMPLOYER_PROVINCE));
            noValidationErrors = false; 
        }
                
        //Employer Industry 
        if(String.isNotBlank(industryValue) && 
            validateSelectValue(Application__c.Industry__c.getDescribe(), industryValue)) {
                Application.Industry__c = industryValue;             
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_EMPLOYER_INDUSTRY));
            noValidationErrors = false; 
        }
        
        //Employer Job Description
        if(String.isNotBlank(jobDescriptionValue) && 
            validateSelectValue(Application__c.Job_Description__c.getDescribe(), jobDescriptionValue)) {
                Application.Job_Description__c = jobDescriptionValue;             
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_EMPLOYER_JOB_DESCRIPTION));
            noValidationErrors = false; 
        }
        
        // Employer Postal Code
        Pattern postalCodePattern = Pattern.compile(REGEX_POSTAL_CODE);
        
        if (String.isBlank(EmployerPostalCode) || 
            postalCodePattern.matcher(EmployerPostalCode).matches() == false) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_EMPLOYER_POSTAL_CODE));
                noValidationErrors = false;     
            }
        
        Boolean validatePreviousEmployer = false;
        
        // Years and Months at Employer
        if (EmploymentYears == null || EmploymentMonths == null || 
            (EmploymentYears == 0 && EmploymentMonths == 0)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_HOW_LONG_EMPLOYER));
                noValidationErrors = false;         
            } else if (EmploymentYears < 2) {
                validatePreviousEmployer = true;
            }
        
        // Gross Monthly Income
        if (GrossAnnualIncome == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_GROSS_ANNUAL_INCOME));
            noValidationErrors = false;         
        }
        
        if (validatePreviousEmployer) {
            // Previous Employer Name
            if (String.isBlank(PreviousEmployerName)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PREVIOUS_EMPLOYER_NAME));
                noValidationErrors = false;     
            }
            
            // Previous Employer Street Number
            if (String.isBlank(PreviousEmployerStreetNumber)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PREVIOUS_EMPLOYER_STREET_NUMBER));
                noValidationErrors = false;     
            }
            
            // Previous Employer Street Name
            if (String.isBlank(PreviousEmployerStreetName)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PREVIOUS_EMPLOYER_STREET_NAME));
                noValidationErrors = false;     
            }
            
            // Previous Employer City
            if (String.isBlank(PreviousEmployerCity)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PREVIOUS_EMPLOYER_CITY));
                noValidationErrors = false;     
            }
            
            // Previous Employer Province
            if (String.isNotBlank(SelPreviousEmployerProvince) && 
                validateSelectValue(getProvinceSelectOptionsWithQC(), SelPreviousEmployerProvince)) {
                    Application.Previous_Employer_Province__c = SelPreviousEmployerProvince;                
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PREVIOUS_EMPLOYER_PROVINCE));
                    noValidationErrors = false; 
                }
            
            // Previous Employer Postal Code
            if (String.isBlank(PreviousEmployerPostalCode) || 
                postalCodePattern.matcher(PreviousEmployerPostalCode).matches() == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PREVIOUS_EMPLOYER_POSTAL_CODE));
                    noValidationErrors = false;     
                }
            
            // Years and Months at Previous Employer
            if (PreviousEmploymentYears == null || PreviousEmploymentMonths == null || 
                (PreviousEmploymentYears == 0 && PreviousEmploymentMonths == 0)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_HOW_LONG_PREVIOUS_EMPLOYER));
                    noValidationErrors = false;         
                } 
            
            // Gross Monthly Income
            if (PreviousGrossAnnualIncome == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_PREVIOUS_GROSS_ANNUAL_INCOME));
                noValidationErrors = false;         
            }
            
        } else {
            // Clear out Previous employer info as it was collected incidentally
            PreviousEmployerName = null;
            PreviousEmployerStreetNumber = null;
            PreviousEmployerStreetName = null;
            PreviousEmployerUnitNumber = null;
            PreviousEmployerCity = null;
            PreviousEmployerPostalCode = null;
            PreviousEmploymentYears = null;
            PreviousEmploymentMonths = null;
            Application.Previous_Gross_Monthly_Income__c = null;
            PreviousGrossAnnualIncome = null;
        }
               
        //check whether postalcode valid or not as per province         
        validatePostalCodeProvince(Application.Employer_PostalCode__c, Application.Employer_Province__c );      
        validatePostalCodeProvince(Application.Previous_Employer_PostalCode__c, Application.Previous_Employer_Province__c );
        
        return noValidationErrors;
    }
    
    //check whether postalcode valid or not as per province     
    private Boolean validatePostalCodeProvince(String postalCode, String province){     
        
        Boolean noValidationErrors = true;      
        
        Map<String, set<String>> mapList = New Map<String, set<String>>();      
        mapList.put('NL',new Set<String>{'A'});     
        mapList.put('NS',new Set<String>{'B'});     
        mapList.put('PE',new Set<String>{'C'});     
        mapList.put('NB',new Set<String>{'E'});     
        mapList.put('QC',new Set<String>{'G','H','J'});     
        mapList.put('ON',new Set<String>{'K','L','M','N','P'});     
        mapList.put('MB',new Set<String>{'R'});     
        mapList.put('SK',new Set<String>{'S'});     
        mapList.put('AB',new Set<String>{'T'});     
        mapList.put('BC',new Set<String>{'V'});     
        mapList.put('NU',new Set<String>{'X'});     
        mapList.put('NT',new Set<String>{'X'});     
        mapList.put('YT',new Set<String>{'Y'});     
        
        if(String.isNotBlank(postalCode) && String.isNotBlank(province)){       
            
            postalCode = postalCode.toUpperCase();      
            province = province.toUpperCase();      
            
            if(! (mapList.get(province).contains(postalCode.substring(0, 1))) ){        
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_POSTALCODE_PROVINCE));     
                noValidationErrors = false;     
            }       
        }       
        return noValidationErrors;      
    }
    
    private Boolean validateSelectValue(Schema.DescribeFieldResult dfr, String value) {
        List<Schema.PicklistEntry> peList = dfr.getPicklistValues();
        for(Schema.PicklistEntry pe : peList) {
            if (value == pe.getValue()) {
                return true;
            }
        }
        return false;
    }
    
    private Boolean validateSelectValue(List<SelectOption> opts, String value) {
        for(SelectOption opt : opts) {
            if (value == opt.getValue()) {
                return true;
            }
        }
        return false;
    }
    
    private List<SelectOption> getSelectOptions(Schema.DescribeFieldResult dfr, Boolean addNoneOption, Boolean pleaseSelectOption) {
        List<SelectOption> selOpts = new List<SelectOption>();
        /*if (addNoneOption) {
            selOpts.add(new SelectOption('',NONE_SEL_TEXT));
        }
        if (pleaseSelectOption) {*/
            selOpts.add(new SelectOption('', PLEASE_SEL_TEXT)); 
        //}
        List<Schema.PicklistEntry> peList = dfr.getPicklistValues();
        for(Schema.PicklistEntry pe : peList) {
            selOpts.add(new SelectOption(pe.getValue(),pe.getLabel()));
        }
        return selOpts;
    }
    
    private List<SelectOption> getProvinceSelectOptions() {
        List<SelectOption> provOpts = new List<SelectOption>();
        provOpts.add(new SelectOption('', PLEASE_SEL_TEXT));
        provOpts.add(new SelectOption('AB', 'Alberta'));
        provOpts.add(new SelectOption('BC', 'British Columbia'));
        provOpts.add(new SelectOption('MB', 'Manitoba'));
        provOpts.add(new SelectOption('NB', 'New Brunswick'));
        provOpts.add(new SelectOption('NL', 'Newfoundland and Labrador'));
        provOpts.add(new SelectOption('NS', 'Nova Scotia'));
        provOpts.add(new SelectOption('ON', 'Ontario'));
        provOpts.add(new SelectOption('PE', 'Prince Edward Island'));
        provOpts.add(new SelectOption('SK', 'Saskatchewan'));
        provOpts.add(new SelectOption('NT', 'Northwest Territories'));
        provOpts.add(new SelectOption('NU', 'Nunavut'));
        provOpts.add(new SelectOption('YT', 'Yukon'));
        
        return provOpts;
    }
    
    private List<SelectOption> getProvinceSelectOptionsWithQC() {
        List<SelectOption> provOpts = new List<SelectOption>();
        provOpts.add(new SelectOption('', PLEASE_SEL_TEXT));
        provOpts.add(new SelectOption('AB', 'Alberta'));
        provOpts.add(new SelectOption('BC', 'British Columbia'));
        provOpts.add(new SelectOption('MB', 'Manitoba'));
        provOpts.add(new SelectOption('NB', 'New Brunswick'));
        provOpts.add(new SelectOption('NL', 'Newfoundland and Labrador'));
        provOpts.add(new SelectOption('NS', 'Nova Scotia'));
        provOpts.add(new SelectOption('ON', 'Ontario'));
        provOpts.add(new SelectOption('PE', 'Prince Edward Island'));
        provOpts.add(new SelectOption('QC', 'Quebec'));
        provOpts.add(new SelectOption('SK', 'Saskatchewan'));
        provOpts.add(new SelectOption('NT', 'Northwest Territories'));
        provOpts.add(new SelectOption('NU', 'Nunavut'));
        provOpts.add(new SelectOption('YT', 'Yukon'));
        
        return provOpts;
    }
    
    private List<SelectOption> getYesNoSelectOptions() {
        List<SelectOption> opts = new List<SelectOption>();
        opts.add(new SelectOption(YES_SEL_TEXT, YES_SEL_TEXT));
        opts.add(new SelectOption(NO_SEL_TEXT, NO_SEL_TEXT));
        
        return opts;    
    }
    
    private List<SelectOption> getYesNoSelectOptionsBkcp() {
        List<SelectOption> opts = new List<SelectOption>();
        opts.add(new SelectOption('Bankruptcy', 'Bankruptcy'));
        opts.add(new SelectOption('Consumer Proposal', 'Consumer Proposal'));
        opts.add(new SelectOption('None', 'None'));
        
        return opts;    
    }
        
    private List<SelectOption> getPermanentRentOrOwnSelectOptions() {
        List<SelectOption> opts = new List<SelectOption>();
        opts.add(new SelectOption(RENT_SEL_TEXT, RENT_SEL_TEXT));
        opts.add(new SelectOption(OWN_SEL_TEXT, OWN_SEL_TEXT));
        
        return opts;
    }
    
    //For CS tracking URL - To replace Ampersand to '&'
    private String replaceAmpersand(String str){
        
        String woAmpersand = '';
        
        woAmpersand = str.replaceAll('ampersand', '&');
        return woAmpersand;
    }
    
    //To redirect page to decision page if AFI number present
    private PageReference urlForDecisionPage(){
        
        Application__c app = [select id, Decision__c, Offer_Code__c from application__c where id =: Application.Id];
        PageReference p = new PageReference(LANDING_PAGE);
        Map<String, String> params = p.getParameters();
        params.put('FirstName', FirstName);
        params.put('LastName', LastName);
        SYSTEM.debug('cHECKDECISION'+ app.Decision__c);
        if (Utilities.APP_ACCEPTED_DECISIONS.contains(app.Decision__c) || app.Decision__c == DECISION_Rejected) {
            if (Utilities.APP_ACCEPTED_DECISIONS.contains(app.Decision__c)) {
                // Accepted
                params.put('Decision', DECISION_PARAM_ACCEPTED);
            } else {
                // Declined
                params.put('Decision', DECISION_Rejected);
            }
        } else {
            // Unknown decision result
            params.put('Decision', DECISION_PARAM_REVIEWED);
        }
        params.put('id', Application.Id);
        
        p.setRedirect(true);
        return p;
    }
    
    //Get Eligible Product Options for PreApplication Form
    public List<SelectOption> getEligibleProductOptions2() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No'));
        return options;
    }
    
    //Get Primary phone number options
    public List<SelectOption> getPrimaryPhoneOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Home Phone','Home Phone'));
        options.add(new SelectOption('Mobile Phone','Mobile/Cell Phone'));
        options.add(new SelectOption('Work Phone','Work Phone'));
        return options;
    }
    
    //Populate Occupation for customer
    public List<SelectOption> getOccupationList() {
        List<SelectOption> options = new List<SelectOption>();
        return getSelectOptions(Application__c.Occupation_Dropdown__c.getDescribe(), false, true);
        //return options;
    }
    
    //Populte Industry values for customer employment
    public List<SelectOption> getIndustryList() {
        List<SelectOption> options = new List<SelectOption>();
        
        return getSelectOptions(Application__c.Industry__c.getDescribe(), false, true);
    }
    
    //Populte Industry values for customer employment
    Public List<SelectOption> getJobDescriptionList(){
        return derivedJobDescriptionList;
    }
    
    public Pagereference populateJobList(){
        
        derivedJobDescriptionList = new List<SelectOption>();
        
        system.debug('Industry value : ' + industryValue);
        derivedJobDescriptionList.add(New SelectOption('', 'Please Select'));
        if(!String.isBlank(industryValue)){
            for(String picklistValue : mapDependentPicklist.get(industryValue)){
                derivedJobDescriptionList.add(New SelectOption(picklistValue ,picklistValue));
            }
        }
        
        system.debug('Job List : ' + derivedJobDescriptionList);
        return null;
    }
        
    //To populate dependent picklist values
    public static Map<String, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
     
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
     
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars = String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        
        system.debug('Map of List ' + dependentPicklistValues);
        return dependentPicklistValues;
    }
}