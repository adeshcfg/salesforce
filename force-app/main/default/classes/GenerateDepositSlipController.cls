public class GenerateDepositSlipController {
    public String type { get; set; }
    public integer size { get; set; }
    public decimal total { get; set; }

    public List<Insolvency_Payment__c> insolvPayList = new List<Insolvency_Payment__c>();
    transient public List<DepositWrapper> lisDepotWrap { get; set; }
    public List<SuspenseWrapper> listSuspWrap = new List<SuspenseWrapper>();

    //Affirm Suspense account lists
    transient public List<SuspenseWrapper> listAAL { get; set; }
    transient public List<SuspenseWrapper> listETC { get; set; }
    transient public List<SuspenseWrapper> listAFL { get; set; }
    transient public List<SuspenseWrapper> listAFSI { get; set; }

    //Canaccede Suspense account lists
    transient public List<SuspenseWrapper> listCAL { get; set; }
    transient public List<SuspenseWrapper> listCIH { get; set; }
    transient public List<SuspenseWrapper> listCCL { get; set; }
    transient public List<SuspenseWrapper> listCIA { get; set; }
    transient public List<SuspenseWrapper> listCFL { get; set; }
    transient public List<SuspenseWrapper> listCIML { get; set; }
    transient public List<List<SuspenseWrapper>> listOfListCIML { get; set; }

    //Affirm Suspense account total
    public Decimal totalAAL { get; set; }
    public Decimal totalETC { get; set; }
    public Decimal totalAFL { get; set; }
    public Decimal totalAFSI { get; set; }

    //Canaccede Suspense account total
    public Decimal totalCAL { get; set; }
    public Decimal totalCIH { get; set; }
    public Decimal totalCCL { get; set; }
    public Decimal totalCIA { get; set; }
    public Decimal totalCFL { get; set; }
    public Decimal totalCIML { get; set; }

    Map<String, Deposit_Accounts__c> depositAccountMap = Deposit_Accounts__c.getAll();
    public Deposit_Accounts__c depositAcc { get; set; }
    // Controller
    public GenerateDepositSlipController() {
        type = ApexPages.currentPage().getParameters().get('type');
        total = 0.0;
        insolvPayList = new List<Insolvency_Payment__c>();
        lisDepotWrap = new List<DepositWrapper>();
        listSuspWrap = new List<SuspenseWrapper>();
        List<String> listParameter = new List<string>();

        //Initialize Affirm Suspense account lists
        listAAL = new List<SuspenseWrapper>();
        listETC = new List<SuspenseWrapper>();
        listAFL = new List<SuspenseWrapper>();
        listAFSI = new List<SuspenseWrapper>();

        //Initialize Canaccede Suspense account lists
        listCAL = new List<SuspenseWrapper>();
        listCIH = new List<SuspenseWrapper>();
        listCCL = new List<SuspenseWrapper>();
        listCIA = new List<SuspenseWrapper>();
        listCFL = new List<SuspenseWrapper>();
        listCIML = new List<SuspenseWrapper>();
        listOfListCIML = new List<List<SuspenseWrapper>>();

        //Initialize Affirm Suspense account total
        totalAAL = 0.0;
        totalETC = 0.0;
        totalAFL = 0.0;
        totalAFSI = 0.0;

        //Initialize Canaccede Suspense account total
        totalCAL = 0.0;
        totalCIH = 0.0;
        totalCCL = 0.0;
        totalCIA = 0.0;
        totalCFL = 0.0;
        totalCIML = 0.0;

        String parameter = type;
        if (type == 'Canaccede_Account_Perticulars' || type == 'CIML' || type == '') {
            listParameter.add('CIML');
            listParameter.add('');
            listParameter.add(null);
            parameter = 'CIML';
            //type = 'CIML';
        } else if (type == 'Affirm_Account_Perticulars' || type == 'AFSI') {
            listParameter.add('AFSI');
            //type = 'AFSI';
        } else if (type == 'CCL' || type == 'CLP') {
            listParameter.add('CCL');
            listParameter.add('CLP');
        } else if (type == 'ETC' || type == 'AFF') {
            listParameter.add('ETC');
            listParameter.add('AFF');
        } else if (type == 'CIA' || type == 'CIH' || type == 'AAL') {
            listParameter.add('CIA');
            listParameter.add('CIH');
            listParameter.add('AAL');
        } else {
            listParameter.add(type);
        }
        DateTime LastDepositSlipCreatedDate = GenerateDepositSlipRecordsController.LastDepositSlipCreatedDate();
        List<Remittance__C> listRemittance = [
            SELECT id, name, Bank_Account_Number__c, Transit_Code__c, Entity_Name__c, Trustee_Name__r.name, Cheque_Amount__c, Cheque_Payment_Reference_Number__c
            FROM remittance__C
            WHERE
                Deposit_Account_Name__c IN :listParameter
                AND Status__c = 'Processed'
                AND recordType.Developername = 'Insolvency_Dividend'
                AND lastmodifiedDate > :LastDepositSlipCreatedDate
                ORDER BY remittance__r.Trustee_Name__r.name
        ];
        List<ID> listRemittanceID = new List<ID>();
        for (Remittance__C rem : listRemittance) {
            listRemittanceID.add(rem.id);
        }
        size = listRemittance.size();
        depositAcc = depositAccountMap.get(parameter);
        for (Remittance__C rem : listRemittance) {
            DepositWrapper wrp = new DepositWrapper();

            wrp.trusteeName = rem.Trustee_Name__r.name + ' - ' + rem.Cheque_Payment_Reference_Number__c;
            wrp.paymentAmount = rem.Cheque_Amount__c;
            total += rem.Cheque_Amount__c;
            lisDepotWrap.add(wrp);
        }
        if (type == 'Canaccede_Account_Perticulars' || type == 'Affirm_Account_Perticulars') {
            for (Insolvency_Payment__c insolPay : [
                SELECT
                    id,
                    name,
                    Insolvency_account__r.name,
                    Insolvency_account__r.Portfolio_Group_Name__c,
                    Cheque_Payment_Reference_Number__c,
                    Deposit_Account_Type__c,
                    Payment_Amount__c,
                    remittance__r.Cheque_Payment_Reference_Number__c,
                    remittance__r.Trustee_Name__r.name
                FROM Insolvency_Payment__c
                WHERE remittance__c IN :listRemittanceID 
                AND remittance__r.recordtype.Developername = 'Insolvency_Dividend' 
                AND Is_Payment_Remitted__c = FALSE
                ORDER BY remittance__r.Trustee_Name__r.name
            ]) {
                if (null != insolPay.Deposit_Account_Type__c) {
                    depositAcc = depositAccountMap.get(insolPay.Deposit_Account_Type__c);
                } else {
                    depositAcc = depositAccountMap.get('CIML');
                }
                SuspenseWrapper wrp = new SuspenseWrapper();

                if (null == depositAcc) {
                    depositAcc = depositAccountMap.get('CIML');
                }

                wrp.accountName = insolPay.Insolvency_account__r.name;
                wrp.transit = depositAcc.Transit_Number__c;
                wrp.entity = depositAcc.Account_Name_on_Clearing_Account__c;
                wrp.bankAccountName = depositAcc.Account_Number__c;
                wrp.trustee = insolPay.remittance__r.Trustee_Name__r.name + ' - ' + insolPay.remittance__r.Cheque_Payment_Reference_Number__c;
                wrp.paymentAmount = insolPay.Payment_Amount__c;

                if (insolPay.Deposit_Account_Type__c == 'AAL') {
                    listCIH.add(wrp);
                    totalCIH += insolPay.Payment_Amount__c;
                } else if (insolPay.Deposit_Account_Type__c == 'ETC') {
                    listETC.add(wrp);
                    totalETC += insolPay.Payment_Amount__c;
                } else if (insolPay.Deposit_Account_Type__c == 'AFF') {
                    listETC.add(wrp);
                    totalETC += insolPay.Payment_Amount__c;
                } else if (insolPay.Deposit_Account_Type__c == 'AFL') {
                    listAFL.add(wrp);
                    totalAFL += insolPay.Payment_Amount__c;
                } else if (insolPay.Deposit_Account_Type__c == 'CAL') {
                    listCAL.add(wrp);
                    totalCAL += insolPay.Payment_Amount__c;
                } else if (insolPay.Deposit_Account_Type__c == 'CIH') {
                    listCIH.add(wrp);
                    totalCIH += insolPay.Payment_Amount__c;
                } else if (insolPay.Deposit_Account_Type__c == 'CCL') {
                    listCCL.add(wrp);
                    totalCCL += insolPay.Payment_Amount__c;
                } else if (insolPay.Deposit_Account_Type__c == 'CLP') {
                    listCCL.add(wrp);
                    totalCCL += insolPay.Payment_Amount__c;
                } else if (insolPay.Deposit_Account_Type__c == 'CIA') {
                    listCIH.add(wrp);
                    totalCIH += insolPay.Payment_Amount__c;
                } else if (insolPay.Deposit_Account_Type__c == 'CFL') {
                    listCFL.add(wrp);
                    totalCFL += insolPay.Payment_Amount__c;
                } else if (insolPay.Deposit_Account_Type__c == 'CIML' || null == insolPay.Deposit_Account_Type__c) {
                    if (listCIML.size() == 999) {
                        listOfListCIML.add(listCIML);
                        listCIML = new List<SuspenseWrapper>();
                    }

                    listCIML.add(wrp);

                    totalCIML += insolPay.Payment_Amount__c;
                } else if (insolPay.Deposit_Account_Type__c == 'AFSI') {
                    listAFSI.add(wrp);
                    totalAFSI += insolPay.Payment_Amount__c;
                }

                listSuspWrap.add(wrp);
            }

            for (Unallocated_Payment__c unallo : [
                SELECT
                    Id,
                    Account_Number__c,
                    Unallocated_Amount__c,
                    Remittance__c,
                    Remittance__r.Trustee_Name__r.Name,
                    Remittance__r.Trustee_Name__c,
                    Remittance__r.Cheque_Payment_Reference_Number__c,
                    Remittance__r.Deposit_Account_Name__c
                FROM Unallocated_Payment__c
                WHERE
                    CreatedDate > :LastDepositSlipCreatedDate
                    AND remittance__c IN :listRemittanceID
                    AND remittance__r.recordtype.Developername = 'Insolvency_Dividend'
                    AND Allocated__c = FALSE
                    AND Is_Payment_Remitted__c = FALSE
                    AND Is_Payments_Reversed__c = NULL
                    ORDER BY remittance__r.Trustee_Name__r.name
            ]) {
                SuspenseWrapper wrp = new SuspenseWrapper();

                if (unallo.remittance__r.Deposit_Account_Name__c == 'CIML') {
                    depositAcc = depositAccountMap.get('CIML');

                    if (listCIML.size() == 999) {
                        listOfListCIML.add(listCIML);
                        listCIML = new List<SuspenseWrapper>();
                    }

                    listCIML.add(wrp);

                    totalCIML += unallo.Unallocated_Amount__c;
                }
                if (unallo.remittance__r.Deposit_Account_Name__c == 'AFSI') {
                    depositAcc = depositAccountMap.get('AFSI');

                    listAFSI.add(wrp);
                    totalAFSI += unallo.Unallocated_Amount__c;
                }
                wrp.accountName = (unallo.Account_Number__c == null ? '' : unallo.Account_Number__c) + ' - Unallocated';
                wrp.transit = depositAcc.Transit_Number__c;
                wrp.entity = depositAcc.Account_Name_on_Clearing_Account__c;
                wrp.bankAccountName = depositAcc.Account_Number__c;
                wrp.trustee = unallo.remittance__r.Trustee_Name__r.name + ' - ' + unallo.remittance__r.Cheque_Payment_Reference_Number__c;
                wrp.paymentAmount = unallo.Unallocated_Amount__c;
            }

            listOfListCIML.add(listCIML);
            listCIML = new List<SuspenseWrapper>();
        }
    }

    public class DepositWrapper {
        public String trusteeName { get; set; }
        public Decimal paymentAmount { get; set; }
    }
    public class SuspenseWrapper {
        public String accountName { get; set; }
        public String transit { get; set; }
        public String entity { get; set; }
        public String bankAccountName { get; set; }
        public String trustee { get; set; }
        public Decimal paymentAmount { get; set; }
    }
}
