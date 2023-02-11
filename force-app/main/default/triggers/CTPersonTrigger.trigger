/**
 * Trigger : CTPersonTrigger
 * @auther Bhupendra
 * Last Modified By :
 * Last Modified Date :
 */

trigger CTPersonTrigger on Person__c (before insert, after insert, before update, after update,
                                                    before delete, after delete, after undelete) {

  switch on Trigger.operationType{
    when BEFORE_INSERT{
        //todo: update health status to green
        //todo: generate unique token for person record
        
        CTPersonTriggerHandler.beforeInsertHandler(Trigger.new);
    }
    when BEFORE_UPDATE{
        //todo: is status changes then update Status_Update_Date__c to today
        
        CTPersonTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
    }
    when AFTER_UPDATE{
        CTPersonTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
    }
  }                                                      
}