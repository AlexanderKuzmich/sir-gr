@IsTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HttpResponse respond(HttpRequest req) {

        String resBody = '';
        if (req.getMethod() == 'GET' && req.getEndpoint() == 'https://api.freecurrencyapi.com/v1/latest?apikey=testApiKey&currencies=EUR%2CUSD%2CSEK&base_currency=USD') {
            resBody = '{"data": {"EUR": 0.9251701273,"SEK": 10.5309517239,"USD": 1}}';
        }

        if (req.getMethod() == 'GET' && req.getEndpoint() == 'https://api.freecurrencyapi.com/v1/latest?apikey=testApiKey&currencies=EUR%2CUSD%2CSEK&base_currency=EUR') {
            resBody = '{"data": {"EUR": 1,"SEK": 11.3827191488,"USD": 1.0808822837}}';
        }

        if (req.getMethod() == 'GET' && req.getEndpoint() == 'https://api.freecurrencyapi.com/v1/latest?apikey=testApiKey&currencies=EUR%2CUSD%2CSEK&base_currency=SEK') {
            resBody = '{"data": {"EUR": 0.0878524707,"SEK": 1,"USD": 0.0949581791}}';
        }

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(resBody);
        res.setStatusCode(200);

        return res;
    }
}