/**
 * Class : CTLocationTracingTriggerHandler
 * @auther Bhupendra
 * Last Modified By :
 * Last Modified Date :
 */

public with sharing class CTLocationTracingTriggerHandler {
    
    public static void beforeInsertHandler(List<Location_Tracing__c> newLocationTraces){

        //getting duplicate from CTLocationTracingController class
        List<Location_Tracing__c> duplicates = CTLocationTracingController.checkDuplicates(newLocationTraces);

        for(Location_Tracing__c trace: duplicates){
            trace.addError('Duplicate record found. Person: '+trace.Person__c +' Location: '+trace.Location__c);
        }
    }
}