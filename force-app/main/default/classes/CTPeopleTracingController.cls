public with sharing class CTPeopleTracingController {
    //People tracing records by recordId
    public static List<People_Tracing__c> getTraces(String recordId){
        if(recordId == null || String.isBlank(recordId)) return null;
        return [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                        LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, 
                        Contact_Type__c, Contact_Date__c, Person_1__c, Person_2__c 
                FROM People_Tracing__c 
                WHERE Person_1__c = :recordId OR Person_2__c = :recordId
                ORDER BY Contact_Date__c DESC];
    }

    //Get Duplicates Records
    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> peopleTraces){
        if(peopleTraces == null || peopleTraces.size() <= 0) return null;
        set<Id> personIds = new Set<Id>();
        Map<Id, Set<Id>> peopleTracingIdVsPersons = new Map<Id, Set<Id>>();
        List<People_Tracing__c> duplicateRecords = new List<People_Tracing__c>();
        for(People_Tracing__c pt : peopleTraces){
            personIds.add(pt.Person_1__c);
            personIds.add(pt.Person_2__c);
        }
        
        List<People_Tracing__c> existingRecords = [SELECT Id, Person_1__c, Person_2__c 
                                                    FROM People_Tracing__c 
                                                    WHERE Person_1__c IN :personIds OR Person_2__c IN :personIds];
        if(existingRecords != Null && existingRecords.size() > 0){
            for(People_Tracing__c pt : existingRecords){
                if(!peopleTracingIdVsPersons.containsKey(pt.Id)){
                    peopleTracingIdVsPersons.put(pt.Id, new Set<Id>());
                }
                if(!peopleTracingIdVsPersons.get(pt.Id).contains(pt.Person_1__c)){
                    peopleTracingIdVsPersons.get(pt.Id).add(pt.Person_1__c);
                }
                if(!peopleTracingIdVsPersons.get(pt.Id).contains(pt.Person_2__c)){
                    peopleTracingIdVsPersons.get(pt.Id).add(pt.Person_2__c);
                }
            }
        }
        for(People_Tracing__c pt : peopleTraces){
            if(peopleTracingIdVsPersons.containsKey(pt.Id) && peopleTracingIdVsPersons.get(pt.Id).contains(pt.Person_1__c) 
                                                           && peopleTracingIdVsPersons.get(pt.Id).contains(pt.Person_2__c)){
                duplicateRecords.add(pt);
            }
        }
        return duplicateRecords;
    }
}