public with sharing class CTLocationController {
    //Fetch Location upto 100 Records.
    public static List<Location__c> getRecentStatusChanges(){
        return[SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Status__c, 
                Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c 
                FROM Location__c 
                ORDER BY Status_Update_Date__c DESC 
                LIMIT 100];
    } 

    //Fetch Location By Search Term
    public static List<Location__c> searchLocations(String searchTerm){
        if(searchTerm == null || String.isBlank(searchTerm)) return null;
        searchTerm = searchTerm + '%';
        return [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Status__c, 
                Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c 
                FROM Location__c 
                WHERE Name LIKE :searchTerm OR Pincode__c LIKE :searchTerm OR Address__c LIKE :searchTerm
                ORDER BY Status_Update_Date__c DESC NULLS LAST];
    }

    //Fetch location by Id 
    public static Location__c getLocationById(String locationId){
        if(locationId == null || String.isBlank(locationId)) return null;
        return [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Status__c, 
                Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c 
                FROM Location__c 
                WHERE Id = :locationId LIMIT 1 ];
    }

    public static Map<String, Integer> getStatusCount(){
        Map<String, Integer> locationIdVsStatus = new Map<String, Integer>();
        for(AggregateResult aggr : [SELECT COUNT(Id) locationIdCount, Status__c locationStatus FROM Location__c GROUP BY Status__c]){
            locationIdVsStatus.put(String.valueOf(aggr.get('locationStatus')), Integer.valueOf(aggr.get('locationIdCount')));
        }
        return locationIdVsStatus;
    }

    public static void updateRedScoreByLocation(Set<Id> locationIds){
        if(locationIds.isEmpty()) return;
        List<Location__c> locationToUpdate = new List<Location__c>();
        for(AggregateResult agr : [SELECT COUNT(Id) total, Location__c loc 
                                    FROM Location_Tracing__c 
                                    WHERE Person__r.Health_Status__c = 'Red' AND Visit_Date__c = LAST_N_DAYS:10 GROUP BY Location__c]){
                String location = String.valueOf(agr.get('loc'));
                Integer redScore = Integer.valueOf(agr.get('total'));
                String status = setRedScore(redScore);
                locationToUpdate.add(new Location__c(Id=location, Red_Score__c=redScore, Status__c=status));

        }
        if(!locationToUpdate.isEmpty()){
            update locationToUpdate;
        }
    }

    public static String setRedScore(Integer redScore){
        if(redScore == 0){
            return 'Green';
        }
        if(redScore <= 5){
            return 'Yellow';
        }
        if(redScore <= 10){
            return 'Orange';
        }
        else{
            return 'Red';
        }
    }
}