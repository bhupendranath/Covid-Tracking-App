({
    createRecord : function(component, event, helper) {
        const createRecordEvent = $A.get("e.force:createRecord");

        //getting scope to get either Person Or Location obj
        const scope = component.get("v.scope");

        createRecordEvent.setParams({
            "entityApiName": scope === "person" ? "Person__c" : "Location__c"
        });
        createRecordEvent.fire();
    },

    doInit :  function(component, event, helper){
        helper.fetchStatusCount(component);
    },

    fetchCount : function(component, event, helper){
        //again calling fetchStatusCount helper method, which we have define in AURA Method
        //And we will call this fetch count in Parent controller after getting scope(person/loaction)
        helper.fetchStatusCount(component);
    }
});