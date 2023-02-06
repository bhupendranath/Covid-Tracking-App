/**
 * CTLocationTracingController
 * @auther Bhupendra
 * Last Modified By :
 * Last Modified Date :
 */

public with sharing class CTLocationTracingController {
    
    /**
     * get last 30 days visitors
     * @param locationId
     * @return List<Location__c>
     */
    public static List<Location_Tracing__c> getLocationById(String locationId){
        return [SELECT Id, Person__c, Location__c, Visit_Date__c, Person__r.Token__c, Person__r.Health_Status__c  FROM Location_Tracing__c 
                 WHERE Id =: locationId 
                 ORDER BY Visit_Date__c DESC NULLS LAST];
    }

    /**
     * get all location ids for visitors
     * @param personIds
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getLocationByPersonId(Set<Id> personIds){
        return [SELECT Id, Person__c, Location__c FROM Location_Tracing__c 
                 WHERE Person__c IN: personIds 
                 AND Visit_Date__c = LAST_N_DAYS:10];
    }

    /**
     * get all visitor ids for location
     * @param locationIds
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getLocationByLocationId(Set<Id> locationIds){
        return [SELECT Id, Person__c, Location__c, Person__r.Health_Status__c FROM Location_Tracing__c 
                WHERE Location__c IN: locationIds
                AND Person__r.Health_Status__c = 'Green'
                AND Visit_Date__c = LAST_N_DAYS:10];
    }

    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newlocationTraces){

        //store unique location Id
        Set<Id> locationIds = new Set<Id>();
        //store unique person Id
        Set<Id> personIds = new Set<Id>();

        for(Location_Tracing__c trace : newlocationTraces){
            locationIds.add(trace.Location__c);
            personIds.add(trace.Person__c);
        }

        //Map of location Id, Set of perosn Id
        Map<Id, Set<Id>> mapOfExistingRecord = new Map<Id, Set<Id>>();
        //Ex : Map<Location1, <Person1,Person2>>

        //query on existing location tracing record
        List<Location_Tracing__c> existingRecords = [SELECT Id, Person__c, Location__c, Person__r.Health_Status__c FROM Location_Tracing__c 
                                                     WHERE Location__c IN: locationIds
                                                     AND Person__c IN: personIds];

        //Blank list to add duplicates
        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();

        if(existingRecords != null && existingRecords.size()>0){
            for(Location_Tracing__c trace :existingRecords){

                if(!mapOfExistingRecord.containsKey(trace.Location__c)){
                    //if map doesn't have this key then add this in the 
                    //Map using location Id as Key
                    //and black set<Id> as value
                    mapOfExistingRecord.put(trace.Location__c, new Set<Id>()); //we got the map Id: <location Ids>, but value set is blank
                }

                //now we need to add Map Value : person records(Ids) in the set of Location Ids
                //add person Id to the map set
                mapOfExistingRecord.get(trace.Location__c).add(trace.Person__c);

            }

            //loop over new location tarcing records
            for(Location_Tracing__c trace :newlocationTraces){
                //first check for location id
                //if item found in map, then check for person id set
                if(mapOfExistingRecord.containsKey(trace.Location__c) 
                    && mapOfExistingRecord.get(trace.Location__c).contains(trace.Person__c)){
                        duplicates.add(trace);
                }
            }
        }

        return duplicates;
    }
    /*
    //Anonymouse Window Code for checkDuplicates
    //Here we are constructing Location_Tracing__c records
    //trace1,trace2 are duplicate and trace 3 is unique
    //Section 13 : Challenge 5
    Location_Tracing__c trace1 = new Location_Tracing__c(Person__c ='a035g00000D4enwAAB', Location__c = 'a015g00000rDDKGAA4');
    Location_Tracing__c trace2 = new Location_Tracing__c(Person__c ='a035g00000D4enqAAB', Location__c = 'a015g00000rDDKGAA4');
    Location_Tracing__c trace3 = new Location_Tracing__c(Person__c ='a035g00000D4enlAAB', Location__c = 'a015g00000rDDKGAA4');

    List<Location_Tracing__c> traces = new List<Location_Tracing__c>();
    traces.add(trace1);
    traces.add(trace2);
    traces.add(trace3);

    List<Location_Tracing__c> duplicates = CTLocationTracingController.checkDuplicates(traces);
    System.debug('Duplicates :'+duplicates);
    System.debug('Duplicates Size :'+duplicates.size());*/
}