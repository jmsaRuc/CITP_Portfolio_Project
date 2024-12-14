using System.Net;
using System.Text.Json;
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

    ///////////////////////////////////////////////////////////////////rating/episode///////////////////////////////////////////////////////////////////

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

        var restResponse = request.PostRestRequest(url, ratingsEpisode, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyRatingsEpisode = JsonSerializer.Deserialize<RatingsEpisodeSchema>(
            restResponse.Content
        );
        Assert.NotNull(bodyRatingsEpisode);
        Assert.Equal(ratingsEpisode.UserId, bodyRatingsEpisode.UserId);

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

        var restResponse = request.PostRestRequest(url, ratingsEpisode, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Rating must be between 1 and 10", restResponse.Content);

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
        var url =
            $"https://localhost/api/user/{ratingsEpisode.UserId}/ratings/episode/{ratingsEpisode.EpisodeId}";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<RatingsEpisodeSchema>(restResponse.Content);
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
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.NotFound, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("User has not rated this episode", restResponse.Content);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test5_UpdateRatingEpisode()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating episode
        var ratingsEpisode = Create_RatingEpisode(bodyUser);
        Assert.NotNull(ratingsEpisode);

        //update rating episode
        var ratingsEpisodeUpdate = BuildBodyRatingEpisode(bodyUser.Id!, 1);
        var url =
            $"https://localhost/api/user/{bodyUser.Id}/ratings/episode/{ratingsEpisode.EpisodeId}";
        var restResponse = request.PutRestRequest(url, ratingsEpisodeUpdate, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<RatingsEpisodeSchema>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Equal(ratingsEpisode.UserId, body.UserId);
        Assert.Equal(ratingsEpisode.EpisodeId, body.EpisodeId);
        Assert.Equal(ratingsEpisodeUpdate.Rating, body.Rating);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test6_UpdateRatingEpisodeInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating episode
        var ratingsEpisode = Create_RatingEpisode(bodyUser);
        Assert.NotNull(ratingsEpisode);

        //update rating episode
        var ratingsEpisodeUpdate = BuildBodyRatingEpisode(bodyUser.Id!, 0);
        var url =
            $"https://localhost/api/user/{bodyUser.Id}/ratings/episode/{ratingsEpisode.EpisodeId}";
        var restResponse = request.PutRestRequest(url, ratingsEpisodeUpdate, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Rating must be between 1 and 10", restResponse.Content);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test7_DeleteRatingEpisode()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating episode
        var ratingsEpisode = Create_RatingEpisode(bodyUser);
        Assert.NotNull(ratingsEpisode);

        //delete rating episode
        var url =
            $"https://localhost/api/user/{bodyUser.Id}/ratings/episode/{ratingsEpisode.EpisodeId}";
        var restResponse = request.DeleteRestRequest(url, ratingsEpisode, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Rating deleted", restResponse.Content);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test8_DeleteRatingEpisodeInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating episode
        var ratingsEpisode = Create_RatingEpisode(bodyUser);
        Assert.NotNull(ratingsEpisode);

        //delete rating episode
        var url = $"https://localhost/api/user/{bodyUser.Id}/ratings/episode/td11322924";
        var restResponse = request.DeleteRestRequest(url, ratingsEpisode, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid EpisodeId", restResponse.Content);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    ///////////////////////////////////////////////////////////////////rating/movie///////////////////////////////////////////////////////////////////

    [Fact]
    public void Test9_CreateRatingMovie()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        //create rating movie
        var url = "https://localhost/api/user/ratings/movie";

        var ratingsMovie = BuildBodyRatingMovie(bodyUser.Id!);

        var restResponse = request.PostRestRequest(url, ratingsMovie, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyRatingsMovie = JsonSerializer.Deserialize<RatingsMovieSchema>(restResponse.Content);
        Assert.NotNull(bodyRatingsMovie);
        Assert.Equal(ratingsMovie.UserId, bodyRatingsMovie.UserId);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test10_CreateRaitingMovieInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        //create rating movie
        var url = "https://localhost/api/user/ratings/movie";

        var ratingsMovie = BuildBodyRatingMovie("æ", 3);

        var restResponse = request.PostRestRequest(url, ratingsMovie, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid UserId", restResponse.Content);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test11_GetRatingMovie()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating mopvie
        var ratingsMovie = Create_RatingMovie(bodyUser);
        Assert.NotNull(ratingsMovie);

        //get rating movie
        var url =
            $"https://localhost/api/user/{ratingsMovie.UserId}/ratings/movie/{ratingsMovie.MovieId}";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<RatingsMovieSchema>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Equal(ratingsMovie.UserId, body.UserId);
        Assert.Equal(ratingsMovie.MovieId, body.MovieId);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test12_GetRatingMovieInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating movie
        var ratingsMovie = Create_RatingMovie(bodyUser);
        Assert.NotNull(ratingsMovie);

        //get rating movie
        string null_movieId = "''";
        var url = $"https://localhost/api/user/{ratingsMovie.UserId}/ratings/movie/{null_movieId}";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine("restResponse.Content: " + restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid MovieId", restResponse.Content);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test13_UpdateRatingMovie()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating movie
        var ratingsMovie = Create_RatingMovie(bodyUser);
        Assert.NotNull(ratingsMovie);

        //update rating movie
        var ratingsMovieUpdate = BuildBodyRatingMovie(bodyUser.Id!, 1);
        var url = $"https://localhost/api/user/{bodyUser.Id}/ratings/movie/{ratingsMovie.MovieId}";
        var restResponse = request.PutRestRequest(url, ratingsMovieUpdate, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<RatingsMovieSchema>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Equal(ratingsMovie.UserId, body.UserId);
        Assert.Equal(ratingsMovie.MovieId, body.MovieId);
        Assert.Equal(ratingsMovieUpdate.Rating, body.Rating);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test14_UpdateRatingMovieInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating movie
        var ratingsMovie = Create_RatingMovie(bodyUser);
        Assert.NotNull(ratingsMovie);

        //update rating movie
        string sql_injection = $"ur00OR1=1";
        var ratingsMovieUpdate = BuildBodyRatingMovie(bodyUser.Id!, 4);
        var url =
            $"https://localhost/api/user/{sql_injection}/ratings/movie/{ratingsMovie.MovieId}";
        var restResponse = request.PutRestRequest(url, ratingsMovieUpdate, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid UserId", restResponse.Content);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test15_DeleteRatingMovie()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating movie
        var ratingsMovie = Create_RatingMovie(bodyUser);
        Assert.NotNull(ratingsMovie);

        //delete rating movie
        var url = $"https://localhost/api/user/{bodyUser.Id}/ratings/movie/{ratingsMovie.MovieId}";
        var restResponse = request.DeleteRestRequest(url, ratingsMovie, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Rating deleted", restResponse.Content);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test16_DeleteRatingMovieInvalid()
    {
        //create user
        userApiTests.Create_User();

        //create another user


        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating movie
        var ratingsMovie = Create_RatingMovie(bodyUser);
        Assert.NotNull(ratingsMovie);

        //delete rating movie
        var url =
            $"https://localhost/api/user/{ratingsMovie.UserId}/ratings/movie/{ratingsMovie.MovieId}";
        var fake_token = $"{bodyUser.Token}fake";
        var restResponse = request.DeleteRestRequest(url, ratingsMovie, fake_token);
        _testOutputHelper.WriteLine(restResponse.ErrorException?.Message);

        Assert.Equal(HttpStatusCode.Unauthorized, restResponse.StatusCode);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    ///////////////////////////////////////////////////////////////////rating/series//////////////////////////////////////////////////////////////////

    [Fact]
    public void Test17_CreateRatingSeries()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        //create rating series
        var url = "https://localhost/api/user/ratings/series";

        var ratingsSeries = BuildBodyRatingSeries(bodyUser.Id!);

        var restResponse = request.PostRestRequest(url, ratingsSeries, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var bodyRatingsSeries = JsonSerializer.Deserialize<RatingsSeriesSchema>(
            restResponse.Content
        );
        Assert.NotNull(bodyRatingsSeries);
        Assert.Equal(ratingsSeries.UserId, bodyRatingsSeries.UserId);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test18_CreateRaitingSeriesInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);

        //create rating series
        var url = "https://localhost/api/user/ratings/series";

        var ratingsSeries = BuildBodyRatingSeries("", 3);

        var restResponse = request.PostRestRequest(url, ratingsSeries, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid UserId", restResponse.Content);

        //delete user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test19_GetRatingSeries()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating series
        var ratingsSeries = Create_RatingSeries(bodyUser);
        Assert.NotNull(ratingsSeries);

        //get rating series
        var url =
            $"https://localhost/api/user/{ratingsSeries.UserId}/ratings/series/{ratingsSeries.SeriesId}";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<RatingsSeriesSchema>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Equal(ratingsSeries.UserId, body.UserId);
        Assert.Equal(ratingsSeries.SeriesId, body.SeriesId);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test20_GetRatingSeriesInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating series
        var ratingsSeries = Create_RatingSeries(bodyUser);
        Assert.NotNull(ratingsSeries);

        //get rating series
        string null_seriesId = "!@#$%^&*()";
        var url =
            $"https://localhost/api/user/{ratingsSeries.UserId}/ratings/series/{null_seriesId}";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine("restResponse.Content: " + restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid SeriesId", restResponse.Content);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test21_UpdateRatingSeries()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating series
        var ratingsSeries = Create_RatingSeries(bodyUser);
        Assert.NotNull(ratingsSeries);

        //update rating series
        var ratingsSeriesUpdate = BuildBodyRatingSeries(bodyUser.Id!, 1);
        var url =
            $"https://localhost/api/user/{bodyUser.Id}/ratings/series/{ratingsSeries.SeriesId}";
        var restResponse = request.PutRestRequest(url, ratingsSeriesUpdate, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<RatingsSeriesSchema>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Equal(ratingsSeries.UserId, body.UserId);
        Assert.Equal(ratingsSeries.SeriesId, body.SeriesId);
        Assert.Equal(ratingsSeriesUpdate.Rating, body.Rating);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test22_UpdateRatingSeriesInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating series
        var ratingsSeries = Create_RatingSeries(bodyUser);
        Assert.NotNull(ratingsSeries);

        //update rating series
        var invalidUserId = "'; DROP TABLE Users; --";
        var ratingsSeriesUpdate = BuildBodyRatingSeries(bodyUser.Id!, 4);
        var url =
            $"https://localhost/api/user/{invalidUserId}/ratings/series/{ratingsSeries.SeriesId}";
        var restResponse = request.PutRestRequest(url, ratingsSeriesUpdate, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid UserId", restResponse.Content);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test23_DeleteRatingSeries()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating series
        var ratingsSeries = Create_RatingSeries(bodyUser);
        Assert.NotNull(ratingsSeries);

        //delete rating series
        var url =
            $"https://localhost/api/user/{bodyUser.Id}/ratings/series/{ratingsSeries.SeriesId}";
        var restResponse = request.DeleteRestRequest(url, ratingsSeries, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Rating deleted", restResponse.Content);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test24_DeleteRatingSeriesInvalid()
    {
        //create user
        userApiTests.Create_User();

        //create another user


        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating series
        var ratingsSeries = Create_RatingSeries(bodyUser);
        Assert.NotNull(ratingsSeries);

        //delete rating series
        var invalidSeriesId = new string('a', 1000); //Excessively Long String: String with 1000 'a's

        var url =
            $"https://localhost/api/user/{ratingsSeries.UserId}/ratings/series/{invalidSeriesId}";
        var restResponse = request.DeleteRestRequest(url, ratingsSeries, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.ErrorException?.Message);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid SeriesId", restResponse.Content);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    ///////////////////////////////////////////////////////////////////rating/"ALL"///////////////////////////////////////////////////////////////////

    [Fact]
    public void Test25_GetAllRatings()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //create rating episode
        var ratingsEpisode = Create_RatingEpisode(bodyUser);
        Assert.NotNull(ratingsEpisode);

        //create rating movie
        var ratingsMovie = Create_RatingMovie(bodyUser);
        Assert.NotNull(ratingsMovie);

        //create rating series
        var ratingsSeries = Create_RatingSeries(bodyUser);
        Assert.NotNull(ratingsSeries);

        //get all ratings
        var url = $"https://localhost/api/user/{bodyUser.Id}/ratings";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains(ratingsEpisode.EpisodeId!, restResponse.Content);
        Assert.Contains(ratingsMovie.MovieId!, restResponse.Content);
        Assert.Contains(ratingsSeries.SeriesId!, restResponse.Content);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test26_GetAllRatingsInvalid()
    {
        //create user
        userApiTests.Create_User();

        //login user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser);

        //get all ratings
        var url = $"https://localhost/api/user/{bodyUser.Id}/ratings";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.DoesNotContain("EpisodeId", restResponse.Content);
        Assert.DoesNotContain("MovieId", restResponse.Content);
        Assert.DoesNotContain("SeriesId", restResponse.Content);

        //delete user wich deletes all ratings and watchlist
        userApiTests.Delet_User();
    }

    internal static RatingsEpisodeSchema BuildBodyRatingEpisode(string userId, short rating = 5)
    {
        return new RatingsEpisodeSchema
        {
            UserId = userId,
            EpisodeId = "tt0959621",
            Rating = rating,
        };
    }

    internal static RatingsMovieSchema BuildBodyRatingMovie(string userId, short rating = 5)
    {
        return new RatingsMovieSchema
        {
            UserId = userId,
            MovieId = "tt1596363",
            Rating = rating,
        };
    }

    internal static RatingsSeriesSchema BuildBodyRatingSeries(string userId, short rating = 5)
    {
        return new RatingsSeriesSchema
        {
            UserId = userId,
            SeriesId = "tt20877972",
            Rating = rating,
        };
    }

    internal RatingsEpisodeSchema Create_RatingEpisode(UserSchema user)
    {
        var url = "https://localhost/api/user/ratings/episode";

        var ratingsEpisode = BuildBodyRatingEpisode(user.Id!);

        var restResponse = request.PostRestRequest(url, ratingsEpisode, user.Token!);

        var body = JsonSerializer.Deserialize<RatingsEpisodeSchema>(restResponse.Content!);
        return body!;
    }

    internal RatingsMovieSchema Create_RatingMovie(UserSchema user)
    {
        var url = "https://localhost/api/user/ratings/movie";

        var ratingsMovie = BuildBodyRatingMovie(user.Id!);

        var restResponse = request.PostRestRequest(url, ratingsMovie, user.Token!);

        var body = JsonSerializer.Deserialize<RatingsMovieSchema>(restResponse.Content!);
        return body!;
    }

    internal RatingsSeriesSchema Create_RatingSeries(UserSchema user)
    {
        var url = "https://localhost/api/user/ratings/series";

        var ratingsSeries = BuildBodyRatingSeries(user.Id!);

        var restResponse = request.PostRestRequest(url, ratingsSeries, user.Token!);

        var body = JsonSerializer.Deserialize<RatingsSeriesSchema>(restResponse.Content!);
        return body!;
    }
}
