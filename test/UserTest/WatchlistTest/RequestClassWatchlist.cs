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
    
    public RestResponse PostRestRequest(string token, string Url, object body)
    {
        var baseUrl = Url;
        var Authenticator = new JwtAuthenticator(token);
        var options = new RestClientOptions(baseUrl) { Authenticator = Authenticator };
        RestClient client = new RestClient(options);
        
        RestRequest restRequest = new RestRequest(baseUrl, Method.Post);
        restRequest.AddBody(body, ContentType.Json); 
//
        RestResponse restResponse = client.Execute(restRequest);

        return restResponse;
    }

    public RestResponse DeleteRestRequest(string token, string urlDelete, object body)
    {
        var baseUrl = urlDelete;
        var Authenticator = new JwtAuthenticator(token);
        var options = new RestClientOptions(baseUrl) { Authenticator = Authenticator };
        RestClient client = new RestClient(options);

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

    public static object BuildBodyMovie(string userId)
    {
        return new WatchlistMovieSchema
        {
            UserId = userId,
            MovieId = "tt1596363"
        };
    }

    public static object BuildBodySeries(string userId)
    {
        return new WatchlistSeriesSchema
        {
            UserId = userId,
            SeriesId = "tt20877972"
        };
    }
}
