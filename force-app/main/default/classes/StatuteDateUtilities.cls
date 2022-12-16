public class StatuteDateUtilities {
	// Statute Date MAP loaded from metadata
    public static Map<String, Statute_Date_Update__mdt>  statuteDateInfoMap;

    // Fetching and updating Statute Date values from metadata to a static variable
    public static void loadStatuteDataFromMetadata(){
        statuteDateInfoMap = new Map<String, Statute_Date_Update__mdt>();

        // Iterate and push statute date values to a map
        for(Statute_Date_Update__mdt m :[SELECT Id, MasterLabel, Months__c FROM Statute_Date_Update__mdt]){
            statuteDateInfoMap.put(m.MasterLabel, m);
        }
    }
    
    // Read and return value from Statute Date Map variable
    // *** Note call  'loadStatuteDataFromMetadata' method should be invoked before calling this method */
    // 
      public static Date getStatueDate(Date lastpaymentDate,Date Opendate,Date ChargeoffDate,Date StatueDate,String State){
       
          Date SBC; //Date Variable to be used for Staute date Calculation
          system.debug('****lastpaymentDate=' + lastpaymentDate);
          system.debug('****ChargeoffDate=' + ChargeoffDate);
          system.debug('****StatueDatee=' + StatueDate);
          
          if(lastpaymentDate != null){ // If LastPaymentDate is Not Blank
                 SBC = lastpaymentDate;
             }
          else if(Opendate != null){ // If LastPaymentDate is  Blank and Open Date is not Blank 
                 SBC=OpenDate;
             }
          else if(ChargeoffDate != null){ // If Open Date is Blank and ChargeoffDate is Not Blank
                 SBC=ChargeoffDate;
             }
           //If Both are Null return Null
          if(SBC == null && StatueDate == null){
              return null;
          }
           //Checking if new filed used to calculate is blank/Null and StatueDate is not blank return current Satute Date
          if(SBC == null && StatueDate != null){
              return StatueDate;
          }
         
           // Checking if Current Statute Date is not blank 
           // and is less than new updated date on which Statute Date is calculated  then no changes are required
          if(SBC != null &&           
             StatueDate != null && SBC > StatueDate){
              return StatueDate;
          }
         
       	system.debug('****State=' + State);
        system.debug('****SBC=' + SBC);
          //If State is Manitoba 
        if(State=='Manitoba' || State=='MB'){
           
            date chgDate = date.newInstance(2022, 9, 30); //Date from when Manitoba Changes StatuteDate Logic from 7 Years to 2 years
            date capDate = date.newInstance(2024, 9, 30); //Cap Date Which is set for StatuteDate calculation  
            system.debug('LastpaymentDate='+ SBC);
            
            if(SBC<=chgDate){// If Last Payment Date is < Sept-30-2022
                StatueDate = SBC.addMonths(72); 
                system.debug('StatuteDate if lastpayment date is before 30 Sep 2022'+ StatueDate);
                if(StatueDate>=capDate){      // If Last Payment Date is < Sept-30-2022, use old logic but cap it at Sept-20-2024
                    StatueDate = capDate;
                }
            }else{
                system.debug('statuteDateInfoMap'+statuteDateInfoMap);
                 if(statuteDateInfoMap.containsKey(State)){
                	Integer i= Integer.valueof(statuteDateInfoMap.get(State).Months__c);
                   	StatueDate = SBC.addMonths(i);
            	}     
            }
            
        }
        else{ //If State is Not Manitoba
             if(statuteDateInfoMap.containsKey(State)){
                Integer i= Integer.valueof(statuteDateInfoMap.get(State).Months__c);
    
                StatueDate = SBC.addMonths(i);
            }   
        }
        system.debug('StatuteDate '+ StatueDate);
        return StatueDate;
    }

}
    /*
     * Old Function
     * public static Date getStatueDate(Date lastpaymentDate,Date Opendate,Date SBC,Date StatueDate,String State){
       //If State is Manitoba 
       system.debug('State=' + State);
        if(State=='Manitoba' || State=='MB'){
           
            date chgDate = date.newInstance(2022, 9, 30); //Date from when Manitoba Changes StatuteDate Logic from 7 Years to 2 years
            date capDate = date.newInstance(2024, 9, 30); //Cap Date Which is set for StatuteDate calculation  
            system.debug('LastpaymentDate='+ lastpaymentDate);
            
            if(lastpaymentDate<=chgDate){// If Last Payment Date is < Sept-30-2022
                StatueDate = SBC.addMonths(72); 
                system.debug('StatuteDate if lastpayment date is before 30 Sep 2022'+ StatueDate);
                if(StatueDate>=capDate){      // If Last Payment Date is < Sept-30-2022, use old logic but cap it at Sept-20-2024
                    StatueDate = capDate;
                }
            }else{
                system.debug('statuteDateInfoMap'+statuteDateInfoMap);
                 if(statuteDateInfoMap.containsKey(State)){
                	Integer i= Integer.valueof(statuteDateInfoMap.get(State).Months__c);
                   	StatueDate = SBC.addMonths(i);
            	}     
            }
            
        }
        else{ //If State is Not Manitoba
             if(statuteDateInfoMap.containsKey(State)){
                Integer i= Integer.valueof(statuteDateInfoMap.get(State).Months__c);
    
                StatueDate = SBC.addMonths(i);
            }   
        }
         system.debug('StatuteDate '+ StatueDate);
        return StatueDate;
    }
*/