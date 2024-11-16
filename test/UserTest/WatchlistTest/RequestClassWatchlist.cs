using System;
using OMGdbApi.Models;
using RestSharp;
using Xunit.Sdk;
using RestSharp.Authenticators;
using System.Text.Json;
namespace test.UserTest.WatchlistTest;

public class RequestClassWatchlist
{   
    private readonly WatchlistEpisodeSchema watchlistEpisode = new();
    public RestResponse GetRestRequest(string token, string UserId, string baseUrl)
    {   

        var Url = baseUrl;

        var Authenticator = new JwtAuthenticator(token);
        var options = new RestClientOptions(Url) { Authenticator = Authenticator };
        RestClient client = new RestClient(options);

        RestRequest restRequest = new RestRequest(baseUrl, Method.Get);
        RestResponse restResponse = client.Execute(restRequest);

        return restResponse;
    }

    public RestResponse PostRestRequest(string token, string Url, string UserId)
    {
        var baseUrl = Url;
        var Authenticator = new JwtAuthenticator(token);
        var options = new RestClientOptions(baseUrl) { Authenticator = Authenticator };
        RestClient client = new RestClient(options);
        var body  = (WatchlistEpisodeSchema)BuildBodyEpisode(UserId);
        RestRequest restRequest = new RestRequest(baseUrl, Method.Post);
        restRequest.AddBody(body, ContentType.Json); 
//
        RestResponse restResponse = client.Execute(restRequest);

        return restResponse;
    }

    public RestResponse DeleteRestRequest(string token, string urlDelete, string UserId)
    {
        var baseUrl = urlDelete;
        var Authenticator = new JwtAuthenticator(token);
        var options = new RestClientOptions(baseUrl) { Authenticator = Authenticator };
        RestClient client = new RestClient(options);
        var body = (WatchlistEpisodeSchema)BuildBodyEpisode(UserId);
        RestRequest restRequest = new RestRequest(baseUrl, Method.Delete);
        restRequest.AddBody(body, ContentType.Json);

        RestResponse restResponse = client.Execute(restRequest);

        return restResponse;
    }


 public static object BuildBodyEpisode(string userId)
 {
     return new WatchlistEpisodeSchema
     {
         UserId = userId,
         EpisodeId = "tt0959621"    
     };
 }
}
