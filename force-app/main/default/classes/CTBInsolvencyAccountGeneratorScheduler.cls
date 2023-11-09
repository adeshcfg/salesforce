/**************************************************************************************************
*  Class:   
*  @description : This class can be call CTB automation batch class based on parameter.
*  @author : A5E Consulting
*  @date : 07/11/2023

*************************************************************************************************/
public class CTBInsolvencyAccountGeneratorScheduler implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new CTBFileGenerator(System.Label.CTB_Insolvency_Account), 200);
    }
}