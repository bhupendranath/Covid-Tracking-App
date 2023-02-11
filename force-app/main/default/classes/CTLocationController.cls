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

            healthCountMap.put(String.ValueOf(ar.get('Status__c')), Integer.ValueOf(ar.get('total')));
        }

        return healthCountMap;
    }
    //Anonymous Window code
    //Map<String, Integer> healthCountMap = CTLocationController.getStatusCount();
    //System.debug('Health Count Map'+healthCountMap);

    /**
     * update redscore using aggreagate funtion
     * COUNT(Id)total : totol person with Health_Status__c = 'Red' for respective location
     */
    public static void updateRedScore(Set<Id> locationIds){

        List<Location__c> locationToUpdate = new List<Location__c>();
        AggregateResult[] redPeoplePerLocation = [SELECT Location__c, COUNT(Id)total FROM Location_Tracing__c 
                                                  WHERE Person__r.Health_Status__c = 'Red' AND Visit_Date__c = LAST_N_DAYS:10 
                                                  AND Location__c IN: locationIds GROUP BY Location__c];
                                                  
        for(AggregateResult ar: redPeoplePerLocation){
            String locationId = String.valueOf(ar.get('Location__c'));
            Integer redScore = Integer.valueOf(ar.get('total'));
            String status = getStatus(redScore);
            locationToUpdate.add(new Location__c(Id=locationId, Red_Score__c=redScore, Status__c=status));
        }

        if(locationToUpdate != null && locationToUpdate.size()>0){
            update locationToUpdate;
        }
    }

    /**
     * to set the output base on redscore
     * 
     */
    public static String getStatus(Integer redScore){
        if(redScore == 0){
            return 'Green';
        }else if(redScore <= 5){
            return 'Yellow';
        }else if(redScore <= 10){
            return 'Orange';
        }else{
            return 'Red';
        }
    }

}