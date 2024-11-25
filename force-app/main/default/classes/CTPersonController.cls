public with sharing class CTPersonController {

    //Generate Hash token
    public static String getToken(String mobileNumber){
        //if(String.isBlank(mobileNumber)) return '';
        Blob inputString = Blob.valueOf(mobileNumber);
        Blob encryptMD5 = Crypto.generateDigest('MD5', inputString);
        String hashedString = EncodingUtil.base64Encode(encryptMD5);
        System.debug('MD5 Hashed String -> '+hashedString);
        return hashedString;
    }

    //fetch Recent Health Changes
    public static List<Person__c> getRecentHealthChanges(){
        return [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, 
                LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, 
                LastReferencedDate, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                FROM Person__c 
                ORDER BY Status_Update_Date__c 
                DESC 
                LIMIT 100];
    }

    //Search People
    public static List<Person__c> searchPeople(String searchTerm){
        if(searchTerm == Null || String.isBlank(searchTerm)) return null;
        searchTerm = searchTerm + '%';
        return [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, 
                LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, 
                LastReferencedDate, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                FROM Person__c 
                WHERE Name LIKE :searchTerm OR Mobile__c LIKE :searchTerm OR Token__c LIKE :searchTerm
                ORDER BY Status_Update_Date__c 
                DESC NULLS LAST];
    }

    //Fetch Person Record
    public static Person__c getPersonById(String personId){
        if(personId == Null || String.isBlank(personId)) return null;
        return [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, 
                LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, 
                LastReferencedDate, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                FROM Person__c 
                WHERE Id = :personId LIMIT 1];
    }

    //Fetch the Health Status Count
    public static Map<String, Integer> getHealthStatusCount(){
        List<AggregateResult> healthStatusList = [SELECT COUNT(Id) personIdCount, Health_Status__c personHealthStatus FROM Person__c GROUP BY Health_Status__c];
        Map<String, Integer> personIdVsHealthStatus = new Map<String, Integer>();
        if(healthStatusList.size() > 0){
            for(AggregateResult aggr : healthStatusList){
                personIdVsHealthStatus.put(String.valueOf(aggr.get('personHealthStatus')), Integer.valueOf(aggr.get('personIdCount')));
            }
        }
        return personIdVsHealthStatus;
    }

    //Fetch Cohabitants via personIds
    public static Set<Id> getCohabitant(Set<Id> personIds, Set<Id> alreadyProcessed){
        if(personIds.isEmpty()) return null;
        Set<String> healthStatusSet = new Set<String>{'Yellow', 'Green'};
        Set<Id> cohabitantList = new Set<Id>();
        List<People_Tracing__c> personTracingList = [SELECT Id, Person_1__c, Person_2__c 
                                                     FROM People_Tracing__c 
                                                     WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds) 
                                                     AND Contact_Type__c = 'Cohabitant' 
                                                     AND (Person_1__r.Health_Status__c IN :healthStatusSet OR Person_2__r.Health_Status__c IN :healthStatusSet)];
        
        if(!personTracingList.isEmpty()){
            for(People_Tracing__c pt : personTracingList){
                if(!alreadyProcessed.contains(pt.Person_1__c)){
                    cohabitantList.add(pt.Person_1__c);
                    alreadyProcessed.add(pt.Person_1__c);
                }
                if(!alreadyProcessed.contains(pt.Person_2__c)){
                    cohabitantList.add(pt.Person_2__c);
                    alreadyProcessed.add(pt.Person_2__c);
                }
            }
        }
        return cohabitantList;
    }

    //Fetch Neighbours via personIds
    public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessed){
        if(personIds.isEmpty()) return null;
        Set<String> healthStatusSet = new Set<String>{'Green'};
        Set<Id> neighboursList = new Set<Id>();
        List<People_Tracing__c> personTracingList = [SELECT Id, Person_1__c, Person_2__c 
                                                     FROM People_Tracing__c 
                                                     WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds) 
                                                     AND Contact_Type__c = 'Neighbours' 
                                                     AND (Person_1__r.Health_Status__c IN :healthStatusSet OR Person_2__r.Health_Status__c IN :healthStatusSet)];
        
        if(!personTracingList.isEmpty()){
            for(People_Tracing__c pt : personTracingList){
                if(!alreadyProcessed.contains(pt.Person_1__c)){
                    neighboursList.add(pt.Person_1__c);
                    alreadyProcessed.add(pt.Person_1__c);
                }
                if(!alreadyProcessed.contains(pt.Person_2__c)){
                    neighboursList.add(pt.Person_2__c);
                    alreadyProcessed.add(pt.Person_2__c);
                }
            }
        }
        return neighboursList;
    }

    //Fetch Primary Contact via personIds
    public static Set<Id> getPrimaryContact(Set<Id> personIds, Set<Id> alreadyProcessed){
        if(personIds.isEmpty()) return null;
        Set<String> healthStatusSet = new Set<String>{'Yellow','Green'};
        Set<Id> primaryContactList = new Set<Id>();
        List<People_Tracing__c> personTracingList = [SELECT Id, Person_1__c, Person_2__c 
                                                     FROM People_Tracing__c 
                                                     WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds) 
                                                     AND Contact_Type__c = 'Other' 
                                                     AND (Person_1__r.Health_Status__c IN :healthStatusSet OR Person_2__r.Health_Status__c IN :healthStatusSet)];
        
        if(!personTracingList.isEmpty()){
            for(People_Tracing__c pt : personTracingList){
                if(!alreadyProcessed.contains(pt.Person_1__c)){
                    primaryContactList.add(pt.Person_1__c);
                    alreadyProcessed.add(pt.Person_1__c);
                }
                if(!alreadyProcessed.contains(pt.Person_2__c)){
                    primaryContactList.add(pt.Person_2__c);
                    alreadyProcessed.add(pt.Person_2__c);
                }
            }
        }
        return primaryContactList;
    }

    //Fetch Secondary Contact via personIds
    public static Set<Id> getSecondaryContact(Set<Id> primaryContactIds, Set<Id> alreadyProcessed){
        if(primaryContactIds.isEmpty()) return null;
        Set<String> healthStatusSet = new Set<String>{'Yellow','Green'};
        Set<Id> secondContactList = new Set<Id>();
        List<People_Tracing__c> personTracingList = [SELECT Id, Person_1__c, Person_2__c 
                                                     FROM People_Tracing__c 
                                                     WHERE (Person_1__c IN :primaryContactIds OR Person_2__c IN :primaryContactIds) 
                                                     AND Contact_Type__c = 'Other' 
                                                     AND (Person_1__r.Health_Status__c IN :healthStatusSet OR Person_2__r.Health_Status__c IN :healthStatusSet)];
        
        if(!personTracingList.isEmpty()){
            for(People_Tracing__c pt : personTracingList){
                if(!alreadyProcessed.contains(pt.Person_1__c)){
                    secondContactList.add(pt.Person_1__c);
                    alreadyProcessed.add(pt.Person_1__c);
                }
                if(!alreadyProcessed.contains(pt.Person_2__c)){
                    secondContactList.add(pt.Person_2__c);
                    alreadyProcessed.add(pt.Person_2__c);
                }
            }
        }
        return secondContactList;
    }
}