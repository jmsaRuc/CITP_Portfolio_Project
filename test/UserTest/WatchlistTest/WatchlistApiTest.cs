using System.Net;
using System.Text.Json;
using RestSharp;
using Xunit.Abstractions;
using test;

namespace test.UserTest.WatchlistTest;

public class WatchlistApiTest
{
    private readonly ITestOutputHelper _testOutputHelper;

    private readonly UserApiTests userApiTests;

    public WatchlistApiTest(ITestOutputHelper testOutputHelper)
    {
        _testOutputHelper = testOutputHelper;
        userApiTests = new(_testOutputHelper);
    }

    readonly RequestClass request = new();

    ///////////////////////////////////////////////watchlist/episode///////////////////////////////////////////////

    [Fact]
    public void Test1_CreateWatchlistEpisode()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        //create watchlist episode
        string url = "https://localhost/api/user/watchlist/episode";

        var watchlistEpisode = BuildBodyWatchlistEpisode(bodyUser.Id!);

        RestResponse restResponse = request.PostRestRequest(url, watchlistEpisode, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyWatchlistEpisode = JsonSerializer.Deserialize<WatchlistEpisodeSchema>(
            restResponse.Content
        );
        Assert.NotNull(bodyWatchlistEpisode);
        Assert.Equal(watchlistEpisode.EpisodeId, bodyWatchlistEpisode.EpisodeId);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test2_CreateWatchlistEpisodeInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        //create watchlist episode
        string url = "https://localhost/api/user/watchlist/episode";

        var watchlistEpisode = BuildBodyWatchlistEpisode("1231231231312312313");

        RestResponse restResponse = request.PostRestRequest(url, watchlistEpisode, bodyUser.Token!);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid UserId", restResponse.Content);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test3_GetWatchlistEpisode()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);
        Assert.NotNull(bodyUser.Id);

        //create watchlist episode
        var watchlistEpisode = Create_WatchlistEpisode(bodyUser);
        Assert.NotNull(watchlistEpisode);

        //get watchlist episode
        string url = $"https://localhost/api/user/{bodyUser.Id}/watchlist/episode/{watchlistEpisode.EpisodeId}";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<WatchlistEpisodeSchema>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Equal(watchlistEpisode.EpisodeId, body.EpisodeId);
        Assert.Equal(watchlistEpisode.UserId, body.UserId);
        //delete user and watchlist (when user is deleted, watchlist is deleted too because of cascade)
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test4_GetWatchlistEpisodeInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //create watchlist episode
        var watchlistEpisode = Create_WatchlistEpisode(bodyUser);
        Assert.NotNull(watchlistEpisode);

        //get watchlist episode
        watchlistEpisode.EpisodeId = "%02%03";
        string url = $"https://localhost/api/user/{bodyUser.Id}/watchlist/episode/{watchlistEpisode.EpisodeId}";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.ErrorException!.Message);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid EpisodeId", restResponse.Content);

        //delete user and watchlist (when user is deleted, watchlist is deleted too because of cascade)
        userApiTests.Delet_User();
    }
    

    [Fact]
    public void Test5_DeleteWatchlistEpisode()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create watchlist episode
        var watchlistEpisode = Create_WatchlistEpisode(bodyUser);
        Assert.NotNull(watchlistEpisode);  
  
        //delete WatchlistEpisode
        string url = $"https://localhost/api/user/{bodyUser.Id}/watchlist/episode/{watchlistEpisode.EpisodeId}";
        var restResponse = request.DeleteRestRequest(url, watchlistEpisode, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Episode removed from User watchlist", restResponse.Content);

        
        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test6_DeleteWatchlistEpisodeInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //create watchlist episode
        var watchlistEpisode = Create_WatchlistEpisode(bodyUser);
        Assert.NotNull(watchlistEpisode);

        //delete WatchlistEpisode
        var invalidUserId = "用户ID";
        string url = $"https://localhost/api/user/{invalidUserId}/watchlist/episode/{watchlistEpisode.EpisodeId}";
        var restResponse = request.DeleteRestRequest(url, watchlistEpisode, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid UserId", restResponse.Content);

        //delete user
        userApiTests.Delet_User();
    }

    //////////////////////////////////////////////////////////watchlist/movie//////////////////////////////////////////////////////////
    
    [Fact]
    public void Test7_CreateWatchlistMovie()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        //create watchlist movie
        string url = "https://localhost/api/user/watchlist/movie";

        var watchlistMovie = BuildBodyWatchlistMovie(bodyUser.Id!);

        RestResponse restResponse = request.PostRestRequest(url, watchlistMovie, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyWatchlistMovie = JsonSerializer.Deserialize<WatchlistMovieSchema>(
            restResponse.Content
        );
        Assert.NotNull(bodyWatchlistMovie);
        Assert.Equal(watchlistMovie.MovieId, bodyWatchlistMovie.MovieId);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test8_CreateWatchlistMovieInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        //create watchlist movie
        string url = "https://localhost/api/user/watchlist/movie";

         var invalidUserId = "{\"$ne\":null}";

        var watchlistMovie = BuildBodyWatchlistMovie(invalidUserId);

        RestResponse restResponse = request.PostRestRequest(url, watchlistMovie, bodyUser.Token!);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid UserId", restResponse.Content);

        //delete user
        userApiTests.Delet_User();
    }
    
    [Fact]
    public void Test9_GetWatchlistMovie()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //create watchlist movie
        var watchlistMovie = Create_WatchlistMovie(bodyUser);
        Assert.NotNull(watchlistMovie);

        //get watchlist movie
        string url = $"https://localhost/api/user/{bodyUser.Id}/watchlist/movie/{watchlistMovie.MovieId}";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<WatchlistMovieSchema>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Equal(watchlistMovie.MovieId, body.MovieId);
        Assert.Equal(watchlistMovie.UserId, body.UserId);

        //delete user and watchlist (when user is deleted, watchlist is deleted too because of cascade)
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test10_GetWatchlistMovieInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //create watchlist movie
        var watchlistMovie = Create_WatchlistMovie(bodyUser);
        Assert.NotNull(watchlistMovie);

        //get watchlist movie
        var MovieId = "'%00%01%02'";
        string url = $"https://localhost/api/user/{bodyUser.Id}/watchlist/movie/{MovieId}";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.ErrorException!.Message);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);

        //delete user and watchlist (when user is deleted, watchlist is deleted too because of cascade)
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test11_DeleteWatchlistMovie()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create watchlist movie
        var watchlistMovie = Create_WatchlistMovie(bodyUser);
        Assert.NotNull(watchlistMovie);  
  
        //delete WatchlistMovie
        string url = $"https://localhost/api/user/{bodyUser.Id}/watchlist/movie/{watchlistMovie.MovieId}";
        var restResponse = request.DeleteRestRequest(url, watchlistMovie, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Movie removed from User watchlist", restResponse.Content);

        
        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test12_DeleteWatchlistMovieInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //create watchlist movie
        var watchlistMovie = Create_WatchlistMovie(bodyUser);
        Assert.NotNull(watchlistMovie);

        //delete WatchlistMovie
        var invalidEpisodeId = "tt11043522";
        string url = $"https://localhost/api/user/{watchlistMovie.UserId}/watchlist/movie/{invalidEpisodeId}";
        var restResponse = request.DeleteRestRequest(url, watchlistMovie, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.NotFound, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Movie not in User watchlist", restResponse.Content);

        //delete user
        userApiTests.Delet_User();
    }

    //////////////////////////////////////////////////////////watchlist/series//////////////////////////////////////////////////////////
    
    [Fact]
    public void Test13_CreateWatchlistSeries()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        //create watchlist series
        string url = "https://localhost/api/user/watchlist/series";

        var watchlistSeries = BuildBodyWatchlistSeries(bodyUser.Id!);

        RestResponse restResponse = request.PostRestRequest(url, watchlistSeries, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyWatchlistSeries = JsonSerializer.Deserialize<WatchlistSeriesSchema>(
            restResponse.Content
        );
        Assert.NotNull(bodyWatchlistSeries);
        Assert.Equal(watchlistSeries.SeriesId, bodyWatchlistSeries.SeriesId);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test14_CreateWatchlistSeriesInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        //create watchlist series
        string url = "https://localhost/api/user/watchlist/series";

        var watchlistSeries = BuildBodyWatchlistSeries("1231231231312312313");

        RestResponse restResponse = request.PostRestRequest(url, watchlistSeries, bodyUser.Token!);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid UserId", restResponse.Content);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test15_GetWatchlistSeries()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //create watchlist series
        var watchlistSeries = Create_WatchlistSeries(bodyUser);
        Assert.NotNull(watchlistSeries);

        //get watchlist series
        string url = $"https://localhost/api/user/{bodyUser.Id}/watchlist/series/{watchlistSeries.SeriesId}";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<WatchlistSeriesSchema>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Equal(watchlistSeries.SeriesId, body.SeriesId);
        Assert.Equal(watchlistSeries.UserId, body.UserId);

        //delete user and watchlist (when user is deleted, watchlist is deleted too because of cascade)
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test16_GetWatchlistSeriesInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //create watchlist series
        var watchlistSeries = Create_WatchlistSeries(bodyUser);
        Assert.NotNull(watchlistSeries);

        //get watchlist series
        watchlistSeries.SeriesId = "%02%03";
        string url = $"https://localhost/api/user/{bodyUser.Id}/watchlist/series/{watchlistSeries.SeriesId}";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.ErrorException!.Message);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);

        //delete user and watchlist (when user is deleted, watchlist is deleted too because of cascade)
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test17_DeleteWatchlistSeries()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create watchlist series
        var watchlistSeries = Create_WatchlistSeries(bodyUser);
        Assert.NotNull(watchlistSeries);  
  
        //delete WatchlistSeries
        string url = $"https://localhost/api/user/{bodyUser.Id}/watchlist/series/{watchlistSeries.SeriesId}";
        var restResponse = request.DeleteRestRequest(url, watchlistSeries, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Series removed from User watchlist", restResponse.Content);

        
        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test18_DeleteWatchlistSeriesInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //create watchlist series
        var watchlistSeries = Create_WatchlistSeries(bodyUser);
        Assert.NotNull(watchlistSeries);

        //delete WatchlistSeries
        var invalidUserId = "tt11573284";
        string url = $"https://localhost/api/user/{invalidUserId}/watchlist/series/{watchlistSeries.SeriesId}";
        var restResponse = request.DeleteRestRequest(url, watchlistSeries, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid UserId", restResponse.Content);

        //delete user
        userApiTests.Delet_User();
    }
    
    /////////////////////////////////////////////////////////////////watchlist/"ALL"///////////////////////////////////////////////////////////

    [Fact]
    public void Test19_GetWatchlistAll()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //create watchlist episode
        var watchlistEpisode = Create_WatchlistEpisode(bodyUser);
        Assert.NotNull(watchlistEpisode);

        //create watchlist movie
        var watchlistMovie = Create_WatchlistMovie(bodyUser);
        Assert.NotNull(watchlistMovie);

        //create watchlist series
        var watchlistSeries = Create_WatchlistSeries(bodyUser);
        Assert.NotNull(watchlistSeries);

        //get watchlist all
        string url = $"https://localhost/api/user/{bodyUser.Id}/watchlist";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains(watchlistEpisode.EpisodeId!, restResponse.Content);
        Assert.Contains(watchlistMovie.MovieId!, restResponse.Content);
        Assert.Contains(watchlistSeries.SeriesId!, restResponse.Content);


        //delete user and watchlist (when user is deleted, watchlist is deleted too because of cascade)
        userApiTests.Delet_User();
    }  

    [Fact]
    public void Test20_GetWatchlistAllInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //get watchlist all
        string url = $"https://localhost/api/user/{bodyUser.Id}/watchlist";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.DoesNotContain("EpisodeId", restResponse.Content);
        Assert.DoesNotContain("MovieId", restResponse.Content);
        Assert.DoesNotContain("SeriesId", restResponse.Content);

        //delete user and watchlist (when user is deleted, watchlist is deleted too because of cascade)
        userApiTests.Delet_User();
    }
    private static WatchlistEpisodeSchema BuildBodyWatchlistEpisode(string userId)
    {
        return new WatchlistEpisodeSchema { UserId = userId, EpisodeId = "tt0959621" };
    }

    public static WatchlistMovieSchema BuildBodyWatchlistMovie(string userId)
    {
        return new WatchlistMovieSchema { UserId = userId, MovieId = "tt1596363" };
    }

    public static WatchlistSeriesSchema BuildBodyWatchlistSeries(string userId)
    {
        return new WatchlistSeriesSchema { UserId = userId, SeriesId = "tt20877972" };
    }

    internal WatchlistEpisodeSchema Create_WatchlistEpisode(UserSchema user)
    {
        var url = "https://localhost/api/user/watchlist/episode";

        var watchlistEpisode = BuildBodyWatchlistEpisode(user.Id!);

        var restResponse = request.PostRestRequest(url, watchlistEpisode, user.Token!);

        var body = JsonSerializer.Deserialize<WatchlistEpisodeSchema>(restResponse.Content!);
        return body!;
    }

    internal WatchlistMovieSchema Create_WatchlistMovie(UserSchema user)
    {
        var url = "https://localhost/api/user/watchlist/movie";

        var watchlistMovie = BuildBodyWatchlistMovie(user.Id!);

        var restResponse = request.PostRestRequest(url, watchlistMovie, user.Token!);

        var body = JsonSerializer.Deserialize<WatchlistMovieSchema>(restResponse.Content!);
        return body!;
    }

    internal WatchlistSeriesSchema Create_WatchlistSeries(UserSchema user)
    {
        var url = "https://localhost/api/user/watchlist/series";

        var watchlistSeries = BuildBodyWatchlistSeries(user.Id!);

        var restResponse = request.PostRestRequest(url, watchlistSeries, user.Token!);

        var body = JsonSerializer.Deserialize<WatchlistSeriesSchema>(restResponse.Content!);
        return body!;
    }
}
