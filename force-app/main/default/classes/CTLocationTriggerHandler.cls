public with sharing class CTLocationTriggerHandler {
    public static void handleBeforeInsert(List<Location__c> newList){
        if(newList.isEmpty()) return;
        for(Location__c loc : newList){
            loc.Status__c = 'Green';
        }
    }

    public static void handleBeforeUpdate(List<Location__c> newList, Map<Id, Location__c> oldMap){
        if(newList.isEmpty()) return;
        for(Location__c loc : newList){
            if(oldMap != Null){
                Location__c oldLocation = oldMap.get(loc.Id);
                if(loc.Status__c != oldLocation.Status__c){
                    loc.Status_Update_Date__c = Date.today();
                }
            }
        }
    }

    public static void handleAfterUpdate(List<Location__c> newList, Map<Id, Location__c> oldMap){
        if(newList.isEmpty()) return;
        Set<Id> locationIds = new Set<Id>();
        List<Person__c> personToUpdate = new List<Person__c>();
        for(Location__c loc : newList){
            if(oldMap != Null){
                Location__c oldLocation = oldMap.get(loc.Id);
                if(oldLocation.Status__c != 'Red' && loc.Status__c == 'Red'){
                    locationIds.add(loc.Id);
                }
            }
        }
        if(!locationIds.isEmpty()){
            List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByLocationId(locationIds);
            if(!locationTraces.isEmpty()){
                for(Location_Tracing__c lt : locationTraces){
                    personToUpdate.add(new Person__c(Id=lt.Person__c, Health_Status__c = 'Yellow'));
                }
                if(!personToUpdate.isEmpty()){
                    update personToUpdate;
                }
            }
        }
        
    }
}