/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a iterator class to send Notifications for Direct Payments to Portal
 *  @author : A5E Consulting
 *  @date : 12/07/2022
 
 *************************************************************************************************/
public class AggregateResultIterable implements Iterable<AggregateResult> {
  private String query;

  public AggregateResultIterable(String soql){
    query = soql;
  }

  public Iterator<AggregateResult> Iterator(){
    return new AggregateResultIterator(query);
  }
}