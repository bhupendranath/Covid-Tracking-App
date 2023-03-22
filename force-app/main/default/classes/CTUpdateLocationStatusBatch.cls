/**
 * @description       : Batch Class for Data Cleanup
 * @auther            : Bhupendra
 * @group             : 
 * @last modified on  : 03-22-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-22-2023   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class CTUpdateLocationStatusBatch implements Database.Batchable<SObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc){

        List<String> statuses = new List<String>{'Red','Orange','Yellow'};

        //to calculate exact past 14 days before date : LAST_N_DAYS : 14 won't work here
        Date today = Date.Today();
        Date fourteenDaysAgo = today - 14;
        return Database.getQueryLocator('SELECT Id, Status__c FROM Location__c WHERE Status_Update_Date__c =: fourteenDaysAgo AND Health_Status__c IN: statuses');

        //Here, != operator will always harm/slowdown query performance, hence we have use above list
        //SELECT Id, Status__c FROM Location__c WHERE Status_Update_Date__c =: fourteenDaysAgo AND Status__c != 'Green'
    }

    //operating over records what getQueryLocator() will provide from above method
    public void execute(Database.BatchableContext bc, List<Location__c> scope){
        for(Location__c location: scope){
            location.Status__c = 'Green';
        }

        update scope;
    }

    public void finish(Database.BatchableContext bc){
        //System.debug('Batch is complete');
    }
}
