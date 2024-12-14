using System.Net;
using System.Text.Json;
using RestSharp;
using test.TitleTest.Movie;
using Xunit.Abstractions;

namespace test.GenreTest;

public class GenreApiTest
{
    private readonly ITestOutputHelper _testOutputHelper;
    private readonly GenreSchema genreSchema;

    public GenreApiTest(ITestOutputHelper testOutputHelper)
    {
        _testOutputHelper = testOutputHelper;
        genreSchema = new();
    }

    readonly RequestClass request = new();

    ///////////////////////////////////////////////genre/all////////////////////////////////////////////////////
    [Fact]
    public void Test1_GetGenreAll()
    {
        string url = "https://localhost/api/genre";
        RestResponse restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<GenreSchema>>(restResponse.Content);
        Assert.NotNull(body);
        Assert.NotNull(body[0].GenreName);
        Assert.Contains(body[0].GenreName!, "Action");
    }

    ///////////////////////////////////////////////genre/{GenreName}////////////////////////////////////////////////////
    [Fact]
    public void Test2_GetGenreID()
    {
        string url = "https://localhost/api/genre/Action";
        RestResponse restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<GenreSchema>(restResponse.Content);
        Assert.NotNull(body);
        Assert.NotNull(body.GenreName);
        Assert.Contains("Action", body.GenreName);
        Assert.NotNull(body.EpisodeAmount);
        Assert.True(body.EpisodeAmount! > 7000);
        Assert.NotNull(body.MovieAmount);
        Assert.True(body.MovieAmount! > 3000);
        Assert.NotNull(body.SeriesAmount);
        Assert.True(body.SeriesAmount! > 100);
        Assert.NotNull(body.TotalAmount);
        Assert.True(body.TotalAmount! == body.EpisodeAmount + body.MovieAmount + body.SeriesAmount);
    }

    [Fact]
    public void Test3_GetGenreID_NotFound()
    {
        var nonExistingGenre = "Action1";
        string url = $"https://localhost/api/genre/{nonExistingGenre}";
        RestResponse restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.NotFound, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Genre not found", restResponse.Content);
    }

    ///////////////////////////////////////////////genre/{GenreName}/titles////////////////////////////////////////////////////

    [Fact]
    public void Test4_GetGenreMovies()
    {
        string url =
            "https://localhost/api/genre/Action/movies?pageSize=2&pageNumber=1&sortBy=averageRating";
        RestResponse restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<MovieSchema>>(restResponse.Content);
        Assert.NotNull(body);
        Assert.NotNull(body[0].MovieId);
        Assert.NotNull(body[0].Title);
        Assert.NotNull(body[0].AverageRating);
        Assert.NotNull(body[0].ImdbRating);
        Assert.NotNull(body[0].Popularity);
    }

    [Fact]
    public void Test5_GetGenreMovies_Invalid()
    {
        var nonExistingGenreSqlInject = "Action or 1=1";
        string url =
            $"https://localhost/api/genre/{nonExistingGenreSqlInject}/movies?pageSize=2&pageNumber=1&sortBy=averageRating";
        RestResponse restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.NotFound, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Genre not found", restResponse.Content);
    }

    [Fact]
    public void Test6_GetGenreEpisode()
    {
        string url =
            "https://localhost/api/genre/Action/episodes?pageSize=2&pageNumber=1&sortBy=imdbRating";
        RestResponse restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<MovieSchema>>(restResponse.Content);
        Assert.NotNull(body);
        Assert.NotNull(body[0].MovieId);
        Assert.NotNull(body[0].Title);
        Assert.NotNull(body[0].AverageRating);
        Assert.NotNull(body[0].ImdbRating);
        Assert.NotNull(body[0].Popularity);
    }

    [Fact]
    public void Test7_GetGenreEpisode_Invalid()
    {
        var nonExistingGenreSqlInject = "asdf3rq  ***@@@  342d12q3xcxcxc";
        string url =
            $"https://localhost/api/genre/{nonExistingGenreSqlInject}/episodes?pageSize=2&pageNumber=1&sortBy=imdbRating";
        RestResponse restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.NotFound, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Genre not found", restResponse.Content);
    }

    [Fact]
    public void Test8_GetGenreSeries()
    {
        string url = "https://localhost/api/genre/Action/series?pageSize=2&pageNumber=1";
        RestResponse restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<MovieSchema>>(restResponse.Content);
        Assert.NotNull(body);
        Assert.NotNull(body[0].MovieId);
        Assert.NotNull(body[0].Title);
        Assert.NotNull(body[0].AverageRating);
        Assert.NotNull(body[0].ImdbRating);
        Assert.NotNull(body[0].Popularity);
    }

    [Fact]
    public void Test9_GetGenreSeries_Invalid()
    {
        var nonExistingGenreSqlInject = "与其不如";
        string url =
            $"https://localhost/api/genre/{nonExistingGenreSqlInject}/series?pageSize=2&pageNumber=1";
        RestResponse restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.NotFound, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Genre not found", restResponse.Content);
    }
}
