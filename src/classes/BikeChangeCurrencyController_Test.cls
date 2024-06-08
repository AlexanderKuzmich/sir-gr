@IsTest
public with sharing class BikeChangeCurrencyController_Test {

    @TestSetup
    static void createCommonTestData() {
        TestDataFactory.setupSingleTestFreeCurrencyApiSetting('testApiKey', ConstantsClass.FREE_PLAN_KEY_STRING, true);
    }

    @IsTest
    static void getCurrentRateAndUpdateRecordPositiveTest1() {
        Bike__c testBike = TestDataFactory.setupSingleTestBike('Foxx Caiman', 1000, 'USD', true);
        TestDataFactory.setupSingleTestReplacementPart(testBike.Id, 'Test Part Name', 100, true);

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        BikeChangeCurrencyController.getCurrentRateAndUpdateRecord(testBike.Id, 'EUR');
        Test.stopTest();

        Bike__c updatedBike = [SELECT Id, Currency__c, Price__c FROM Bike__c WHERE Name = 'Foxx Caiman' LIMIT 1];

        System.assertEquals('EUR', updatedBike.Currency__c);
        System.assertEquals(925.17, updatedBike.Price__c.setScale(2));
    }

    @IsTest
    static void getCurrentRateAndUpdateRecordPositiveTest2() {
        Bike__c testBike = TestDataFactory.setupSingleTestBike('Foxx Caiman', 1000, 'EUR', true);
        TestDataFactory.setupSingleTestReplacementPart(testBike.Id, 'Test Part Name', 100, true);
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        BikeChangeCurrencyController.getCurrentRateAndUpdateRecord(testBike.Id, 'USD');
        Test.stopTest();

        Bike__c updatedBike = [SELECT Id, Currency__c, Price__c FROM Bike__c WHERE Name = 'Foxx Caiman' LIMIT 1];

        System.assertEquals('USD', updatedBike.Currency__c);
        System.assertEquals(1080.88, updatedBike.Price__c.setScale(2));
    }

    @IsTest
    static void getCurrentRateAndUpdateRecordPositiveTest3() {
        Bike__c testBike = TestDataFactory.setupSingleTestBike('Foxx Caiman', 1000, 'EUR', true);
        TestDataFactory.setupSingleTestReplacementPart(testBike.Id, 'Test Part Name', 100, true);
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        BikeChangeCurrencyController.getCurrentRateAndUpdateRecord(testBike.Id, 'SEK');
        Test.stopTest();

        Bike__c updatedBike = [SELECT Id, Currency__c, Price__c FROM Bike__c WHERE Name = 'Foxx Caiman' LIMIT 1];

        System.assertEquals('SEK', updatedBike.Currency__c);
        System.assertEquals(11382.72, updatedBike.Price__c.setScale(2));
    }

    @IsTest
    static void getCurrentRateAndUpdateRecordNegativeTest1() {
        Bike__c testBike = TestDataFactory.setupSingleTestBike('Foxx Caiman', 1000, 'EUR', true);
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        BikeChangeCurrencyController.getCurrentRateAndUpdateRecord(testBike.Id, 'PLN');
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM Error_Log__c].size());

    }

}