/**
 * Class : CTLocationTriggerHandler
 * @auther Bhupendra
 * Last Modified By :
 * Last Modified Date :
 */

public with sharing class CTLocationTriggerHandler {
    
    public static void beforeInsertHandler(List<Location__c> newLocations){
        //todo: location status is green before insertion

        for(Location__c location: newLocations){
            location.Status__c = 'Green';
        }
    }

    public static void beforeUpdateHandler(List<Location__c> newLocations, Map<Id, Location__c> oldLocationMap){

        for(Location__c location: newLocations){
            //check if the status change in this transaction
            //then update Status_Update_Date__c
            if(location.Status__c != oldLocationMap.get(location.Id).Status__c){
                location.Status_Update_Date__c = Date.TODAY();
            }
        }
    }

    public static void afterUpdateHandler(List<Location__c> newLocations, Map<Id, Location__c> oldLocationMap){

        Set<Id> statusUpdate = new Set<Id>();
        for(Location__c location:newLocations){
            //check if the status changed to Red
            //then update people status to Yellow who visited the location in last 10 days
            if(location.Status__c == 'Red' && oldLocationMap.get(location.Id).Status__c != 'Red'){
                statusUpdate.add(location.Id);
            }
        }

        //getting all the visitors/People by location Id from CTLocationTracingController Class
        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationByLocationId(statusUpdate);

        Set<Id> personId = new Set<Id>();
        for(Location_Tracing__c trace: locationTraces){
            //get person Id
            personId.add(trace.Person__c);
        }

        //create list of person record to update
        List<Person__c> personToUpdate = new List<Person__c>();
        for(Id pid: personId){
            personToUpdate.add(new Person__c(Id=pid, Health_Status__c='Yellow'));
        }

        if(personToUpdate.size()>0){
            update personToUpdate;  
        }
    }
}