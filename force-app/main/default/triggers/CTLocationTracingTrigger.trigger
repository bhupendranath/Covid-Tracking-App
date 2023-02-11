/**
 * Trigger : CTLocationTracingTrigger
 * @auther Bhupendra
 * Last Modified By :
 * Last Modified Date :
 */

trigger CTLocationTracingTrigger on Location_Tracing__c (before insert) {

    switch on Trigger.operationType{
        when BEFORE_INSERT{
            //todo: if duplicate record found then throw error

            CTLocationTracingTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }

}