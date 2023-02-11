/**
 * Class : CTPeopleTracingTriggerHandler
 * @auther Bhupendra
 * Last Modified By :
 * Last Modified Date :
 */

public with sharing class CTPeopleTracingTriggerHandler {
    
    public static void beforeInsertHandler(List<People_Tracing__c> newPeopleTraces){

        List<People_Tracing__c> duplicates = CTPeopleTracingController.checkDuplicate(newPeopleTraces);

        for(People_Tracing__c trace: duplicates){
            trace.addError('Duplicate record found. Person 1:'+trace.Person_1__c+' Person 2:'+trace.Person_2__c);
        }
    }
}