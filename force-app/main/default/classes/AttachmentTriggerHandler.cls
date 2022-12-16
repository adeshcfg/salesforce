/**************************************************************************************************
*
*  Trigger:   
*
*  @description : This is a Trigger Handler Class for Attachment object 
*  @author : A5E Consulting
*  @date : 10/06/2016
* 
*************************************************************************************************/

public class AttachmentTriggerHandler{
    
    //Handle Befor Delete
    public static void handleBeforeDelete(List<Attachment> oldList){
        
        Profile profileInfo = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() limit 1];
        
        //Loan re-engineering
        if('System Administrator' != profileInfo.Name && 'CFG - Application Admin' != profileInfo.Name ){
            for(Attachment attach : oldList){
                if (attach.ParentId != null){
                    if(attach.ParentId.getSObjectType() == Application__C.sObjectType || 
                       attach.ParentId.getSObjectType() == Product__c.sObjectType ||
                       attach.ParentId.getSObjectType() == Funding_Batch__c.sObjectType ||
                       attach.ParentId.getSObjectType() == Deposit_Slip__c.sObjectType){
                           attach.ParentId.addError('You can not delete an Attachment from Application, Product and Funding Batch Records');
                       }
                }
            }
        }
        
        //Payment Processing
        if('System Administrator' != profileInfo.Name){
            for(Attachment attach : oldList){
                if (attach.ParentId != null){
                    if(attach.ParentId.getSObjectType() == Deposit_Slip__c.sObjectType){
                           attach.ParentId.addError('You can not delete an Attachment from Deposit Slip Records');
                       }
                }
            }
        }
        //Loan re-engineering
        if('System Administrator' != profileInfo.Name){
            for(Attachment attach : oldList){
                if (attach.ParentId != null){
                    if(attach.ParentId.getSObjectType() == Unallocated_Payment__c.sObjectType){
                           attach.ParentId.addError('You can not delete an Attachment from Unallocated Payment Records');
                       }
                }
            }
        }
        
        /*
        //Scotia Forward Flow
        Boolean isCommunityUser = false;
        if(profileInfo.Name.contains('Community User')){
            isCommunityUser = true;
        }        
        //Community user can't delete attachment
        if(isCommunityUser){
            for(Attachment attach : oldList){
                if (attach.ParentId != null){
                    if(attach.ParentId.getSObjectType() == Insolvency_Account__c.sObjectType){
                        attach.ParentId.addError('Sorry, you can\'t remove an attached document; contact Canaccede for more information, or if you require assistance with this action');
                    }
                }
            }
        }
        */
    }
    
    //Handle Befor Update
    public static void handleBeforeEdit(List<Attachment> newList){
        
        Profile profileInfo = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() limit 1];
        if('System Administrator' != profileInfo.Name && 'CFG - Application Admin' != profileInfo.Name ){
            for(Attachment attach : newList){
                if (attach.ParentId != null){
                    if(attach.ParentId.getSObjectType() == Funding_Batch__c.sObjectType ){
                           attach.ParentId.addError('You can not edit an Attachment from Funding Batch Records');
                       }
                }
            }
        }
    }
    
    //After Attachment is Deleted
    public static void handleAfterDelete(List<Attachment> oldList) {
        List<Task> activities = new List<Task>();
        
        for(Attachment attach : oldList){
            if (attach.ParentId != null){
                if(attach.ParentId.getSObjectType() == Insolvency_Account__c.sObjectType || attach.ParentId.getSObjectType() == Insolvency__c.sObjectType){
                    Task activity = new Task();
                    activity.Subject = 'Deleted-'+attach.Name;
                    activity.WhatId = attach.ParentId;
                    activity.Status = 'Completed';
                    activities.add(activity);
                }
            }
        }
        
        if(activities.size() > 0){
            insert activities;
        }
    }
}