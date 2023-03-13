public with sharing class CTPersonTabController {
    @AuraEnabled
    public static UserInformation getPersonDetails(String personId){

        //creating UserInformation instance
        UserInformation info = new UserInformation();

        //to return person
        Person__c person = CTPersonController.getPersonById(personId);
        if(person != null){
            info.name = person.Name;
            info.token = person.Token__c;
            info.statusUpdateOn = person.Status_Update_Date__c;
            info.phone = person.Mobile__c;
            info.status = person.Health_Status__c;
        }

        //to return people traces
        List<People_Tracing__c> traces = CTPeopleTracingController.getTraces(personId);
        if(traces != null && traces.size()>0){

            List<CloseContacts> closeContacts = new List<CloseContacts>();

            //generating set to get unique person id, as person will be stored in Person_1__c OR Person_2__c
            Set<Id> uniqueIds = new Set<Id>();
            uniqueIds.add(personId);
            
            for(People_Tracing__c trace : traces){
                CloseContacts cc = new CloseContacts();
                if(!uniqueIds.contains(trace.Person_1__c)){
                    cc.id = trace.Person_1__c;
                    cc.status = trace.Person_1__r.Health_Status__c;
                    cc.token = trace.Person_1__r.Token__c;
                    cc.contactDate = trace.Contact_Date__c;
                }
                if(!uniqueIds.contains(trace.Person_2__c)){
                    cc.id = trace.Person_2__c;
                    cc.status = trace.Person_2__r.Health_Status__c;
                    cc.token = trace.Person_2__r.Token__c;
                    cc.contactDate = trace.Contact_Date__c;
                }

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
    public class UserInformation{
        @AuraEnabled public String name;
        @AuraEnabled public String token;
        @AuraEnabled public Date statusUpdateOn;
        @AuraEnabled public String phone;
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
        @AuraEnabled public Date contactDate;
        @AuraEnabled public String status;
    }
}