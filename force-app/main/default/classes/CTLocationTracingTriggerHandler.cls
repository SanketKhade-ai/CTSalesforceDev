public with sharing class CTLocationTracingTriggerHandler {
    public static void handleBeforeInsert(List<Location_Tracing__c> newList){
        if(newList.isEmpty()) return;
        Set<Id> locationId = new Set<Id>();
        Set<Id> personId = new Set<Id>();
        for(Location_Tracing__c lt : newList){
            if(lt.Location__c != Null)
            {
                locationId.add(lt.Location__c);
            }
            if(lt.Person__c != Null)
            {
                personId.add(lt.Person__c);
            }
        }
        if(!locationId.isEmpty() && !personId.isEmpty()){
            List<Location_Tracing__c> dupliLocaTrace = [SELECT Id, Location__c, Person__c 
                                                        FROM Location_Tracing__c 
                                                        WHERE Location__c IN :locationId 
                                                        AND Person__c IN :personId];
            if(!dupliLocaTrace.isEmpty()){
                for(Location_Tracing__c locTrace : newList){
                    for(Location_Tracing__c dlt : dupliLocaTrace){
                        if(dlt.Location__c.equals(locTrace.Location__c) && dlt.Person__c.equals(locTrace.Person__c)){
                            locTrace.addError('Duplicate Record!!');
                        }
                    }
                }
            }
        }
    }
}