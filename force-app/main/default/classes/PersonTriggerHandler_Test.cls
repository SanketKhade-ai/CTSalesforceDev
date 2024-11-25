@isTest public with sharing class PersonTriggerHandler_Test {
    @TestSetup
    public static void testSetupMethod(){
        List<Person__c> personList = new List<Person__c>();
        personList.add(new Person__c(Name = 'testData1', Mobile__c = '9867868766'));
        personList.add(new Person__c(Name = 'testData2', Mobile__c = '9867868767'));
        personList.add(new Person__c(Name = 'testData3', Mobile__c = '9867868768'));
        personList.add(new Person__c(Name = 'testData4', Mobile__c = '9867868769'));
        personList.add(new Person__c(Name = 'testData5', Mobile__c = '9867868760'));

        insert personList;

        List<Location__c> locations = new List<Location__c>();
        locations.add(new Location__c(Name = 'testLocation1', Address__c = 'abcde', Pincode__c = '400001'));
        locations.add(new Location__c(Name = 'testLocation2', Address__c = 'abcded', Pincode__c = '400011'));
        locations.add(new Location__c(Name = 'testLocation3', Address__c = 'abcdefg', Pincode__c = '400021'));
        locations.add(new Location__c(Name = 'testLocation4', Address__c = 'abcdefgh', Pincode__c = '400031'));
        locations.add(new Location__c(Name = 'testLocation5', Address__c = 'abcdefgj', Pincode__c = '400041'));

        insert locations;

        List<People_Tracing__c> peopleTrace = new List<People_Tracing__c>();
        peopleTrace.add(new People_Tracing__c(Person_1__c = personList[0].Id, Person_2__c = personList[1].Id, Contact_Date__c = Date.Today()-4, Contact_Type__c = 'Cohabitant'));
        peopleTrace.add(new People_Tracing__c(Person_1__c = personList[1].Id, Person_2__c = personList[2].Id, Contact_Date__c = Date.Today()-2, Contact_Type__c = 'Neighbour'));
        peopleTrace.add(new People_Tracing__c(Person_1__c = personList[2].Id, Person_2__c = personList[3].Id, Contact_Date__c = Date.Today()-5, Contact_Type__c = 'Neighbour'));
        peopleTrace.add(new People_Tracing__c(Person_1__c = personList[0].Id, Person_2__c = personList[3].Id, Contact_Date__c = Date.Today()-7, Contact_Type__c = 'Other'));

        insert peopleTrace;

        List<Location_Tracing__c> locaTrace = new List<Location_Tracing__c>();
        locaTrace.add(new Location_Tracing__c(Person__c = personList[0].Id, Location__c = locations[0].Id, Visit_Date__c = Date.Today()-4));
        locaTrace.add(new Location_Tracing__c(Person__c = personList[1].Id, Location__c = locations[1].Id, Visit_Date__c = Date.Today()-10));
        locaTrace.add(new Location_Tracing__c(Person__c = personList[2].Id, Location__c = locations[2].Id, Visit_Date__c = Date.Today()-6));
        locaTrace.add(new Location_Tracing__c(Person__c = personList[3].Id, Location__c = locations[3].Id, Visit_Date__c = Date.Today()-7));
        locaTrace.add(new Location_Tracing__c(Person__c = personList[4].Id, Location__c = locations[4].Id, Visit_Date__c = Date.Today()-10));

        insert locaTrace;
    }

    @isTest public static void test_PersonTriggerHandler(){
        Test.startTest();
        Person__c person1 = new Person__c(Name = 'testData', Mobile__c = '9867868866');
        person1.Health_Status__c = 'Green';
        insert person1;
        List<Person__c> person2 = [SELECT Id, Name, Mobile__c, Health_Status__c FROM Person__c WHERE Name = 'testData2'];
        person2[0].Health_Status__c = 'Red';
        update person2;
        List<Person__c> person3 = [SELECT Id, Name, Mobile__c, Health_Status__c FROM Person__c WHERE Name = 'testData3'];
        person3[0].Health_Status__c = 'Orange';
        update person3;
        person3[0].Health_Status__c = 'Green';
        update person3;
        Test.stopTest();
    }
}