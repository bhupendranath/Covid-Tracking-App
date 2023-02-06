/**
 * CTLocationController
 * @auther Bhupendra
 * Last Modified By :
 * Last Modified Date :
 */
 

public with sharing class CTLocationController {
    
    /**
     * get recent Location heath changes
     * @return List<Location__c>
     */
    public static List<Location__c> getRecentStatusChanges(){
        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c FROM Location__c 
                ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    /**
     * Serach Location by Name,Pincode and Address
     * @return List<Person__c>
     */
    public static List<Location__c> searchLocation(String searchTerm){

        searchTerm = searchTerm + '%';
        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c FROM Location__c 
                WHERE Name Like: searchTerm OR Pincode__c Like: searchTerm OR Address__c Like: searchTerm 
                ORDER BY Status_Update_Date__c DESC NULLS LAST];
    }

    /**
     * Serach Location by Id
     * @return Person__c
     */
    public static Location__c getLocationById(String locationId){

        List<Location__c> location = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c FROM Location__c
                                      WHERE Id =:locationId];
        if(location !=null && location.size()>0){
            return location[0];
        }
        return null;
    }

    /**
     * get count of location in each health status
     * @return Map<Health_Status__c, LocationIds>
     */
    public static Map<String, Integer> getStatusCount(){
        Map<String, Integer> healthCountMap = new Map<String, Integer>();

        for(AggregateResult ar : [SELECT Status__c, COUNT(Id) total FROM Location__c GROUP BY Status__c]){

            healthCountMap.put(String.ValueOf(ar.get('Status')), Integer.ValueOf(ar.get('total')));
        }

        return healthCountMap;
    }
    //Anonymous Window code
    //Map<String, Integer> healthCountMap = CTPersonController.getHealthStatusCount();
    //System.debug('Health Count Map'+healthCountMap);

}