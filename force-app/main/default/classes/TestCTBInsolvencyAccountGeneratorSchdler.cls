@isTest
public class TestCTBInsolvencyAccountGeneratorSchdler {
@isTest
    static void testMethod1(){
       test.startTest();
        CTBInsolvencyAccountGeneratorScheduler ctb=new CTBInsolvencyAccountGeneratorScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test CTB Check', sch, ctb); 
        Test.stopTest(); 
    }
}