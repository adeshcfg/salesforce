/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is used to populate data in POC pdf
 *  @author : A5E Consulting
 *  @date : 10/08/2017
 
*************************************************************************************************/
public class POCDocDataController {
    //Collection
    //map to store french translation of POCPackageSettings in english
    public map<String, String> mapPOCPackageSettingTranslation { get; set; }

    public Insolvency_Account__c insolvAcc { get; set; }
    public PoC_Package_Settings__c pocPackage { get; set; }
    public Remittance_Group_Mapping_For_PoC__c remGroupMap { get; set; }
    public String formattedDate { get; set; }
    public String formattedDateToday { get; set; }
    public String formattedLastpaymentDate { get; set; }
    public String formattedSecondLastPayDate {get; set;}
    public String formattedThridLastPayDate {get; set;}
    public String formattedAccountOriginalOpenDate {get; set;}
    public String formattedAccountOpenDate {get; set;}
    public String formattedDebtDueOffDate {get; set;}
    public String formattedAcknowledgementDate {get; set;}
    public String formattedAccountChargedoffDate {get; set;}
    public String formattedDateTodayHeader { get; set; }
    public Boolean spaceCount { get; set; }

    public POCDocDataController() {
        mapPOCPackageSettingTranslation = new Map<String, String>();
        mapPOCPackageSettingTranslation.put('The Bank of Nova Scotia', 'LA BANQUE DE NOUVELLE-ÉCOSSE');
        mapPOCPackageSettingTranslation.put('Bankruptcy', 'la faillite');
        mapPOCPackageSettingTranslation.put('Consumer Proposal', 'Proposition de Consomateur');
        mapPOCPackageSettingTranslation.put('Division 1 Proposal', 'Proposition de la division 1');

        insolvAcc = [
            SELECT
                Id,
                Name,
                Insolvency_Type__c,
                Business_Account__c,
                //Debtor_1_Estate_Number__c, Debtor_2_Estate_Number__c,
                Insolvency__r.Name,
                Insolvency__r.Debtor_2_Estate_Number__c,
                Insolvency__r.Insolvency_Type__c,
                Insolvency__r.Debtor_1_Mailing_City__c,
                Secured_Name__c,
                Insolvency__r.Debtor_1_Mailing_State_Province__c,
                Portfolio_Group_Name__c,
                Vendor_Orginator__c,
                Insolvency__r.Trustee__r.BillingStreet,
                Insolvency__r.Trustee__r.BillingCity,
                Insolvency__r.Trustee__r.BillingState,
                Insolvency__r.Trustee__r.BillingPostalCode,
                Insolvency__r.Trustee__r.BillingCountry,
                Vehicle_Identification_Number__c,
                //Added for Fidem PoC
                Insolvency__r.Debtor_1_Mailing_Street__c,
                Insolvency__r.Debtor_2_Mailing_Street__c,
                Insolvency__r.Debtor_2_Mailing_City__c,
                Insolvency__r.Debtor_1_Mailing_Postal_Code__c,
                Insolvency__r.Debtor_2_Mailing_Postal_Code__c,
                //Debtor_1_Court_Number__c, Debtor_2_Court_Number__c,
                Insolvency__r.Debtor_1_Court_Number__c,
                Insolvency__r.Debtor_2_Court_Number__c,
                Insolvency__r.Court_District_Name__c,
                Insolvency__r.Court_Division_Number__c,
                Insolvency__r.Court_Province__c,
                Insolvency__r.Insolvency_Date__c,
                Secured_Asset_Amount__c,
                Security_Description__c,
                Voting_Letter_Comments__c,
                Claim_Type__c,
                Claim_Amount__c,
                Amended_Claim_Flag__c,
                Insolvency__r.Trustee__r.Name,
                Insolvency__r.Trustee__r.Parent.Name,
                Client_Identifier__c,
                Last_Payment_Date__c,
                Last_Payment_Amount__c,
                Interest_Rate__c,
                Insolvency_Status__c,
                Bank_Name__c,
                Insolvency__r.Debtor_1_First_Name__c,
                Insolvency__r.Debtor_1_Last_Name__c,
                Insolvency__r.Debtor_1_Middle_Name__c,
                Insolvency__r.Debtor_2_First_Name__c,
                Insolvency__r.Debtor_2_Last_Name__c,
                Insolvency__r.Debtor_2_Middle_Name__c,
                Statements_Required__c,
                Proof_of_Claim_Required__c,
                Voting_Options__c,
                Include_Voting_Letter__c,
                Amended_PoC_Created_Date__c,
                PoC_Created_Date__c,
                Account_Type__c,
                Charge_Off_Date__c,
                Account_Original_Open_Date__c,
                Last_Payment_Date_2__c,
                Last_Payment_Date_3__c,
                Last_Payment_Amount_2__c,
                Last_Payment_Amount_3__c,
                Acknowledgement_date__c,
                Debt_Due_as_off_date__c,
                Account_Open_date__c
            FROM Insolvency_Account__c
            WHERE Id = :ApexPages.currentPage().getParameters().get('Id')
        ];

        Map<Integer, String> frenchDates = new Map<Integer, String>();
        frenchDates.put(1, 'Janvier');
        frenchDates.put(2, 'Février');
        frenchDates.put(3, 'Mars');
        frenchDates.put(4, 'Avril');
        frenchDates.put(5, 'Mai');
        frenchDates.put(6, 'Juin');
        frenchDates.put(7, 'Juillet');
        frenchDates.put(8, 'Août');
        frenchDates.put(9, 'Septembre');
        frenchDates.put(10, 'Octobre');
        frenchDates.put(11, 'Novembre');
        frenchDates.put(12, 'Décembre');

        Datetime dateNow = Datetime.now();

        if (insolvAcc.Insolvency__r.Insolvency_Date__c != null) {
            formattedDate = String.valueOf(
                ' ' +
                    frenchDates.get(insolvAcc.Insolvency__r.Insolvency_Date__c.month()) +
                    ' ' +
                    String.valueOf(insolvAcc.Insolvency__r.Insolvency_Date__c.year())
            );
        }
        formattedDateToday = String.valueOf(' ' + frenchDates.get(dateNow.month()) + ' ' + String.valueOf(dateNow.year()));
        if (insolvAcc.Last_Payment_Date__c != null) {
            formattedLastpaymentDate = String.valueOf(
               // String.valueOf(insolvAcc.Last_Payment_Date__c.month()) +
                    ' ' +
                    frenchDates.get(insolvAcc.Last_Payment_Date__c.month()) +
                    ' ' +
                    String.valueOf(insolvAcc.Last_Payment_Date__c.year())
            );
        }
        if (insolvAcc.Last_Payment_Date_2__c != null) {
                formattedSecondLastPayDate = String.valueOf(
                    //String.valueOf(insolvAcc.Last_Payment_Date_2__c.month()) +
                    ' ' +
                        frenchDates.get(insolvAcc.Last_Payment_Date_2__c.month()) +
                        ', ' +
                        String.valueOf(insolvAcc.Last_Payment_Date_2__c.year())
                );
            }
            if (insolvAcc.Last_Payment_Date_3__c != null) {
                formattedThridLastPayDate = String.valueOf(
                    
                    ' ' +
                        frenchDates.get(insolvAcc.Last_Payment_Date_3__c.month()) +
                        ', ' +
                        String.valueOf(insolvAcc.Last_Payment_Date_3__c.year())
                );
            }
        if (insolvAcc.Account_Original_Open_Date__c != null) {
            formattedAccountOriginalOpenDate = String.valueOf(
                    ' ' +
                        frenchDates.get(insolvAcc.Account_Original_Open_Date__c.month()) +
                        ', ' +
                        String.valueOf(insolvAcc.Account_Original_Open_Date__c.year())
                );
            }   
        if (insolvAcc.Account_Open_date__c != null) {
            formattedAccountOpenDate = String.valueOf(
                    ' ' +
                        frenchDates.get(insolvAcc.Account_Open_date__c.month()) +
                        ', ' +
                        String.valueOf(insolvAcc.Account_Open_date__c.year())
                );
            }   
            if (insolvAcc.Charge_Off_Date__c != null) {
                formattedAccountChargedoffDate = String.valueOf(
                    ' ' +
                        frenchDates.get(insolvAcc.Charge_Off_Date__c.month()) +
                        ', ' +
                        String.valueOf(insolvAcc.Charge_Off_Date__c.year())
                );
            }
        if (insolvAcc.Debt_Due_as_off_date__c != null) {
                formattedDebtDueOffDate = String.valueOf(
                    ' ' +
                        frenchDates.get(insolvAcc.Debt_Due_as_off_date__c.month()) +
                        ' ' +
                        String.valueOf(insolvAcc.Debt_Due_as_off_date__c.year())
                );
            }
        if (insolvAcc.Acknowledgement_date__c != null) {
                formattedAcknowledgementDate = String.valueOf(
                    ' ' +
                        frenchDates.get(insolvAcc.Acknowledgement_date__c.month()) +
                        ' ' +
                        String.valueOf(insolvAcc.Acknowledgement_date__c.year())
                );
            }
        
        
        

        formattedDateTodayHeader = String.valueOf(' ' + frenchDates.get(dateNow.month()) + ' ' + dateNow.day() + ' ' + String.valueOf(dateNow.year()));
        // Read poc Package custom setting to fetch related data
        pocPackage = (PoC_Package_Settings__c) PoC_Package_Settings__c.getValues(insolvAcc.Client_Identifier__c);
        spaceCount = false;
        if (pocPackage.Client_Company_Name__c.length() < 13) {
            spaceCount = true;
            //for(Integer i=1;i<13-pocPackage.Client_Company_Name__c.length();i++){
            //spaceCount += '&nbsp;';
            //}
        }
        //Fetch first 3 letters of Portfolio Group Name
        //String portGroupMapShort = LEFT(insolvAcc.Portfolio_Group_Name__c,3);
        if (insolvAcc.Portfolio_Group_Name__c != null) {
            String portGroupMapShort = insolvAcc.Portfolio_Group_Name__c.LEFT(3);
            // Read Remittance group mapping custom setting to fetch related data
            remGroupMap = (Remittance_Group_Mapping_For_PoC__c) Remittance_Group_Mapping_For_PoC__c.getValues(portGroupMapShort);
        }
    }
}