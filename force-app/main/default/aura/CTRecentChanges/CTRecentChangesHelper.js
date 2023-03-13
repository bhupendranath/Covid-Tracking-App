({
    fetchRecentHealthChanges : function(component) {
        //now here we will be making call to server side function
        let action = component.get("v.scope") === "person" ? component.get("c.getRecentPersonHealthChanges") : component.get("c.getRecentLocationHealthChanges")

        action.setCallback(this, function(response){
            const state = response.getState();

            if(state === "SUCCESS"){
                //if state successful then we'll get the data from return value using response.getReturnValue()
                const data = response.getReturnValue();
                //then we are assigning this data to our "v.data" attribute
                component.set("v.data",data)

                component.set("v.initialResponse",data)
            }
        });

        $A.enqueueAction(action);
    },

    searchRecord : function(component, queryTerm){
        //now we will repeat same server side fun call as above JS function
        let action = component.get("v.scope") === "person" ? component.get("c.searchPeople") : component.get("c.searchLocation")

        //as function accepts params so we define setParams
        action.setParams({
            searchTerm : queryTerm
        });

        action.setCallback(this, function(response){
            const state = response.getState();

            if(state === "SUCCESS"){
                const data = response.getReturnValue();
                if(data && data.length >0){
                    component.set("v.data",data);
                }
                //once we get result from server then we make to false so that we can hide the spinner
                component.set("v.issearching", false);
            }
        });

        $A.enqueueAction(action);
    }
});