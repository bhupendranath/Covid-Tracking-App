({
    tabSelectHandler : function(component, event, helper) {
        const selectedTabId = event.getParam("id");
        if(selectedTabId === 'person'){
            component.set("v.headerTitle", "Person View");
        }else{
            component.set("v.headerTitle", "Location View");
        }
        //setting scope
        component.set("v.scope", selectedTabId);

        //calling child comp aura method by setting aura:id in parent comp
        const healthHeaderComp = component.find("health-header");

        //on this child comp 'healthHeaderComp' we need to call aura method 'fetchCount'
        healthHeaderComp.fetchCount();
    }
});