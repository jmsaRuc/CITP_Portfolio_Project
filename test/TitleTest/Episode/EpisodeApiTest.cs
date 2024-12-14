using System.Net;
using System.Text.Json;
using OMGdbApi.Models;
using test.GenreTest;
using Xunit.Abstractions;

namespace test.TitleTest.Episode;

public class EpisodeApiTest
{
    private readonly ITestOutputHelper _testOutputHelper;

    public EpisodeApiTest(ITestOutputHelper testOutputHelper)
    {
        _testOutputHelper = testOutputHelper;
    }

    private readonly RequestClass request = new();

    ////////////////////////////////////////////////////////////////////episodes////////////////////////////////////////////////////

    [Fact]
    public void Test1_GetEpisodes()
    {
        var url = $"https://localhost/api/episode?pageSize=3&pageNumber=4";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<EpisodeSchema>>(restResponse.Content);

        Assert.NotNull(body);
        Assert.Equal(3, body.Count);
        Assert.NotNull(body[0].EpisodeId);
        Assert.NotNull(body[0].Title);
    }

    [Fact]
    public void Test2_GetEpisodesSortedImdb()
    {
        var url = $"https://localhost/api/episode?sortBy=imdbRating";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<EpisodeSchema>>(restResponse.Content);

        Assert.NotNull(body);
        Assert.NotNull(body[0].ImdbRating);
        Assert.True(body[0].ImdbRating >= body[1].ImdbRating);
    }

    [Fact]
    public void Test3_GetEpisodeId()
    {
        var url = $"https://localhost/api/episode/tt0959621";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<EpisodeSchema>(restResponse.Content);

        Assert.NotNull(body);
        Assert.Equal("tt0959621", body.EpisodeId);
        Assert.NotNull(body.Title);
    }

    [Fact]
    public void Test4_GetEpisodeIdInvalid()
    {
        var invalID = "tt0and0>1";
        var url = $"https://localhost/api/episode/{invalID}";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid title id", restResponse.Content);
    }

    ///////////////////////////////////////////////////////////////////////episode/{id}/actors////////////////////////////////////////////////////

    [Fact]
    public void Test5_GetEpisodeActors()
    {
        var url = $"https://localhost/api/episode/tt0959621/actors?pageSize=3&pageNumber=4";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<ActorSchema>>(restResponse.Content);

        Assert.NotNull(body);
        Assert.Equal(2, body.Count);
        Assert.NotNull(body[0].PersonId);
        Assert.NotNull(body[0].Name);
    }

    [Fact]
    public void Test6_GetEpisodeActorsInvalid()
    {
        var invalID = "tt23452345";
        var url = $"https://localhost/api/episode/{invalID}/actors";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Episode dose not exist", restResponse.Content);
    }

    ////////////////////////////////////////////////////////////////////episode/{id}/genre////////////////////////////////////////////////////

    [Fact]
    public void Test7_GetEpisodeGenre()
    {
        var url = $"https://localhost/api/episode/tt11753166/genre?pageSize=2&pageNumber=1";
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
    public void Test8_GetEpisodeGenreInvalid()
    {
        var invalID = "tt23452345";
        var url = $"https://localhost/api/episode/{invalID}/genre";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Episode dose not exist", restResponse.Content);
    }
}
