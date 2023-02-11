/**
 * Class : CTPersonTriggerHandler
 * @auther Bhupendra
 * Last Modified By :
 * Last Modified Date :
 */

public with sharing class CTPersonTriggerHandler {
    
    public static void beforeInsertHandler(List<Person__c> newPersons){
        //before insert operation for Person__c obj
        //make sure Health Status is 'Green'
        //And generate unique token for each record

        for(Person__c person: newPersons){
            //update status to green
            person.Health_Status__c = 'Green';
            //generate unique token 
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
        }
    }

    //Before update operation for Person__c obj
    public static void beforeUpdateHandler(List<Person__c> newPersonRecords, Map<Id, Person__c> oldPersonMap){
        for(Person__c person : newPersonRecords){
            //check if the status change in this transaction
            //then update Status_Update_Date__c
            if(person.Health_Status__c != oldPersonMap.get(person.Id).Health_Status__c){
                person.Status_Update_Date__c = Date.TODAY();
            }
        }
    }

    //After update operation for Person__c obj
    public static void afterUpdateHandler(List<Person__c> newPersonRecords, Map<Id, Person__c> oldPersonMap){
        
        Set<Id> statusChange = new Set<Id>(); //to store Ids of person where Health_Status__c changed
        Set<Id> redStatus = new Set<Id>();    //to store Ids of person where person new Health_Status__c is 'Red'
        for(Person__c person : newPersonRecords){
            //check if the status change in this transaction
            //then update Status_Update_Date__c
            if(person.Health_Status__c != oldPersonMap.get(person.Id).Health_Status__c){
                statusChange.add(person.Id);
            }
            if(person.Health_Status__c != 'Red' && oldPersonMap.get(person.Id).Health_Status__c != 'Red'){
                redStatus.add(person.Id);
            }
        }

        //to ignore duplicate processing : 185
        Set<Id> alreadyProcessed = new Set<Id>();
        alreadyProcessed.addAll(redStatus);

        Set<Id> orangeStatus = new Set<Id>();
        Set<Id> yellowStatus = new Set<Id>();

        List<Person__c> personToUpdate = new List<Person__c>();

        //we should always keep high vulnerable method at top, hence OrangeStatus will be called first
        //so that we can avoid marking person as yellow instead of orange : 186
        //lets add cohabitant
        orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, alreadyProcessed));
        //lets add primary contact
        Set<Id> primaryContacts = CTPersonController.getPrimaryContacts(redStatus, alreadyProcessed);
        orangeStatus.addAll(primaryContacts);

        //lets add neighbour
        yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, alreadyProcessed));
        
        //lets add secondary contact
        //to get secondary contact we should pass output of premary contact
        yellowStatus.addAll(CTPersonController.getSecondaryContacts(primaryContacts, alreadyProcessed));

        for(Id pid : orangeStatus){
            personToUpdate.add(new Person__c(Id=pid, Health_Status__c ='Orange'));
        }
        for(Id pid : yellowStatus){
            personToUpdate.add(new Person__c(Id=pid, Health_Status__c ='Yellow'));
        }

        if(personToUpdate.size()>0){
            update personToUpdate;
        }

        //to get all status change of persons using Location_Tracing__c obj :188
        //in this way we can get location Id
        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationByPersonId(statusChange);
        if(locationTraces != null && locationTraces.size()>0){
            Set<Id> locationIds = new Set<Id>();

            for(Location_Tracing__c trace: locationTraces){
                locationIds.add(trace.Location__c);
            }
            CTLocationController.updateRedScore(locationIds);
        }
    }
}