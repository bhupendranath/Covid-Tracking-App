/**
 * CTPersonController
 * @auther Bhupendra
 * Last Modified By :
 * Last Modified Date :
 */
 

public with sharing class CTPersonController {
    
    /**
     * Generate Unique Token using MobileNo
     * Use MD5 Algo to generate one-way hash
     * @param mobileNo
     * @return String token
     */
    public static string getToken(String mobileNo){
        Blob value = Blob.ValueOf(mobileNo); //getting blob value of mobile no.
        Blob hash = Crypto.generateDigest('MD5', value); //generating hash from above blob(value) object

        //get the string value valoe of hash blob
        return EncodingUtil.base64Encode(hash);
    }

    /**
     * Anonymous wondow code for getTokenMethod
     * String Mobile = '8894372628';
     * String token = CTPersonController.getToket(Mobile);
     * System.debug('Mobile Token :'+token);
     */
    
    /**
     * get recent heath changes
     * @return List<Person__c>
     */
    public static List<Person__c> getRecentHealthChanges(){
        return [SELECT Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c, Name, Id FROM Person__c 
                ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    /**
     * Serach Person by Name,Mobile and Token
     * @return List<Person__c>
     */
    public static List<Person__c> searchPeople(String searchTerm){
        searchTerm = searchTerm + '%'; //this way we can append wild card to our searchTerm
        return [SELECT Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c, Name, Id FROM Person__c 
                WHERE Name Like :searchTerm OR Mobile__c Like :searchTerm OR Token__c Like :searchTerm 
                ORDER BY Status_Update_Date__c DESC NULLS LAST];
    }

    /**
     * Serach Person by Id
     * @return Person__c
     */
    public static Person__c getPersonById(String personId){
        List<Person__c> people = [SELECT Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c, Name, Id FROM Person__c
                WHERE Id =:personId];
        if(people != null && people.size()>0){
            return people[0];
        }
        return null;
    }

    /**
     * get count of people in each health status
     * @return Map<Health_Status__c, PersonIds>
     */

    public static Map<String, Integer>  getHealthStatusCount(){

        Map<String, Integer> healthCountMap = new Map<String, Integer>();
        for(AggregateResult ar : [SELECT Health_Status__c,COUNT(Id) total 
                                   FROM Person__c GROUP BY Health_Status__c]){
            
            //COUNT(Id) total : total is alias for COUNT(Id)
            //Below Typecasting values to String and Integer
            String healthStatus = String.valueOf(ar.get('Health_Status__c'));
            Integer count = Integer.valueOf(ar.get('total'));
            healthCountMap.put(healthStatus,count);
        }

        return healthCountMap;
    }
    //Anonymous Window code
    //Map<String, Integer> healthCountMap = CTPersonController.getHealthStatusCount();
    //System.debug('Health Count Map'+healthCountMap);

    /**
     * get all the cohabitants of a person
     * which returns set of Ids of all cohabitants
     * @return Set<Id>
     * @param Set<Ids> for which we need to find cohabitants
     */
    public static Set<Id> getCohabitants(Set<Id> personIds, Set<Id> alreadyProcessed){

        List<String> healthstatuses = new List<String>{'Green','Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                                 WHERE (Person_1__c IN: personIds OR Person_2__c IN: personIds) 
                                                 AND Contact_Type__c = 'Cohabitant'
                                                 AND (Person_1__r.Health_Status__c IN: healthstatuses 
                                                      OR Person_2__r.Health_Status__c IN: healthstatuses)];

        Set<Id> cohabitants = new Set<Id>();
        for(People_Tracing__c pt: peopleTraces){
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                cohabitants.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if(!personIds.contains(pt.Person_2__c)){
                cohabitants.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }

        return cohabitants;
    }

    /**
     * get all the neighbours of a person
     * which returns set of Ids of all neighbours
     * @return Set<Id>
     * @param Set<Ids> for which we need to find neighbours
     */
    public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessed){

        //List<String> healthstatuses = new List<String>{'Green','Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                                 WHERE (Person_1__c IN: personIds OR Person_2__c IN: personIds) 
                                                 AND Contact_Type__c = 'Neighbour'
                                                 AND (Person_1__r.Health_Status__c = 'Green'
                                                      OR Person_2__r.Health_Status__c ='Green')];

        Set<Id> neighbours = new Set<Id>();
        for(People_Tracing__c pt: peopleTraces){
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                neighbours.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if(!personIds.contains(pt.Person_2__c)){
                neighbours.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }

        return neighbours;
    }

    /**
     * get all the primary contacts of a person
     * which returns set of Ids of all primary contacts
     * @return Set<Id>
     * @param Set<Ids> for which we need to find primary contacts
     */
    public static Set<Id> getPrimaryContacts(Set<Id> personIds, Set<Id> alreadyProcessed){

        List<String> healthstatuses = new List<String>{'Green','Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                                 WHERE (Person_1__c IN: personIds OR Person_2__c IN: personIds) 
                                                 AND Contact_Type__c = 'Other'
                                                 AND Contact_Date__c = LAST_N_DAYS:10
                                                 AND (Person_1__r.Health_Status__c IN: healthstatuses
                                                      OR Person_2__r.Health_Status__c IN: healthstatuses)];

        Set<Id> primaryContacts = new Set<Id>();
        for(People_Tracing__c pt: peopleTraces){
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                primaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if(!personIds.contains(pt.Person_2__c)){
                primaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }

        return primaryContacts;
    }

    /**
     * get all the secondary contacts of a person
     * which returns set of Ids of all secondary contacts
     * @return Set<Id>
     * @param Set<Ids> for which we need to find secondary contacts
     */
    public static Set<Id> getSecondaryContacts(Set<Id> primaryContactIds, Set<Id> alreadyProcessed){

        List<String> healthstatuses = new List<String>{'Green','Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                                 WHERE (Person_1__c IN: primaryContactIds OR Person_2__c IN: primaryContactIds) 
                                                 AND Contact_Type__c = 'Other'
                                                 AND Contact_Date__c = LAST_N_DAYS:10
                                                 AND (Person_1__r.Health_Status__c IN: healthstatuses
                                                      OR Person_2__r.Health_Status__c IN: healthstatuses)];

        Set<Id> secondaryContacts = new Set<Id>();
        for(People_Tracing__c pt: peopleTraces){
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                secondaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if(!primaryContactIds.contains(pt.Person_2__c)){
                secondaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
