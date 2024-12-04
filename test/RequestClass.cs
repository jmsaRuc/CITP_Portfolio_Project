
using RestSharp;
using RestSharp.Authenticators;

namespace test;

public class RequestClass
{ 
    public RestResponse PostRestRequest(string Url, object body, string? token = null)
    {
        var baseUrl = Url;
        RestClient client = new RestClient(baseUrl);
        
        if (!string.IsNullOrEmpty(token))
            {
                var Authenticator = new JwtAuthenticator(token);
                var options = new RestClientOptions(baseUrl) { Authenticator = Authenticator };
                client = new RestClient(options);
            }

        
        RestRequest restRequest = new RestRequest(baseUrl, Method.Post);
        restRequest.AddBody(body, ContentType.Json); 
        RestResponse restResponse = client.Execute(restRequest);

        return restResponse;
    }

    public RestResponse GetRestRequest(string Url, string? token = null)
    {
        var baseUrl = Url;
        RestClient client = new RestClient(baseUrl);

        if (!string.IsNullOrEmpty(token))
            {
                var Authenticator = new JwtAuthenticator(token);
                var options = new RestClientOptions(baseUrl) { Authenticator = Authenticator };
                client = new RestClient(options);
            }

        RestRequest restRequest = new RestRequest(baseUrl, Method.Get);
        RestResponse restResponse = client.Execute(restRequest);

        return restResponse;
    }

    public RestResponse PutRestRequest(string Url, object body, string? token = null)
    {
        var baseUrl = Url;
        RestClient client = new RestClient(baseUrl);
        
        if (!string.IsNullOrEmpty(token))
            {
                var Authenticator = new JwtAuthenticator(token);
                var options = new RestClientOptions(baseUrl) { Authenticator = Authenticator };
                client = new RestClient(options);
            }

        
        RestRequest restRequest = new RestRequest(baseUrl, Method.Put);
        restRequest.AddBody(body, ContentType.Json);

        RestResponse restResponse = client.Execute(restRequest);


        return restResponse;
    }

    public RestResponse DeleteRestRequest(string urlDelete, object body, string? token = null)
    {
        var baseUrl = urlDelete;
        RestClient client = new RestClient(baseUrl);
        
        if (!string.IsNullOrEmpty(token))
            {
                var Authenticator = new JwtAuthenticator(token);
                var options = new RestClientOptions(baseUrl) { Authenticator = Authenticator };
                client = new RestClient(options);
            }


        RestRequest restRequest = new RestRequest(baseUrl, Method.Delete);
        restRequest.AddBody(body, ContentType.Json);

        RestResponse restResponse = client.Execute(restRequest);

        return restResponse;
    }
}
