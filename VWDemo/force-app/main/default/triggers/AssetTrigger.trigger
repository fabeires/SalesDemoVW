trigger AssetTrigger on Asset (after insert) {
    // After logic
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            
            // Get more data into Asset record
            AssetTriggerHandler.handleAfterInsert(Trigger.new);
        }
    }
}