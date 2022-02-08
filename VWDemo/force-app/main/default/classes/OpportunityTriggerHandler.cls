public without sharing class OpportunityTriggerHandler {
    
    public static void handleAfterUpdate(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        // handleAssetCreation list
        Map<Id, Opportunity> handleAssetCreationMap = new Map<Id, Opportunity>();
        
        // for each Opportunity get all that changed to Closed Won
        for(Opportunity auxOpp : newMap.values()) {
            if(auxOpp.StageName != oldMap.get(auxOpp.Id).StageName && auxOpp.StageName == System.Label.OpportunityClosedWon){ 
                handleAssetCreationMap.put(auxOpp.Id, auxOpp);
            }            
        }
        
        // if any, call handleAssetCreation
        if(!handleAssetCreationMap.isEmpty()) {
            handleAssetCreation(handleAssetCreationMap);
        }
    }
    
    public static void handleAssetCreation(Map<Id, Opportunity> opportunityMap) {
        // Asset List to create
        List<Asset> assetListToInsert = new List<Asset>();
        
        // All OpportunityLineItem of the CLosed won Opportunities
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        oppLineItemList = [Select Id, OpportunityId, Opportunity.AccountId, Product2.Name, Quantity, UnitPrice, Has_subscription__c from OpportunityLineItem where OpportunityId IN: opportunityMap.keySet()];
        
        // Iterate over each OpportunityLineItem and create an Asset for the Opportunity Account 
        if(!oppLineItemList.isEmpty()) {
            for(OpportunityLineItem auxOppLine : oppLineItemList) {
                
                for(integer i=0; i<auxOppLine.Quantity; i++) {
                    // Build each asset
                    Asset currentAsset = new Asset();
                    currentAsset.Product2Id = auxOppLine.Product2Id;
                    currentAsset.Name = auxOppLine.Product2.Name;
                    currentAsset.Status = System.Label.AssetPurchased;
                    currentAsset.Price = auxOppLine.UnitPrice;
                    currentAsset.AccountId = auxOppLine.Opportunity.AccountId;
                    currentAsset.Has_subscription__c = auxOppLine.Has_subscription__c;
                    currentAsset.PurchaseDate = system.today();
                    currentAsset.Quantity = 1;
                    if(currentAsset.Has_subscription__c)
                    currentAsset.Subscription_End_Date__c = Date.newInstance(system.Today().year()+1, system.Today().month(), system.Today().Day());
                    assetListToInsert.add(currentAsset);  
                } 
            }
            
            // Insert list
            try{
                insert assetListToInsert;
            }
            catch(Exception e) {
                system.debug('OpportunityTriggerHandler handleAssetCreation : ' + e.getMessage());
            }
        }  
    }
}