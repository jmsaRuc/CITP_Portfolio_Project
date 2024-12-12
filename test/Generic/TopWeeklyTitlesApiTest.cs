using System.Net;
using System.Text.Json;
using OMGdbApi.Models.Users;
using RestSharp;
using test.UserTest;
using test.UserTest.RecentViewTest;
using Xunit.Abstractions;

namespace test.Generic;

public class TopWeeklyTitlesApiTest
{
    private readonly ITestOutputHelper _testOutputHelper;

    private readonly UserApiTests userApiTests;
    private readonly RecentViewApiTest recentViewApiTest;

    public TopWeeklyTitlesApiTest(ITestOutputHelper testOutputHelper)
    {
        _testOutputHelper = testOutputHelper;
        recentViewApiTest = new(_testOutputHelper);
        userApiTests = new(_testOutputHelper);
    }

    readonly RequestClass request = new();

    ///////////////////////////////////////////////topWeeklyTitles////////////////////////////////////////////////////

    [Fact]
    public void Test1_GetTopWeeklyTitles()
    {
        //Create a new user
        userApiTests.Create_User();

        //login the user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);
        Assert.NotNull(bodyUser.Id);

        //Create a new recent view
        recentViewApiTest.Test1_CreateRecentView();

        //Get top weekly titles
        string url = "https://localhost/api/topweekly";

        RestResponse restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<TopWeeklyTitlesSchema>>(restResponse.Content);
        Assert.NotNull(body);
        Assert.NotNull(body[0].TitleId);
        Assert.NotNull(body[0].TitleType);
        Assert.NotNull(body[0].Title);
        //Delete the user
        userApiTests.Delet_User();
    }
}
