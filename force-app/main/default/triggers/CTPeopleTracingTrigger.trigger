/**
 * Trigger : CTPeopleTracingTrigger
 * @auther Bhupendra
 * Last Modified By :
 * Last Modified Date :
 */

trigger CTPeopleTracingTrigger on People_Tracing__c (before insert) {

    switch on Trigger.operationType{
        when BEFORE_INSERT{
            //TODO: if duplicate found the throw error
            
            CTPeopleTracingTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }

}