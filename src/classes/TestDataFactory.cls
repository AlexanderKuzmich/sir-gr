public inherited sharing class TestDataFactory {

    public static Bike__c setupSingleTestBike(String bikeName, Decimal bikePrice, String bikeCurrency, Boolean isInsert) {
        Bike__c testBike = new Bike__c(Name = bikeName, Price__c = bikePrice, Currency__c = bikeCurrency);
        if (isInsert) {
            insert testBike;
        }
        return testBike;
    }

    public static Replacement_Part__c setupSingleTestReplacementPart(Id bikeId, String partName, Decimal partPrice, Boolean isInsert) {
        Replacement_Part__c testRP = new Replacement_Part__c(Name = partName, Price__c = partPrice, Bike__c = bikeId);
        if (isInsert) {
            insert testRP;
        }
        return testRP;
    }

    public static Free_Currency_Api_Settings__c setupSingleTestFreeCurrencyApiSetting(String apiKey, String name, Boolean isInsert) {
        Free_Currency_Api_Settings__c testSettings = new Free_Currency_Api_Settings__c(Name = name, Api_Key__c = apiKey);
        if (isInsert) {
            insert testSettings;
        }
        return testSettings;
    }
}