/**************************************************************************************************
 *
 *  Class:    InsolvencyViewController
 *
 *  @description : Allow team to inline edit insolvency
 *  @author : A5E Consulting
 *  @date : 07/20/2020
 
 *************************************************************************************************/
public class InsolvencyViewController {
    public Boolean inlineEdit {get;set;}
    
    public InsolvencyViewController (ApexPages.StandardController controller){
        if(InsolvencyUtil.isCommunityUser()){
            inlineEdit = False;
        }
        else{
            inlineEdit = True;
        }
        system.debug('inlineEdit: '+inlineEdit);
    }
}