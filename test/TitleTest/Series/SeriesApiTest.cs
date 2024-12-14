using System.Net;
using System.Text.Json;
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

    ///////////////////////////////////////////////////////////////////////series/{id}/genre////////////////////////////////////////////////////

    [Fact]
    public void Test7_GetSeriesGenre()
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
    public void Test8_GetSeriesGenreInvalid()
    {
        var invalID = "tt23452345";
        var url = $"https://localhost/api/series/{invalID}/genre";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Series dose not exist", restResponse.Content);
    }
}
