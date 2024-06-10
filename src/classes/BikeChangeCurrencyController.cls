public without sharing class BikeChangeCurrencyController {

    @AuraEnabled
    public static List<SObject> getCurrentRateAndUpdateRecord(Id recordId, String currentCurrency) {

        List<SObject> recordsForUpdate = new List<SObject>();

        try {
            List<Free_Currency_Api_Settings__c> freeCurrencyApiSettingsList = [
                    SELECT Id, Api_Key__c
                    FROM Free_Currency_Api_Settings__c
                    WHERE Name = :ConstantsClass.FREE_PLAN_KEY_STRING
                    LIMIT 1
            ];

            List<Bike__c> bikeWithPartsList = [
                    SELECT Id, Price__c, Currency__c, (
                            SELECT Id, Price__c
                            FROM Replacement_Parts__r
                    )
                    FROM Bike__c
                    WHERE Id = :recordId FOR UPDATE
            ];

            if (freeCurrencyApiSettingsList.size() > 0 && bikeWithPartsList.size() > 0) {
                Bike__c bikeWithParts = bikeWithPartsList[0];
                String apiKey = freeCurrencyApiSettingsList[0].Api_Key__c;

                String endpoint = 'https://api.freecurrencyapi.com/v1/latest' +
                        '?apikey=' + apiKey +
                        '&currencies=EUR%2CUSD%2CSEK' +
                        '&base_currency=' + bikeWithParts.Currency__c;

                HttpResponse res = getCallout(endpoint);

                DataCurrencyWrapper currencies = (DataCurrencyWrapper) JSON.deserialize(res.getBody(), DataCurrencyWrapper.class);

                switch on currentCurrency {
                    when 'EUR' {
                        changeTheCurrencyOfRecords(bikeWithParts, currentCurrency, currencies.data.EUR, recordsForUpdate);
                    }
                    when 'USD' {
                        changeTheCurrencyOfRecords(bikeWithParts, currentCurrency, currencies.data.USD, recordsForUpdate);
                    }
                    when 'SEK' {
                        changeTheCurrencyOfRecords(bikeWithParts, currentCurrency, currencies.data.SEK, recordsForUpdate);
                    } when else {
                        insert new Error_Log__c(
                                Error_Description__c = ConstantsClass.BIKE_CURRENCY_CONTROLLER_STRING + ': ' +
                                        ConstantsClass.PLEASE_ADD_SUPPORT_CURRENCY_STRING
                        );
                    }
                }

                update recordsForUpdate;

            }
        } catch (Exception ex) {
            System.debug(ex);
            insert new Error_Log__c(
                    Error_Description__c = ConstantsClass.BIKE_CURRENCY_CONTROLLER_STRING + ': ' + ex.getMessage()
            );
            recordsForUpdate = new List<SObject>();
        }

        return recordsForUpdate;
    }

    private static void changeTheCurrencyOfRecords(Bike__c bikeForUpdate,
            String currentCurrency, Decimal exchangeRate, List<SObject> recordsForUpdate) {

        bikeForUpdate.Price__c *= exchangeRate;
        bikeForUpdate.Currency__c = currentCurrency;
        for (Replacement_Part__c eachRP : bikeForUpdate.Replacement_Parts__r) {
            eachRP.Price__c *= exchangeRate;
        }
        recordsForUpdate.add(bikeForUpdate);
        recordsForUpdate.addAll(bikeForUpdate.Replacement_Parts__r);
    }

    private static HttpResponse getCallout(String endpoint) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');

        Http http = new Http();

        return http.send(req);
    }


    private class DataCurrencyWrapper {
        public CurrencyWrapper data;
    }

    private class CurrencyWrapper {
        public Decimal SEK;
        public Decimal USD;
        public Decimal EUR;
    }
}