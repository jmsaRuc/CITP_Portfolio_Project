using System.Net;
using System.Text.Json;
using NuGet.Protocol;
using RestSharp;
using RestSharp.Authenticators;
using test.UserTest;
using test.UserTest.WatchlistTest;
using Xunit;
using Xunit.Abstractions;
using ServicePointManager = System.Net.ServicePointManager;

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

    private readonly RequestClassWatchlist requestWatch = new();
    private readonly WatchlistEpisodeSchema watchlistEpisode = new();

    //////////////////////////////////////////Test WatchlistEpisode//////////////////////////////////////////

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

        var watchlistEpisode = (WatchlistEpisodeSchema)
            RequestClassWatchlist.BuildBodyEpisode(bodyUser.Id!);

        RestResponse restResponse = requestWatch.PostRestRequest(
            bodyUser.Token!,
            url,
            watchlistEpisode
        );
        _testOutputHelper.WriteLine(restResponse.Content!);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyWatchlistEpisode = JsonSerializer.Deserialize<WatchlistEpisodeSchema>(
            restResponse.Content!
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

        var watchlistEpisode = (WatchlistEpisodeSchema)
            RequestClassWatchlist.BuildBodyEpisode("1231231231312312313"!);

        RestResponse restResponse = requestWatch.PostRestRequest(
            bodyUser.Token!,
            url,
            watchlistEpisode
        );
        _testOutputHelper.WriteLine(restResponse.Content!);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test3_DeleteWatchlistEpisode()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //create watchlist episode
        string url = "https://localhost/api/user/watchlist/episode";

        var watchlistEpisode = (WatchlistEpisodeSchema)
            RequestClassWatchlist.BuildBodyEpisode(bodyUser.Id!);

        RestResponse restResponse = requestWatch.PostRestRequest(
            bodyUser.Token!,
            url,
            watchlistEpisode
        );
        _testOutputHelper.WriteLine(restResponse.Content!);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyWatchlistEpisode = JsonSerializer.Deserialize<WatchlistEpisodeSchema>(
            restResponse.Content!
        );
        Assert.NotNull(bodyWatchlistEpisode);
        Assert.Equal(watchlistEpisode.EpisodeId, bodyWatchlistEpisode.EpisodeId);

        //delete watchlist episode
        string urlDelete =
            $"https://localhost/api/user/{bodyUser.Id}/watchlist/episode/{bodyWatchlistEpisode.EpisodeId}";
        RestResponse restResponseDelete = requestWatch.DeleteRestRequest(
            bodyUser.Token!,
            urlDelete,
            watchlistEpisode
        );
        _testOutputHelper.WriteLine(restResponseDelete.Content!);

        Assert.Equal(HttpStatusCode.OK, restResponseDelete.StatusCode);
        Assert.NotNull(restResponseDelete.Content);
        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test4_DeleteWatchlistEpisodeInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //create watchlist episode
        string url = "https://localhost/api/user/watchlist/episode";

        var watchlistEpisode = (WatchlistEpisodeSchema)
            RequestClassWatchlist.BuildBodyEpisode(bodyUser.Id!);

        RestResponse restResponse = requestWatch.PostRestRequest(
            bodyUser.Token!,
            url,
            watchlistEpisode
        );
        _testOutputHelper.WriteLine(restResponse.Content!);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyWatchlistEpisode = JsonSerializer.Deserialize<WatchlistEpisodeSchema>(
            restResponse.Content!
        );
        Assert.NotNull(bodyWatchlistEpisode);
        Assert.Equal(watchlistEpisode.EpisodeId, bodyWatchlistEpisode.EpisodeId);

        //delete watchlist episode
        string urlDelete =
            $"https://localhost/api/user/{bodyUser.Id}/watchlist/episode/123123123123123123";
        RestResponse restResponseDelete = requestWatch.DeleteRestRequest(
            bodyUser.Token!,
            urlDelete,
            watchlistEpisode
        );
        _testOutputHelper.WriteLine(restResponseDelete.Content!);

        Assert.Equal(HttpStatusCode.BadRequest, restResponseDelete.StatusCode);
        Assert.NotNull(restResponseDelete.Content);
        //delete user
        userApiTests.Delet_User();
    }

    //////////////////////////////////////////Test WatchlistMovie//////////////////////////////////////////

    [Fact]
    public void Test5_CreateWatchlistMovie()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        //create watchlist movie
        string url = "https://localhost/api/user/watchlist/movie";

        var watchlistMovie = (WatchlistMovieSchema)
            RequestClassWatchlist.BuildBodyMovie(bodyUser.Id!);
        _testOutputHelper.WriteLine(watchlistMovie.MovieId);
        RestResponse restResponse = requestWatch.PostRestRequest(
            bodyUser.Token!,
            url,
            watchlistMovie
        );
        _testOutputHelper.WriteLine(restResponse.Content!);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyWatchlistMovie = JsonSerializer.Deserialize<WatchlistMovieSchema>(
            restResponse.Content!
        );
        Assert.NotNull(bodyWatchlistMovie);
        Assert.Equal(watchlistMovie.MovieId, bodyWatchlistMovie.MovieId);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test6_CreateWatchlistMovieInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        //create watchlist movie
        string url = "https://localhost/api/user/watchlist/movie";

        var watchlistMovie = (WatchlistMovieSchema)
            RequestClassWatchlist.BuildBodyMovie("1231231231312312313"!);

        RestResponse restResponse = requestWatch.PostRestRequest(
            bodyUser.Token!,
            url,
            watchlistMovie
        );
        _testOutputHelper.WriteLine(restResponse.Content!);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test7_DeleteWatchlistMovie()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //create watchlist movie
        string url = "https://localhost/api/user/watchlist/movie";

        var watchlistMovie = (WatchlistMovieSchema)
            RequestClassWatchlist.BuildBodyMovie(bodyUser.Id!);

        RestResponse restResponse = requestWatch.PostRestRequest(
            bodyUser.Token!,
            url,
            watchlistMovie
        );
        _testOutputHelper.WriteLine(restResponse.Content!);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyWatchlistMovie = JsonSerializer.Deserialize<WatchlistMovieSchema>(
            restResponse.Content!
        );
        Assert.NotNull(bodyWatchlistMovie);
        Assert.Equal(watchlistMovie.MovieId, bodyWatchlistMovie.MovieId);

        //delete watchlist movie
        string urlDelete =
            $"https://localhost/api/user/{bodyUser.Id}/watchlist/movie/{bodyWatchlistMovie.MovieId}";
        RestResponse restResponseDelete = requestWatch.DeleteRestRequest(
            bodyUser.Token!,
            urlDelete,
            watchlistMovie
        );
        _testOutputHelper.WriteLine(restResponseDelete.Content!);

        Assert.Equal(HttpStatusCode.OK, restResponseDelete.StatusCode);
        Assert.NotNull(restResponseDelete.Content);
        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test8_DeleteWatchlistMovieInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //create watchlist movie
        string url = "https://localhost/api/user/watchlist/movie";

        var watchlistMovie = (WatchlistMovieSchema)
            RequestClassWatchlist.BuildBodyMovie(bodyUser.Id!);

        RestResponse restResponse = requestWatch.PostRestRequest(
            bodyUser.Token!,
            url,
            watchlistMovie
        );
        _testOutputHelper.WriteLine(restResponse.Content!);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyWatchlistMovie = JsonSerializer.Deserialize<WatchlistMovieSchema>(
            restResponse.Content!
        );
        Assert.NotNull(bodyWatchlistMovie);
        Assert.Equal(watchlistMovie.MovieId, bodyWatchlistMovie.MovieId);

        //delete watchlist movie
        string urlDelete =
            $"https://localhost/api/user/{bodyUser.Id}/watchlist/movie/123123123123123123";
        RestResponse restResponseDelete = requestWatch.DeleteRestRequest(
            bodyUser.Token!,
            urlDelete,
            watchlistMovie
        );
        _testOutputHelper.WriteLine(restResponseDelete.Content!);

        Assert.Equal(HttpStatusCode.BadRequest, restResponseDelete.StatusCode);
        Assert.NotNull(restResponseDelete.Content);
        //delete user
        userApiTests.Delet_User();
    }

    //////////////////////////////////////////Test WatchlistSeries//////////////////////////////////////////
    

    [Fact]
    public void Test9_CreateWatchlistSeries()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        //create watchlist series
        string url = "https://localhost/api/user/watchlist/series";

        var watchlistSeries = (WatchlistSeriesSchema)
            RequestClassWatchlist.BuildBodySeries(bodyUser.Id!);
        _testOutputHelper.WriteLine(watchlistSeries.SeriesId);
        RestResponse restResponse = requestWatch.PostRestRequest(
            bodyUser.Token!,
            url,
            watchlistSeries
        );
        _testOutputHelper.WriteLine(restResponse.Content!);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyWatchlistSeries = JsonSerializer.Deserialize<WatchlistSeriesSchema>(
            restResponse.Content!
        );
        Assert.NotNull(bodyWatchlistSeries);
        Assert.Equal(watchlistSeries.SeriesId, bodyWatchlistSeries.SeriesId);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test10_CreateWatchlistSeriesInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        //create watchlist series
        string url = "https://localhost/api/user/watchlist/series";

        var watchlistSeries = (WatchlistSeriesSchema)
            RequestClassWatchlist.BuildBodySeries("1231231231312312313"!);

        RestResponse restResponse = requestWatch.PostRestRequest(
            bodyUser.Token!,
            url,
            watchlistSeries
        );
        _testOutputHelper.WriteLine(restResponse.Content!);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test11_DeleteWatchlistSeries()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //create watchlist series
        string url = "https://localhost/api/user/watchlist/series";

        var watchlistSeries = (WatchlistSeriesSchema)
            RequestClassWatchlist.BuildBodySeries(bodyUser.Id!);

        RestResponse restResponse = requestWatch.PostRestRequest(
            bodyUser.Token!,
            url,
            watchlistSeries
        );
        _testOutputHelper.WriteLine(restResponse.Content!);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyWatchlistSeries = JsonSerializer.Deserialize<WatchlistSeriesSchema>(
            restResponse.Content!
        );
        Assert.NotNull(bodyWatchlistSeries);
        Assert.Equal(watchlistSeries.SeriesId, bodyWatchlistSeries.SeriesId);

        //delete watchlist series
        string urlDelete =
            $"https://localhost/api/user/{bodyUser.Id}/watchlist/series/{bodyWatchlistSeries.SeriesId}";
        RestResponse restResponseDelete = requestWatch.DeleteRestRequest(
            bodyUser.Token!,
            urlDelete,
            watchlistSeries
        );
        _testOutputHelper.WriteLine(restResponseDelete.Content!);

        Assert.Equal(HttpStatusCode.OK, restResponseDelete.StatusCode);
        Assert.NotNull(restResponseDelete.Content);
        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test12_DeleteWatchlistSeriesInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login
        var bodyUser = userApiTests.Login();

        //create watchlist series
        string url = "https://localhost/api/user/watchlist/series";

        var watchlistSeries = (WatchlistSeriesSchema)
            RequestClassWatchlist.BuildBodySeries(bodyUser.Id!);

        RestResponse restResponse = requestWatch.PostRestRequest(
            bodyUser.Token!,
            url,
            watchlistSeries
        );
        _testOutputHelper.WriteLine(restResponse.Content!);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyWatchlistSeries = JsonSerializer.Deserialize<WatchlistSeriesSchema>(
            restResponse.Content!
        );
        Assert.NotNull(bodyWatchlistSeries);
        Assert.Equal(watchlistSeries.SeriesId, bodyWatchlistSeries.SeriesId);

        //delete watchlist series
        string urlDelete =
            $"https://localhost/api/user/{bodyUser.Id}/watchlist/series/123123123123123123";
        RestResponse restResponseDelete = requestWatch.DeleteRestRequest(
            bodyUser.Token!,
            urlDelete,
            watchlistSeries
        );
        _testOutputHelper.WriteLine(restResponseDelete.Content!);

        Assert.Equal(HttpStatusCode.BadRequest, restResponseDelete.StatusCode);
        Assert.NotNull(restResponseDelete.Content);
        //delete user
        userApiTests.Delet_User();
    }
}
