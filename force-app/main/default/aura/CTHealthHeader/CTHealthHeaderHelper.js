({
    fetchStatusCount : function(component) {
        //as best practice we should make apex method call from "helper" file not "controller"

        //getting scope to get either Person OR Location
        const scope = component.get("v.scope");

        let action = scope === "person" ? component.get("c.getPersonHealthStatusCount") : component.get("c.getLocationHealthStatusCount")

        action.setCallback(this, function(response){
            const state = response.getState();

            if(state === "SUCCESS"){
                //is state is success then we will put the output inside count attribute
                //and output we can get from response object with getReturnValue method
                component.set("v.count", response.getReturnValue())
            }
        });

        $A.enqueueAction(action);
    }
});