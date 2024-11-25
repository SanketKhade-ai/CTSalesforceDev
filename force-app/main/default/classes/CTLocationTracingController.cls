public with sharing class CTLocationTracingController {
    //Fetch Location Tracing by locationId
    public List<Location_Tracing__c> getVisitors(String locationId){
        if(locationId == null || String.isBlank(locationId)) return null;
        return [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, 
                Person__c, Location__c, Visit_Date__c 
                FROM Location_Tracing__c 
                WHERE Location__c = :locationId 
                ORDER BY Visit_Date__c DESC];
    }

    //Fetch Location Tracing by PersonId
    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> personIds){
        if(personIds == Null || personIds.isEmpty()) return null;
        return [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, 
                Person__c, Location__c, Visit_Date__c 
                FROM Location_Tracing__c 
                WHERE Person__c IN :personIds 
                AND Visit_Date__c = LAST_N_DAYS:10];
    }

    //Fetch Location Tracing by locationId
    public static List<Location_Tracing__c> getLocationsByLocationId(Set<Id> locationId){
        if(locationId == Null || locationId.isEmpty()) return null;
        Set<String> healthStatus = new Set<String>{'Yellow', 'Green'};
        return [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, 
                Person__c, Location__c, Visit_Date__c 
                FROM Location_Tracing__c 
                WHERE Location__c IN :locationId
                AND Visit_Date__c = LAST_N_DAYS:10 
                AND Person__r.Health_Status__c IN :healthStatus];
    }

    //Fetch Location Tracing by locationId
    public static List<Location_Tracing__c> getLocationsByLocationIds(Set<Id> locationIds){
        if(locationIds == Null || locationIds.isEmpty()) return null;
        return [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, 
                Person__c, Location__c, Visit_Date__c 
                FROM Location_Tracing__c 
                WHERE Location__c IN :locationIds AND Person__r.Health_Status__c = 'Green'
                AND Visit_Date__c = LAST_N_DAYS:10];
    }

    //Checking for duplicate records
    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> locationTraces){
        if(locationTraces == Null || locationTraces.isEmpty()) return null;
        List<Location_Tracing__c> duplicateLocationTracingRecords = new List<Location_Tracing__c>();
        Map<Id, Set<Id>> locationIdVsPersons = new Map<Id, Set<Id>>();
        Set<Id> locationIds = new set<Id>();
        Set<Id> personIds = new set<Id>();
        for(Location_Tracing__c lt : locationTraces){
            locationIds.add(lt.Location__c);
            personIds.add(lt.Person__c);
        }
        if(locationIds != Null &&  !personIds.isEmpty()){
            
            List<Location_Tracing__c> existingLocationTracingRecords = [SELECT Id, Location__c, Person__c 
                                                                        FROM Location_Tracing__c 
                                                                        WHERE Location__c IN :locationIds 
                                                                        AND Person__c IN :personIds];

            if(existingLocationTracingRecords != Null && existingLocationTracingRecords.size() > 0){
                
                for(Location_Tracing__c lt : existingLocationTracingRecords){
                    if(!locationIdVsPersons.containsKey(lt.Location__c)){
                        locationIdVsPersons.put(lt.Location__c, new Set<Id>());
                    }
                    locationIdVsPersons.get(lt.Location__c).add(lt.Person__c);
                }
                
                for(Location_Tracing__c lt : locationTraces){
                    if(locationIdVsPersons.containsKey(lt.Location__c) && locationIdVsPersons.get(lt.Location__c).contains(lt.Person__c)){
                        duplicateLocationTracingRecords.add(lt);
                    }
                }
            }
        }
        
        return duplicateLocationTracingRecords;
    }
}