public with sharing class CTHealthHeaderController {
    
    //Map<String, Integer> : String=>Store health status, Integer=>store count of people in that perticular health status
    @AuraEnabled
    public static Map<String, Integer> getPersonHealthStatusCount(){
        return CTPersonController.getHealthStatusCountAura();
    }

    @AuraEnabled
    public static Map<String, Integer> getLocationHealthStatusCount(){
        return CTLocationController.getLocationStatusCount();
    }
}