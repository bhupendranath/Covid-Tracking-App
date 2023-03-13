public with sharing class CTLocationTabController {
     @AuraEnabled
    public static LocationInformation getLocationDetails(String locationId){

        //creating UserInformation instance
        LocationInformation info = new LocationInformation();

        //to return person
        Location__c location = CTLocationController.getLocationById(locationId);
        if(location != null){
            info.name = location.Name;
            info.redScore = Integer.valueOf(location.Red_Score__c);
            info.statusUpdateOn = location.Status_Update_Date__c;
            info.pinCode = location.Pincode__c;
            info.status = location.Status__c;
        }

        //to return people traces
        List<Location_Tracing__c> traces = CTLocationTracingController.getLocationById(locationId);
        if(traces != null && traces.size()>0){

            List<CloseContacts> closeContacts = new List<CloseContacts>();

            
            for(Location_Tracing__c trace : traces){
                CloseContacts cc = new CloseContacts();
                    cc.id = trace.Person__c;
                    cc.token = trace.Person__r.Token__c;
                    cc.visitDate = trace.Visit_Date__c;
                    cc.status = trace.Person__r.Health_Status__c;    
            

                closeContacts.add(cc);
            }

            //once we come out of loop we will assign this closeContacts list to UserInformation class
            //as UserInformation accepts List of contacts List<CloseContacts>
            info.contacts = closeContacts;
            info.contactsCount = closeContacts.size();
        }

        return info;
    }

    //Above Code we have 2 thing to return ('person' and 'traces'), but we can not return with  
    //single return method, in such scenario How we can combine these 2 and return it in 1 single statement
    //that we can do with "wrapper class"

    //this class covers user info. : 'person' and also [People traces info. : 'traces' withing the list >> that's how we combine 2 Wrapper Class]
    public class LocationInformation{
        @AuraEnabled public String name;
        @AuraEnabled public Integer redScore;
        @AuraEnabled public Date statusUpdateOn;
        @AuraEnabled public String pinCode;
        @AuraEnabled public String status;
        @AuraEnabled public Integer contactsCount = 0;
        @AuraEnabled public List<CloseContacts> contacts;
    }

    //this class covers People traces info. : 'traces'
    public class CloseContacts{
        //here we will only display Id, token, Contact date, Status. And we not suppose to share
        //sensitive info. such as name and mobile no
        @AuraEnabled public String id;
        @AuraEnabled public String token;
        @AuraEnabled public Date visitDate;
        @AuraEnabled public String status;
    }
}