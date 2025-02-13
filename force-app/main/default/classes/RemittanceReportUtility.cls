public class RemittanceReportUtility {

    /**
     * @description : Method to get list of reports to remitttance
     * @author tejal.vidhate@canaccede.com | 13-02-2025
     * @return List<String>
     **/
    @AuraEnabled(cacheable=true)
    public static List<String> getReportNameList() {
        List<String> reportList = new List<String>();
 
        reportList.add('Secured Payments - BNS Retail Remittance');
        reportList.add('Secured Payments - BNS Small Business');
        reportList.add('Canadian Tire remittances');
        reportList.add('Easy Financial Secured');
        reportList.add('Easy Home Service Only');
        return reportList;
    }
}
