using System.Net;
using System.Text.Json;
using OMGdbApi.Models;
using test.GenreTest;
using Xunit.Abstractions;

namespace test.TitleTest.Series;

public class SeriesApiTest
{
    private readonly ITestOutputHelper _testOutputHelper;

    public SeriesApiTest(ITestOutputHelper testOutputHelper)
    {
        _testOutputHelper = testOutputHelper;
    }

    private readonly RequestClass request = new();

    ////////////////////////////////////////////////////////////////////series////////////////////////////////////////////////////

    [Fact]
    public void Test1_GetSeriess()
    {
        var url = $"https://localhost/api/series?pageSize=3&pageNumber=4";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<SeriesSchema>>(restResponse.Content);

        Assert.NotNull(body);
        Assert.Equal(3, body.Count);
        Assert.NotNull(body[0].SeriesId);
        Assert.NotNull(body[0].Title);
    }

    [Fact]
    public void Test2_GetSeriessSortedImdb()
    {
        var url = $"https://localhost/api/series?sortBy=imdbRating";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<SeriesSchema>>(restResponse.Content);

        Assert.NotNull(body);
        Assert.NotNull(body[0].ImdbRating);
        Assert.True(body[0].ImdbRating >= body[1].ImdbRating);
    }

    [Fact]
    public void Test3_GetSeriesId()
    {
        var url = $"https://localhost/api/series/tt20877972";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<SeriesSchema>(restResponse.Content);

        Assert.NotNull(body);
        Assert.Equal("tt20877972", body.SeriesId);
        Assert.NotNull(body.Title);
    }

    [Fact]
    public void Test4_GetSeriesIdInvalid()
    {
        var invalID = "tt0and0>1";
        var url = $"https://localhost/api/series/{invalID}";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid title id", restResponse.Content);
    }

    ///////////////////////////////////////////////////////////////////////series/{id}/actors////////////////////////////////////////////////////

    [Fact]
    public void Test5_GetSeriesActors()
    {
        var url = $"https://localhost/api/series/tt20877972/actors?pageSize=3&pageNumber=4";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<ActorSchema>>(restResponse.Content);
        int one = 1;
        Assert.NotNull(body);
        Assert.Equal(one, body.Count);
        Assert.NotNull(body[0].PersonId);
        Assert.NotNull(body[0].Name);
    }

    [Fact]
    public void Test6_GetSeriesActorsInvalid()
    {
        var invalID = "tt1596363";
        var url = $"https://localhost/api/series/{invalID}/actors";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Series dose not exist", restResponse.Content);
    }

    ///////////////////////////////////////////////////////////////////////series/{id}/creators////////////////////////////////////////////////////

    [Fact]
    public void Test7_GetSeriesCreators()
    {
        var url = $"https://localhost/api/series/tt11247158/creators?pageSize=1&pageNumber=1";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<CastNotActorSchema>>(restResponse.Content);
        Assert.NotNull(body);
        Assert.NotNull(body[0].PersonId);
        Assert.NotNull(body[0].Name);
        Assert.NotNull(body[0].CastOrder);
    }

    [Fact]
    public void Test8_GetSeriesCreatorsInvalid()
    {
        var invalID = "tt23452345";
        var url = $"https://localhost/api/series/{invalID}/creators";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Series dose not exist", restResponse.Content);
    }

    ///////////////////////////////////////////////////////////////////////series/{id}/writers////////////////////////////////////////////////////

    [Fact]
    public void Test9_GetSeriesWriters()
    {
        var url = $"https://localhost/api/series/tt0944947/writers?pageSize=2&pageNumber=1";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<CastNotActorSchema>>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Equal(2, body.Count);
        Assert.NotNull(body[0].PersonId);
        Assert.NotNull(body[0].Name);
        Assert.NotNull(body[0].CastOrder);
    }

    [Fact]
    public void Test10_GetSeriesWritersInvalid()
    {
        var invalID = "tt23452232";
        var url = $"https://localhost/api/series/{invalID}/writers";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Series dose not exist", restResponse.Content);
    }

    ///////////////////////////////////////////////////////////////////////series/{id}/genre////////////////////////////////////////////////////

    [Fact]
    public void Test11_GetSeriesGenre()
    {
        var url = $"https://localhost/api/series/tt11247158/genre?pageSize=2&pageNumber=1";
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
    public void Test12_GetSeriesGenreInvalid()
    {
        var invalID = "tt23452345";
        var url = $"https://localhost/api/series/{invalID}/genre";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Series dose not exist", restResponse.Content);
    }

    ///////////////////////////////////////////////////////////////////////series/{id}/episode////////////////////////////////////////////////////
    ///
    [Fact]
    public void Test13_GetSeriesEpisodeSortSeason_p1()
    {
        var url = $"https://localhost/api/series/tt0944947/episode?seasonNumber=1";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<SeriesEpisodeSchema>>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Equal(11, body.Count);
        Assert.NotNull(body[0].EpisodeId);
        Assert.NotNull(body[0].Title);
        Assert.Equal(1, body[0].SeasonNumber);
        Assert.Equal(0, body[0].EpisodeNumber);
    }

    [Fact]
    public void Test14_GetSeriesEpisodeSortSeason_p2()
    {
        var url = $"https://localhost/api/series/tt0944947/episode?seasonNumber=7";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<SeriesEpisodeSchema>>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Equal(7, body.Count);
        Assert.NotNull(body[0].EpisodeId);
        Assert.NotNull(body[0].Title);
        Assert.Equal(7, body[0].SeasonNumber);
        Assert.Equal(1, body[0].EpisodeNumber);
    }

    [Fact]
    public void Test15_GetSeriesEpisodeSortSeason_p3_testpageConstraints()
    {
        var url =
            $"https://localhost/api/series/tt0944947/episode?pageSize=2&pageNumber=4&seasonNumber=7";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<SeriesEpisodeSchema>>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Equal(7, body.Count);
        Assert.NotNull(body[0].EpisodeId);
        Assert.NotNull(body[0].Title);
        Assert.Equal(7, body[0].SeasonNumber);
        Assert.Equal(1, body[0].EpisodeNumber);
    }

    [Fact]
    public void Test16_GetSeriesEpisodeSortSeason_p4_InvalidSeasonNumber()
    {
        var url =
            $"https://localhost/api/series/tt0944947/episode?pageSize=2&pageNumber=1&seasonNumber=20";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.NotFound, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<object>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Contains("This series dose not have this season number", restResponse.Content);
    }

    [Fact]
    public void Test17_GetSeriesEpisode()
    {
        var url = $"https://localhost/api/series/tt0944947/episode?pageSize=2&pageNumber=1";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<SeriesEpisodeSchema>>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Equal(2, body.Count);
        Assert.NotNull(body[0].EpisodeId);
        Assert.NotNull(body[0].Title);
        Assert.Equal(1, body[0].SeasonNumber);
        Assert.Equal(0, body[0].EpisodeNumber);
    }

    [Fact]
    public void Test18_GetSeriesEpisodeSort()
    {
        var url =
            $"https://localhost/api/series/tt0944947/episode?pageSize=2&pageNumber=1&sortBy=imdbRating";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<SeriesEpisodeSchema>>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Equal(2, body.Count);
        Assert.NotNull(body[0].EpisodeId);
        Assert.NotNull(body[0].Title);
        Assert.NotEqual(1, body[0].SeasonNumber);
        Assert.NotEqual(0, body[0].EpisodeNumber);
        Assert.Contains("Battle of the Bastards", body[0].Title);
    }
}
