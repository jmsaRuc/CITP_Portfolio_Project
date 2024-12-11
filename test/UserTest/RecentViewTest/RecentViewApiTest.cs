using System.Net;
using System.Text.Json;
using RestSharp;
using Xunit.Abstractions;

namespace test.UserTest.RecentViewTest;

public class RecentViewApiTest
{
    private readonly ITestOutputHelper _testOutputHelper;

    private readonly UserApiTests userApiTests;

    public RecentViewApiTest(ITestOutputHelper testOutputHelper)
    {
        _testOutputHelper = testOutputHelper;
        userApiTests = new(_testOutputHelper);
    }

    readonly RequestClass request = new();

    ////////////////////////////////////////////////////////////////////////////////recentview/////////////////////////////////////////////////////////////////////////////

    [Fact]
    public void Test1_CreateRecentView()
    {
        //Create a new user
        userApiTests.Create_User();

        //login the user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);
        Assert.NotNull(bodyUser.Id);

        //Create a new recent view
        string url = "https://localhost/api/user/recentview";

        var recentView = BuildBodyRecentView(bodyUser.Id);

        RestResponse restResponse = request.PostRestRequest(url, recentView, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<RecentViewSchema>(restResponse.Content);
        Assert.NotNull(body);
        _testOutputHelper.WriteLine(restResponse.Content);
        Assert.Equal(body.UserId, recentView.UserId);
        Assert.Equal(recentView.TypeId, body.TypeId);

        //Delete the user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test2_CreateRecentViewInvalid()
    {
        //Create a new user
        userApiTests.Create_User();

        //login the user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);
        Assert.NotNull(bodyUser.Id);

        //Create a new recent view
        string url = "https://localhost/api/user/recentview";

        var recentView = BuildBodyRecentView("1231231231312312313");

        RestResponse restResponse = request.PostRestRequest(url, recentView, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid UserId", restResponse.Content);

        //Delete the user and the recent view (when user is deleted, recentView is deleted too because of cascade)
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test3_GetRecentView()
    {
        //create a new user
        userApiTests.Create_User();

        //login the user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);
        Assert.NotNull(bodyUser.Id);

        //Create a new recent view
        var recentView = Create_RecentView(bodyUser);
        Assert.NotNull(recentView);

        //Get the recent view
        string url = $"https://localhost/api/user/{bodyUser.Id}/recentview/{recentView.TypeId}";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<RecentViewSchema>(restResponse.Content);
        Assert.NotNull(body);
        Assert.Equal(body.UserId, recentView.UserId);
        Assert.Equal(recentView.TypeId, body.TypeId);

        //Delete the user and the recent view (when user is deleted, recentView is deleted too because of cascade)
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test4_GetRecentViewInvalid()
    {
        //create a new user
        userApiTests.Create_User();

        //login the user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);
        Assert.NotNull(bodyUser.Id);

        //Create a new recent view
        var recentView = Create_RecentView(bodyUser);
        Assert.NotNull(recentView);

        //Get the recent view
        recentView.TypeId = "%02%03";
        string url = $"https://localhost/api/user/{bodyUser.Id}/recentview/{recentView.TypeId}";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid TypeId", restResponse.Content);

        //Delete the user and the recent view (when user is deleted, recentView is deleted too because of cascade)
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test5_DeleteRecentView()
    {
        //create a new user
        userApiTests.Create_User();

        //login the user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);
        Assert.NotNull(bodyUser.Id);

        //Create a new recent view
        var recentView = Create_RecentView(bodyUser);
        Assert.NotNull(recentView);

        //Delete the recent view
        string url = $"https://localhost/api/user/{bodyUser.Id}/recentview/{recentView.TypeId}";
        var restResponse = request.DeleteRestRequest(url, bodyUser, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Entity removed from recent view", restResponse.Content);

        //Delete the user
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test6_DeleteRecentViewInvalid()
    {
        //create a new user
        userApiTests.Create_User();

        //login the user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);
        Assert.NotNull(bodyUser.Id);

        //Create a new recent view
        var recentView = Create_RecentView(bodyUser);
        Assert.NotNull(recentView);

        //Delete the recent view
        var invalidUserId = "用户ID";
        string url = $"https://localhost/api/user/{invalidUserId}/recentview/{recentView.TypeId}";
        RestResponse restResponse = request.DeleteRestRequest(url, bodyUser, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid UserId", restResponse.Content);

        //Delete the user
        userApiTests.Delet_User();
    }

    ////////////////////////////////////////////////////////////////////////////////recentview/"ALL"////////////////////////////////////////////////////////////////////////////

    [Fact]
    public void Test6_GetRecentViewAll()
    {
        //create a new user
        userApiTests.Create_User();

        //login the user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);
        Assert.NotNull(bodyUser.Id);

        //Create a new recent view
        var recentView = Create_RecentView(bodyUser);
        Assert.NotNull(recentView);

        //Get the recent view
        string url = $"https://localhost/api/user/{bodyUser.Id}/recentview";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains(recentView.TypeId!, restResponse.Content);

        //Delete the user and the recent view (when user is deleted, recentView is deleted too because of cascade)
        userApiTests.Delet_User();
    }

    [Fact]
    public void Test7_GetRecentViewAllInvalid()
    {
        //create a new user
        userApiTests.Create_User();

        //login the user
        var bodyUser = userApiTests.Login();
        Assert.NotNull(bodyUser.Token);
        Assert.NotNull(bodyUser.Id);

        //Get the recent view
        string url = $"https://localhost/api/user/{bodyUser.Id}/recentview";
        var restResponse = request.GetRestRequest(url, bodyUser.Token);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.DoesNotContain("userId", restResponse.Content);
        Assert.DoesNotContain("typeId", restResponse.Content);
        Assert.DoesNotContain("viewOrdering", restResponse.Content);

        //Delete the user and the recent view (when user is deleted, recentView is deleted too because of cascade)
        userApiTests.Delet_User();
    }

    private static RecentViewSchema BuildBodyRecentView(string userId)
    {
        return new RecentViewSchema { UserId = userId, TypeId = "tt1596363" };
    }

    internal RecentViewSchema Create_RecentView(UserSchema user)
    {
        string url = "https://localhost/api/user/recentview";
        var recentView = BuildBodyRecentView(user.Id!);
        RestResponse restResponse = request.PostRestRequest(url, recentView, user.Token);
        var body = JsonSerializer.Deserialize<RecentViewSchema>(restResponse.Content!);
        return body!;
    }
}
