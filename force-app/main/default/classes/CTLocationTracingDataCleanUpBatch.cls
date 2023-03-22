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
public with sharing class CTLocationTracingDataCleanUpBatch implements Database.Batchable<SObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id FROM Location_Tracing__c WHERE Visit_Date__c < LAST_N_DAYS : 30');
    }

    //operating over records what getQueryLocator() will provide from above method
    public void execute(Database.BatchableContext bc, List<Location_Tracing__c> scope){
        delete scope;
    }

    public void finish(Database.BatchableContext bc){
        //System.debug('Batch is complete');
    }
}