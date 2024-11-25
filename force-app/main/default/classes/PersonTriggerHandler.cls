public with sharing class PersonTriggerHandler {
    public static void handleBeforeInsert(List<Person__c> newList){
        if(newList.isEmpty()) return;
        for(Person__c person : newList){
            person.Health_Status__c = 'Green';
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
        }
    }

    public static void handleBeforeUpdate(List<Person__c> newList, Map<Id, Person__c> oldMap){
        if(newList.isEmpty()) return;
        for(Person__c person : newList){
            if(oldMap != Null){
                Person__c oldPerson = oldMap.get(person.Id);
                if(oldPerson.Health_Status__c != person.Health_Status__c){
                    person.Status_Update_Date__c = Date.today();
                }
            }
        }
    }

    public static void handleAfterUpdate(List<Person__c> newList, Map<Id, Person__c> oldMap){
        if(newList.isEmpty()) return;
        Set<Id> statusChanged = new Set<Id>();
        Set<Id> redStatus = new Set<Id>();
        Set<Id> alreadyProcessed = new Set<Id>();
        Set<Id> orangeStatus = new Set<Id>();
        Set<Id> yellowStatus = new Set<Id>();
        Set<Id> locationIds = new Set<Id>();
        List<Person__c> personToUpdate = new List<Person__c>();
        for(Person__c person : newList){
            Person__c oldPerson = oldMap.get(person.Id);
            if(oldPerson.Health_Status__c != person.Health_Status__c){
                statusChanged.add(person.Id);
            }
            if(person.Health_Status__c.equals('Red') && oldPerson.Health_Status__c != 'Red'){
                redStatus.add(person.Id);
            }
        }
        if(!redStatus.isEmpty()){
            alreadyProcessed.addAll(redStatus);
            orangeStatus.addAll(CTPersonController.getCohabitant(redStatus, alreadyProcessed));
            orangeStatus.addAll(CTPersonController.getPrimaryContact(redStatus, alreadyProcessed));
            yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, alreadyProcessed));
            yellowStatus.addAll(CTPersonController.getSecondaryContact(redStatus, alreadyProcessed));
        }

        if(!orangeStatus.isEmpty()){
            for(Id orange : orangeStatus){
                personToUpdate.add(new Person__c(Id=orange, Health_Status__c = 'Orange'));
            }
        }
        if(!yellowStatus.isEmpty()){
            for(Id yellow : yellowStatus){
                personToUpdate.add(new Person__c(Id=yellow, Health_Status__c = 'Yellow'));
            }
        }
        if(!personToUpdate.isEmpty())
        {
            update personToUpdate;
        }

        if(!statusChanged.isEmpty()){
            List<Location_Tracing__c> locationTrace = CTLocationTracingController.getLocationsByPersonIds(statusChanged);
            if(!locationTrace.isEmpty()){
                for(Location_Tracing__c lt : locationTrace){
                    locationIds.add(lt.Location__c);
                }
                CTLocationController.updateRedScoreByLocation(locationIds);
            }
        }
    }
        
}