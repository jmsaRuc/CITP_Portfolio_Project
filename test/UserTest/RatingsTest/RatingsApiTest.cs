using System.Net;
using System.Text.Json;
using RestSharp;
using RestSharp.Authenticators;
using Xunit.Abstractions;

namespace test.UserTest.RatingsTest;

public class RatingsApiTest
{   
    private readonly ITestOutputHelper _testOutputHelper;

    private readonly UserApiTests userApiTests;
    
    public RatingsApiTest(ITestOutputHelper testOutputHelper)
    {
        _testOutputHelper = testOutputHelper;
        userApiTests = new(_testOutputHelper);
    }

    private readonly RequestClass request = new();

    [Fact]
    public void Test1_CreateRatingEpisode()
    {   
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        var url = "https://localhost/api/user/ratings/episode";

        var ratingsEpisode = BuildBodyRatingEpisode(bodyUser.Id!);

        var restResponse = request.PostRestRequest(url, ratingsEpisode, bodyUser.Token!);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyWatchlistEpisode = JsonSerializer.Deserialize<WatchlistEpisodeSchema>(
            restResponse.Content!
        );
        Assert.NotNull(bodyWatchlistEpisode);
        Assert.Equal(ratingsEpisode.UserId, bodyWatchlistEpisode.UserId);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test2_CreateRaitingEpisodeInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        var url = "https://localhost/api/user/ratings/episode";

        var ratingsEpisode = BuildBodyRatingEpisode(bodyUser.Id!, 0);

        var restResponse = request.PostRestRequest(url, ratingsEpisode, bodyUser.Token!);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test3_GetRatingEpisode()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating episode
        var ratingsEpisode = Create_RatingEpisode(bodyUser);
        Assert.NotNull(ratingsEpisode);

        //get rating episode
        var url = $"https://localhost/api/user/{ratingsEpisode.UserId}/ratings/episode/{ratingsEpisode.EpisodeId}";
        var restResponse = request.GetRestRequest(url, bodyUser.Token!);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<RatingsEpisodeSchema>(
            restResponse.Content!
        );
        Assert.NotNull(body);
        Assert.Equal(ratingsEpisode.UserId, body.UserId);
        Assert.Equal(ratingsEpisode.EpisodeId, body.EpisodeId);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test4_GetRatingEpisodeInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating episode
        var ratingsEpisode = Create_RatingEpisode(bodyUser);
        Assert.NotNull(ratingsEpisode);

        //get rating episode
        var url = $"https://localhost/api/user/{ratingsEpisode.UserId}/ratings/episode/tt11322924";
        var restResponse = request.GetRestRequest(url, bodyUser.Token!);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.NotFound, restResponse.StatusCode);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    internal static RatingsEpisodeSchema BuildBodyRatingEpisode(string userId, short rating = 5)
    {
        return new RatingsEpisodeSchema { UserId = userId, EpisodeId = "tt0959621", Rating = rating};
    }

    internal RatingsEpisodeSchema Create_RatingEpisode(UserSchema user)
    {
        var url = "https://localhost/api/user/ratings/episode";

        var ratingsEpisode = BuildBodyRatingEpisode(user.Id!);

        var restResponse = request.PostRestRequest(url, ratingsEpisode, user.Token!);

        var body = JsonSerializer.Deserialize<RatingsEpisodeSchema>(
            restResponse.Content!
        );
        return body!;
    }


}
