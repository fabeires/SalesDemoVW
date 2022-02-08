public without sharing class OpportunityLineItemTriggerHandler {
    
    public static void adjustLineItem(List<OpportunityLineItem> oppLineItemList) {
        
        // for each line item adjust unit price based on subscription percentage
        for(OpportunityLineItem auxOppLine : oppLineItemList) {
            
            // calculate percentage and set Unit Price
            if(auxOppLine.Has_subscription__c && auxOppLine.Subscription_Percentage__c != null){
                Decimal subscriptionPercentage = (Decimal.valueOf(auxOppLine.Subscription_Percentage__c)/100);               
                auxOppLine.UnitPrice = auxOppLine.UnitPrice + (auxOppLine.UnitPrice * subscriptionPercentage);  
            }
            
            // set Subscription_Percentage__c to 0
            else if(!auxOppLine.Has_subscription__c) {
                auxOppLine.Subscription_Percentage__c = '0';
            }
        }
    }
    
    public static void adjustLineItemOnUpdate(List<OpportunityLineItem> oppLineItemList, Map<Id, OpportunityLineItem> oldMap) {
        
        // for each line item adjust unit price based on subscription percentage
        for(OpportunityLineItem auxOppLine : oppLineItemList) {
            
            // calculate percentage and set Unit Price
            if(!auxOppLine.Has_subscription__c){ 
                auxOppLine.Subscription_Percentage__c = '0';            
            }
            
            if(oldMap.get(auxOppLine.Id).UnitPrice != auxOppLine.UnitPrice) {
                Decimal subscriptionPercentage = (Decimal.valueOf(auxOppLine.Subscription_Percentage__c)/100);               
                auxOppLine.UnitPrice = auxOppLine.UnitPrice + (auxOppLine.UnitPrice * subscriptionPercentage);  
            }
            else if(oldMap.get(auxOppLine.Id).Subscription_Percentage__c != auxOppLine.Subscription_Percentage__c || oldMap.get(auxOppLine.Id).Has_subscription__c != auxOppLine.Has_subscription__c) {
                
                Decimal oldSubscriptionPercentage = (Decimal.valueOf(oldMap.get(auxOppLine.Id).Subscription_Percentage__c)/100);
                Decimal subscriptionPercentage = (Decimal.valueOf(auxOppLine.Subscription_Percentage__c)/100);
                
                Decimal currentUnitPrice = auxOppLine.UnitPrice / (1 + oldSubscriptionPercentage);  
                auxOppLine.UnitPrice = currentUnitPrice + (currentUnitPrice * subscriptionPercentage);  
            }                
        }
    }
}