using System.Net;
using System.Text.Json;
using test.GenreTest;
using Xunit.Abstractions;

namespace test.TitleTest.Movie;

public class MovieApiTest
{
    private readonly ITestOutputHelper _testOutputHelper;

    public MovieApiTest(ITestOutputHelper testOutputHelper)
    {
        _testOutputHelper = testOutputHelper;
    }

    private readonly RequestClass request = new();

    ////////////////////////////////////////////////////////////////////movie////////////////////////////////////////////////////

    [Fact]
    public void Test1_GetMovies()
    {
        var url = $"https://localhost/api/movie?pageSize=3&pageNumber=4";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<MovieSchema>>(restResponse.Content);

        Assert.NotNull(body);
        Assert.Equal(3, body.Count);
        Assert.NotNull(body[0].MovieId);
        Assert.NotNull(body[0].Title);
    }

    [Fact]
    public void Test2_GetMoviesSortedImdb()
    {
        var url = $"https://localhost/api/movie?sortBy=imdbRating";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<MovieSchema>>(restResponse.Content);

        Assert.NotNull(body);
        Assert.NotNull(body[0].ImdbRating);
        Assert.True(body[0].ImdbRating >= body[1].ImdbRating);
    }

    [Fact]
    public void Test3_GetMovieId()
    {
        var url = $"https://localhost/api/movie/tt1596363";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<MovieSchema>(restResponse.Content);

        Assert.NotNull(body);
        Assert.Equal("tt1596363", body.MovieId);
        Assert.NotNull(body.Title);
    }

    [Fact]
    public void Test4_GetMovieIdInvalid()
    {
        var invalID = "tt0and0>1";
        var url = $"https://localhost/api/movie/{invalID}";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid title id", restResponse.Content);
    }

    ///////////////////////////////////////////////////////////////////////movie/{id}/actors////////////////////////////////////////////////////

    [Fact]
    public void Test5_GetMovieActors()
    {
        var url = $"https://localhost/api/movie/tt1596363/actors?pageSize=3&pageNumber=4";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<ActorSchema>>(restResponse.Content);

        Assert.NotNull(body);
        Assert.Equal(3, body.Count);
        Assert.NotNull(body[0].PersonId);
        Assert.NotNull(body[0].Name);
    }

    [Fact]
    public void Test6_GetMovieActorsInvalid()
    {
        var invalID = "tt20877972";
        var url = $"https://localhost/api/movie/{invalID}/actors";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Movie does not exist", restResponse.Content);
    }

    ////////////////////////////////////////////////////////////////////movie/{id}/genre////////////////////////////////////////////////////

    [Fact]
    public void Test7_GetMovieGenre()
    {
        var url = $"https://localhost/api/movie/tt0936501/genre?pageSize=2&pageNumber=1";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<GenreSchema>>(restResponse.Content);

        Assert.NotNull(body);
        Assert.Equal(2, body.Count);
        Assert.NotNull(body[0].GenreName);
        Assert.Contains(body[0].GenreName!, "Action");
    }

    [Fact]
    public void Test8_GetMovieGenreInvalid()
    {
        var sqlInjec = "tt0936501or1=1";
        var url = $"https://localhost/api/movie/{sqlInjec}/genre";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid title id", restResponse.Content);
    }
}
