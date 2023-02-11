/**
 * Trigger : CTLocationTrigger
 * @auther Bhupendra
 * Last Modified By :
 * Last Modified Date :
 */

trigger CTLocationTrigger on Location__c (before insert, before update, after update) {

    switch on Trigger.operationType{
        when BEFORE_INSERT{
            //todo: location status is green before insertion

            CTLocationTriggerHandler.beforeInsertHandler(Trigger.new);
        }
        when BEFORE_UPDATE{
            //todo: if location status changes update status update date to TODAY()

            CTLocationTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        when AFTER_UPDATE{
            //todo: if location status changes to 'Red' mark all people yellow
            //who visited that location on last 10 days

            CTLocationTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}