public without sharing class OpportunityTriggerHandler {
    
    public static void checkPreventClosedWon(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        // handle Update list
        Map<Id, Opportunity> handleClosedWonUpdare = new Map<Id, Opportunity>();
        
        // for each Opportunity get all that changed to Closed Won
        for(Opportunity auxOpp : newMap.values()) {
            if(auxOpp.StageName != oldMap.get(auxOpp.Id).StageName && auxOpp.StageName == System.Label.OpportunityClosedWon){ 
                handleClosedWonUpdare.put(auxOpp.Id, auxOpp);
            }            
        }
        
        if(!handleClosedWonUpdare.isEmpty()) {
            // All Opportunity and Orders
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = [Select Id, (Select Id from Orders) from Opportunity where Id IN: handleClosedWonUpdare.keySet()];
            
            // Prevent update if has no orders
            for(Opportunity auxOpp : oppList) {
                if(auxOpp.Orders.size() == 0) {
                    newMap.get(auxOpp.Id).addError(System.Label.PreventOpportunityClosedWonChange);  
                }
            }
        }
    }
    
    public static void handleClosedWonUpdate(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
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
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = [Select id, AccountId, (Select Id, OpportunityId, Product2.Name, Quantity, UnitPrice, Has_subscription__c, Subscription_Percentage__c from OpportunityLineItems), (Select Id from Orders) from Opportunity where Id IN: opportunityMap.keySet()];
        
        // Iterate over each OpportunityLineItem and create an Asset for the Opportunity Account 
        if(!oppList.isEmpty()) {
            for(Opportunity auxOpp : oppList) {
                for(OpportunityLineItem auxOppLine : auxOpp.OpportunityLineItems) {
                    for(integer i=0; i < auxOppLine.Quantity; i++) {
                        // Build each asset
                        Asset currentAsset = new Asset();
                        currentAsset.Product2Id = auxOppLine.Product2Id;
                        currentAsset.Name = auxOppLine.Product2.Name;
                        currentAsset.Status = System.Label.AssetPurchased;
                        currentAsset.Price = auxOppLine.UnitPrice;
                        currentAsset.AccountId = auxOpp.AccountId;
                        currentAsset.Has_subscription__c = auxOppLine.Has_subscription__c;
                        currentAsset.PurchaseDate = system.today();
                        currentAsset.Quantity = 1;
                        
                        if(!auxOpp.orders.isEmpty())
                        currentAsset.Order__c = auxOpp.orders[0].Id;
                        
                        if(currentAsset.Has_subscription__c) {
                            currentAsset.Subscription_End_Date__c = Date.newInstance(system.Today().year()+1, system.Today().month(), system.Today().Day());
                            currentAsset.Subscription_Percentage__c = auxOppLine.Subscription_Percentage__c;
                        }
                            
                        assetListToInsert.add(currentAsset);  
                    }
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