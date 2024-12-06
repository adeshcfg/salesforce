/**
 * @description       : Controller class for LOR demand VF email templates
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 07-30-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class LorVfTemplateController {
    public Insolvency_Account__c insolvAcc { get; set; }
    public PoC_Package_Settings__c pocPackage { get; set; }
    public LorInformationWrapper otherInfo { get; set; }
    public LorVfTemplateController() {
        insolvAcc = [
            SELECT
                Id,
                Insolvency__r.Trustee__r.Communication_Preference__c,
                Insolvency__r.Trustee__r.Business_Email__c,
                Insolvency__r.Trustee__r.Fax,
                Trustee_Company__c,
                Trustee_Office__c,
                Insolvency__r.Trustee__r.Preferred_Language__c,
                Insolvency__r.Debtor__c,
                Is_Active__c,
                Insolvency__r.Co_Debtor__c,
                Security_Type__c,
                Security_Description__c,
                Insolvency_Status_Last_Changed__c,
                Client_Identifier__c,
                Claim_Type__c,
                Insolvency__r.Name,
                Name,
                Insolvency__r.Debtor_1_First_Name__c,
                Insolvency__r.Debtor_1_Last_Name__c,
                Date_LOR_received_for_Secured__c,
                PoC_Created_Date__c,
                Insolvency_Status__c,
                Secured_Name__c,
                LOR_Notice_1_Sent_Date__c,
                LOR_Notice_2_Sent_Date__c,
                LoR_Notice_1_FollowUp_Date__c,
                Vehicle_Identification_Number__c,
                Account_Type__c,
                Bank_Name__c
            FROM Insolvency_Account__c
            WHERE Id = :ApexPages.currentPage().getParameters().get('Id')
        ];
        populateInformation(insolvAcc, ApexPages.currentPage().getParameters().get('selectedLanguage'));
    }

    /**
     * @description : Method to assign/reassign correct values as per conditions
     * @author adesh.ikhar@canaccede.com | 07-30-2024
     * @param insolvAcc
     * @param languageValue
     **/
    public void populateInformation(Insolvency_Account__c insolvAcc, String languageValue) {
        Set<String> fairstoneProductTypes = new Set<String>{ 'Secured', 'PL Unsecured', 'PL Secured', 'PL Auto Secured', 'Retail', 'Auto Loans' };
            
        pocPackage = PoC_Package_Settings__c.getValues(insolvAcc.Client_Identifier__c);
        Date dateToday = System.Today();
        otherInfo = new LorInformationWrapper();
        // Convert DateTime to Date format ex: May 01, 2018
        String formattedDate = DateTime.newInstance(dateToday.year(), dateToday.month(), dateToday.day()).formatGMT('MMM dd, YYYY');
        String companyName = pocPackage.Company_Name__c;
        String clientCompanyName = pocPackage.Client_Company_Name__c;
        String bankNameWiseCompanyName = pocPackage.Client_Company_Name__c;
        String bankNameWiseFrenchCompanyName = pocPackage.Client_Company_Name_French__c;
        // Only used in French template
        String clientCompanyNameSuffix = ' (« Banque Scotia »)';
        if (insolvAcc.Client_Identifier__c == 'Goeasy' && insolvAcc.Account_Type__c == 'Leasing product') {
            pocPackage.Client_Company_Name__c = pocPackage.CFG_Office_Name_2__c;
            clientCompanyNameSuffix = '';
            companyName = pocPackage.CFG_Office_Name_2__c;
            clientCompanyName = pocPackage.CFG_Office_Name_2__c.toUppercase();
            bankNameWiseCompanyName = pocPackage.Company_Name__c;
            bankNameWiseFrenchCompanyName = pocPackage.Company_Name__c;
            if (languageValue == 'fr') {
                pocPackage.Client_Company_Name_French__c = pocPackage.CFG_Office_Name_2__c;
            }
        }
        if (insolvAcc.Client_Identifier__c == 'Goeasy' && insolvAcc.Account_Type__c != 'Leasing product') {
            clientCompanyNameSuffix = '';
            companyName = 'Easyfinancial';
            clientCompanyName = companyName.toUppercase();
            bankNameWiseCompanyName = pocPackage.Company_Name__c;
            bankNameWiseFrenchCompanyName = pocPackage.Company_Name__c;
            if (languageValue == 'fr') {
                pocPackage.Client_Company_Name_French__c = 'Easyfinancial';
            }
        }
        if (insolvAcc.Client_Identifier__c == 'Fairstone' && fairstoneProductTypes.contains(insolvAcc.Account_Type__c)) {
            clientCompanyName = pocPackage.Fairstone_New_Product_Company_Detail__c;
            companyName = pocPackage.Fairstone_New_Product_Company_Detail__c;
            pocPackage.Client_Company_Name_French__c = pocPackage.Fairstone_New_Product_Company_Detail__c;
        }
        
        pocPackage.Client_Company_Name__c = pocPackage.Client_Company_Name__c.toUppercase();
        pocPackage.CFG_Office_Phone_Number__c = pocPackage.CFG_Office_Phone_Number__c.replace('-', '.');
        pocPackage.CFG_Office_Fax_Number__c = pocPackage.CFG_Office_Fax_Number__c.replace('-', '.');
        // Populate wrapped fields which cannot be reassigned to object fields
        otherInfo.isEnglish = languageValue != 'fr';
        otherInfo.imageUrl = insolvAcc.Client_Identifier__c == 'Goeasy'
            ? LoRDemandController.getImageUrl('CFG_monogram_Logo')
            : LoRDemandController.getImageUrl('CFG_Logo_Temp1');
        otherInfo.today = formattedDate;
        otherInfo.debitors =
            (insolvAcc.Insolvency__r.Debtor__c != null ? insolvAcc.Insolvency__r.Debtor__c : '') +
            (insolvAcc.Insolvency__r.Co_Debtor__c != null
                ? (insolvAcc.Insolvency__r.Debtor__c != null ? ', ' : '') + insolvAcc.Insolvency__r.Co_Debtor__c
                : '');
        otherInfo.companyName = companyName;
        otherInfo.clientCompanyName = clientCompanyName;
        otherInfo.clientCompanyNameSuffix = clientCompanyNameSuffix;
        otherInfo.fiveBusinessDays = LoRDemandController.WeekdayCalculate();
        otherInfo.bankNameWiseCompanyName = bankNameWiseCompanyName;
        otherInfo.bankNameWiseFrenchCompanyName = bankNameWiseFrenchCompanyName;
        otherInfo.insolvencyStatusLastChanged = String.valueOf(insolvAcc.Insolvency_Status_Last_Changed__c.formatGMT('MMM dd, YYYY'));
        otherInfo.noticeOneSentDate = (insolvAcc.LOR_Notice_1_Sent_Date__c != null
            ? DateTime.newInstance(
                      insolvAcc.LOR_Notice_1_Sent_Date__c.year(),
                      insolvAcc.LOR_Notice_1_Sent_Date__c.month(),
                      insolvAcc.LOR_Notice_1_Sent_Date__c.day()
                  )
                  .format('MMM dd, YYYY')
            : '');
    }

    // Wrapper class for extra fields
    public class LorInformationWrapper {
        public Boolean isEnglish { get; set; }
        public String imageUrl { get; set; }
        public String noticeOneSentDate { get; set; }
        public String insolvencyStatusLastChanged { get; set; }
        public String today { get; set; }
        public String debitors { get; set; }
        public String companyName { get; set; }
        public String clientCompanyName { get; set; }
        public String clientCompanyNameSuffix { get; set; }
        public String fiveBusinessDays { get; set; }
        public String bankNameWiseCompanyName { get; set; }
        public String bankNameWiseFrenchCompanyName { get; set; }
    }
}