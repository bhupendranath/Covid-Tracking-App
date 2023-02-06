/**
 * CTPeopleTracingController
 * @auther Bhupendra
 * Last Modified By :
 * Last Modified Date :
 */

public with sharing class CTPeopleTracingController {
    
    public static List<People_Tracing__c> getTraces(String personId){
        return [SELECT Id, Name, Contact_Date__c, Contact_Type__c, Person_1__c,Person_1__r.Health_Status__c,Person_1__r.Token__c, Person_2__c,Person_2__r.Health_Status__c,Person_2__r.Token__c 
                FROM People_Tracing__c 
                WHERE Person_1__c =:personId 
                   OR Person_2__c =:personId 
                   ORDER BY Contact_Date__c DESC];
    }

    public static List<People_Tracing__c> checkDuplicate(List<People_Tracing__c> newPeopleTraces){

        //unique person Id
        Set<id> personIds = new Set<Id>();
        for(People_Tracing__c trace: newPeopleTraces){
            personIds.add(trace.Person_1__c);
            personIds.add(trace.Person_2__c);
        }

        //list of duplicate record
        List<People_Tracing__c> duplicates = new List<People_Tracing__c>();

        //Map<Person1, <Person2,person3>>
        Map<Id, Set<Id>> mapOfExistingRecord = new Map<Id, Set<Id>>();

        //Query existing record
        List<People_Tracing__c> existingRecords = [SELECT Id, Person_1__c, Person_2__c
                                                    FROM People_Tracing__c 
                                                    WHERE Person_1__c IN:personIds 
                                                    OR Person_2__c IN:personIds];
        
        //iterate over existingRecords to build map of existing record
        if(existingRecords!=null && existingRecords.size()>0){

            for(People_Tracing__c trace :existingRecords){

                //if Map id(Person1) not present then add in Key [build map for person1]
                //map has empty set
                if(!mapOfExistingRecord.containsKey(trace.Person_1__c)){
                    mapOfExistingRecord.put(trace.Person_1__c, new Set<Id>());
                }

                //add value(empty set) to Map
                mapOfExistingRecord.get(trace.Person_1__c).add(trace.Person_2__c);

                //if Map id(Person2) not present then add in Key [build map for person2]
                //map has empty set
                if(!mapOfExistingRecord.containsKey(trace.Person_2__c)){
                    mapOfExistingRecord.put(trace.Person_2__c, new Set<Id>());
                }

                //add value(empty set) to Map
                mapOfExistingRecord.get(trace.Person_2__c).add(trace.Person_1__c);
            }

            //loop over existing record to find duplicate
            for(People_Tracing__c trace: newPeopleTraces){

                //check for duplicate in map
                if(
                    (mapOfExistingRecord.containsKey(trace.Person_1__c) && mapOfExistingRecord.get(trace.Person_1__c).contains(trace.Person_1__c))
                    || 
                    (mapOfExistingRecord.containsKey(trace.Person_2__c) && mapOfExistingRecord.get(trace.Person_2__c).contains(trace.Person_1__c))
                  ){
                    duplicates.add(trace);
                  }
            }
        }

        return duplicates;
    }

    /*//Anonymous Window Code
    //Here we are constructing People_Tracing__c records
    //trace1,trace2 are duplicate and trace 3 is unique
    //Section 13 : Challenge 6
    People_Tracing__c trace1 = new People_Tracing__c(Person_1__c ='a035g00000D4enwAAB', Person_2__c = 'a035g00000D4envAAB');
    People_Tracing__c trace2 = new People_Tracing__c(Person_1__c ='a035g00000D4envAAB', Person_2__c = 'a035g00000D4enwAAB');
    People_Tracing__c trace3 = new People_Tracing__c(Person_1__c ='a035g00000D4envAAB', Person_2__c = 'a035g00000D4enwAAB');

    List<People_Tracing__c> traces = new List<People_Tracing__c>();
    traces.add(trace1);
    traces.add(trace2);
    traces.add(trace3);

    List<People_Tracing__c> duplicates = CTPeopleTracingController.checkDuplicate(traces);
    System.debug('Duplicates :'+duplicates);
    System.debug('Duplicates Size :'+duplicates.size());*/
    
}