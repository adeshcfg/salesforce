/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Batch Class that populates PTP Met value on PTP Information record and on Product record
*  @author : A5E Consulting
*  @date : 09/14/2017   

*************************************************************************************************/
public class PTPMetBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Add condition to only get Products which have atleast one child PTP_Information__C record
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Name,
                    CreatedDate,
                    Last_Payment_Date__c,
                    Last_Payment_Amount__c,
                    PTP1_Method__c,
                    PTP1_Amount__c,
                    PTP1_Date__c,
                    PTP1_mate__c,
                    Delinquency_Days__c
                FROM Product__C
                WHERE Id IN (SELECT Product__c FROM PTP_Information__C)
            ]
        );
    }

    public void execute(Database.BatchableContext BC, List<Product__c> prodList) {
        List<ID> prodIDList = new List<ID>();
        for (Product__C prod : prodList) {
            prodIDList.add(prod.id);
        }
        List<PTP_Information__c> listPTPGreater = [
            SELECT id, name, PTP_Method__c, PTP_Amount__c, PTP_Date__c, PTP_Mate__c, Product__r.id, createdDate
            FROM PTP_Information__C
            WHERE PTP_Date__c >= YESTERDAY AND Product__r.id IN :prodIDList
        ];

        DateTime defaultDate = (System.now()).addDays(-(Integer.valueOf(31)));

        List<PTP_Information__c> listPTPLess = [
            SELECT id, name, PTP_Method__c, PTP_Amount__c, PTP_Date__c, PTP_Mate__c, Product__r.id, createdDate
            FROM PTP_Information__C
            WHERE PTP_Date__c < YESTERDAY AND PTP_Date__C > :defaultDate AND Product__r.id IN :prodIDList
        ];

        List<PTP_Information__C> toUpdatePTP = new List<PTP_Information__c>();

        for (Product__c prod : prodList) {
            Map<DateTime, PTP_Information__c> mapPTPProd = new Map<DateTime, PTP_Information__c>();

            List<DateTime> listDate = new List<DateTime>();
            for (PTP_Information__c ptp : listPTPGreater) {
                if (prod.id == ptp.Product__r.id) {
                    mapPTPProd.put(ptp.PTP_Date__c, ptp);
                    listDate.add(ptp.PTP_Date__c);
                }
            }

            listDate.sort();

            PTP_Information__c PTP_N = new PTP_Information__C();
            DateTime PTP_N_Date = null;
            if (listDate.size() > 0) {
                PTP_N_Date = listDate[0];
                PTP_N = mapPTPProd.get(PTP_N_Date);
            } else {
                PTP_N = null;
            }

            DateTime PTP_L_Date = null;
            PTP_Information__c PTP_L = new PTP_Information__c();

            if (null <> PTP_N) {
                mapPTPProd = new Map<DateTime, PTP_Information__c>();
                listDate = new List<DateTime>();
                for (PTP_Information__c ptp : listPTPLess) {
                    if (prod.id == ptp.Product__r.id) {
                        mapPTPProd.put(ptp.PTP_Date__c, ptp);
                        listDate.add(ptp.PTP_Date__c);
                    }
                }

                listDate.sort();

                if (listDate.size() > 0) {
                    PTP_L_Date = listDate[listDate.size() - 1];
                    PTP_L = mapPTPProd.get(PTP_L_Date);
                } else {
                    PTP_L = null;
                }
                if (PTP_L == null) {
                    if (
                        prod.Last_Payment_Date__c >= (PTP_N.createdDate).date() &&
                        prod.Last_Payment_Date__c <= (PTP_N.PTP_Date__c).date() &&
                        prod.Last_Payment_Amount__c >= PTP_N.PTP_Amount__c
                    ) {
                        prod.PTP1_Mate__C = true;
                        PTP_N.PTP_Mate__c = true;
                        toUpdatePTP.add(PTP_N);
                    } else {
                        prod.PTP1_Mate__C = false;
                    }
                } else {
                    DateTime PreviousDate = findMaxDate(PTP_L.PTP_Date__c, prod.Delinquency_Days__c);
                     system.debug('prod.Last_Payment_Date__c--->'+prod.Last_Payment_Date__c);
                     system.debug('prod.Last_Payment_Amount__c--->'+prod.Last_Payment_Amount__c);
                     system.debug('PreviousDate--->'+(PreviousDate).date());
                     system.debug('(PTP_N.PTP_Date__c).date()--->'+(PTP_N.PTP_Date__c).date());
                     system.debug('PTP_N.PTP_Amount__c--->'+PTP_N.PTP_Amount__c);
                    if (
                        prod.Last_Payment_Date__c >= (PreviousDate).date() &&
                        prod.Last_Payment_Date__c <= (PTP_N.PTP_Date__c).date() &&
                        prod.Last_Payment_Amount__c >= PTP_N.PTP_Amount__c
                    ) {
                        prod.PTP1_Mate__C = true;
                        PTP_N.PTP_Mate__c = true;
                        toUpdatePTP.add(PTP_N);
                    } else {
                        prod.PTP1_Mate__C = false;
                    }
                }
            } else {
                prod.PTP1_Mate__C = false;
            }
        }

        PTPInformationTriggerHandler.runPTPTrigger = false;
        update toUpdatePTP;
        PTPInformationTriggerHandler.runPTPTrigger = true;
        ProductTriggerHandler.runProductTrigger = false;
        update prodList;
        ProductTriggerHandler.runProductTrigger = true;
    }

    public void finish(Database.BatchableContext BC) {
    }

    public DateTime FindMaxDate(DateTime PTPLDate, Decimal NumberOfDelinquentDays) {
        DateTime delinquentDate = null;
        if (NumberOfDelinquentDays == null) {
            delinquentDate = System.now();
        } else {
            delinquentDate = FindMinDate(NumberOfDelinquentDays);
        }
        if (PTPLDate >= delinquentDate) {
            return PTPLDate;
        } else {
            return delinquentDate;
        }
    }

    public DateTime FindMinDate(Decimal NumberOfDelinquentDays) {
        DateTime minDate = null;
        DateTime minDefaultDate = null;

        minDate = (System.now()).addDays(-(Integer.valueOf(NumberOfDelinquentDays)));
        minDefaultDate = (System.now()).addDays(-(Integer.valueOf(30)));

        if (minDate > minDefaultDate) {
            return minDefaultDate;
        } else {
            return minDate;
        }
    }
}