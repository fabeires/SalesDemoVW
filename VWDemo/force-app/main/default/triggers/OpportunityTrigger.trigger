trigger OpportunityTrigger on Opportunity (after update) {
    
    // After Logic
    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            OpportunityTriggerHandler.checkPreventClosedWon(Trigger.newMap, Trigger.oldMap);
            OpportunityTriggerHandler.handleClosedWonUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}