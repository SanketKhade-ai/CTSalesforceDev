public with sharing class CTPeopleTracingTriggerHandler {
    public static void handleBeforeInsert(List<People_Tracing__c> newList){
        if(newList.isEmpty()) return;
        Set<Id> people_1_TraceIds = new Set<Id>();
        Set<Id> people_2_TraceIds = new Set<Id>();

        for(People_Tracing__c pt : newList){
            people_1_TraceIds.add(pt.Person_1__c);
            people_2_TraceIds.add(pt.Person_2__c);
        }
        if(!people_1_TraceIds.isEmpty() || !people_2_TraceIds.isEmpty()){
            List<People_Tracing__c> duplicateRec = [SELECT  Person_1__c, Person_2__c 
                                                    FROM People_Tracing__c 
                                                    WHERE Person_1__c IN :people_1_TraceIds 
                                                    OR Person_2__c IN :people_2_TraceIds];
            for(People_Tracing__c pt : newList){
                for(People_Tracing__c dup : duplicateRec){
                    if(pt.Person_1__c.equals(dup.Person_1__c) && pt.Person_2__c.equals(dup.Person_2__c)){
                        pt.addError('Duplicate records are not allowed to insert');
                    }
                }
            }
        }
    }
}