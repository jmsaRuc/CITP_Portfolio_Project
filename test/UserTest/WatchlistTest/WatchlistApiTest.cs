using System.Net;
using System.Text.Json;
using NuGet.Protocol;
using RestSharp;
using RestSharp.Authenticators;
using Xunit;
using Xunit.Abstractions;
using ServicePointManager = System.Net.ServicePointManager;
using test.UserTest;


using test.UserTest.WatchlistTest;

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
            var Authenticator = new JwtAuthenticator(bodyUser.Token!);
         
            var options = new RestClientOptions(url) { Authenticator = Authenticator };
            RestClient client = new RestClient(options);

            RestResponse restResponse = requestWatch.PostRestRequest(bodyUser.Token!, url, bodyUser.Id!);
            _testOutputHelper.WriteLine(restResponse.Content!);


            Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
            Assert.NotNull(restResponse.Content);
            var bodyWatchlistEpisode = JsonSerializer.Deserialize<WatchlistEpisodeSchema>(restResponse.Content!);
            Assert.NotNull(bodyWatchlistEpisode);
            Assert.Equal("tt0959621", bodyWatchlistEpisode.EpisodeId);


            //delete user
            userApiTests.Delet_User();
        }

        [Fact]
        public void Test2_CreateWatchlistEpisodeInvalid(){

            //create user
            userApiTests.Create_User();
            

            //login
            var bodyUser = userApiTests.Login();
            Assert.NotNull(bodyUser.Token);
        
            //create watchlist episode
            string url = "https://localhost/api/user/watchlist/episode";
            
            RestResponse restResponse = requestWatch.PostRestRequest(bodyUser.Token!, url, "1231231231312312313"!);
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

            RestResponse restResponse = requestWatch.PostRestRequest(bodyUser.Token!, url, bodyUser.Id!);
            _testOutputHelper.WriteLine(restResponse.Content!);

            Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
            Assert.NotNull(restResponse.Content);
            var bodyWatchlistEpisode = JsonSerializer.Deserialize<WatchlistEpisodeSchema>(restResponse.Content!);
            Assert.NotNull(bodyWatchlistEpisode);
            Assert.Equal("tt0959621", bodyWatchlistEpisode.EpisodeId);

            //delete watchlist episode
            string urlDelete = $"https://localhost/api/user/{bodyUser.Id}/watchlist/episode/{bodyWatchlistEpisode.EpisodeId}";
            RestResponse restResponseDelete = requestWatch.DeleteRestRequest(bodyUser.Token!, urlDelete, bodyUser.Id!);
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

            RestResponse restResponse = requestWatch.PostRestRequest(bodyUser.Token!, url, bodyUser.Id!);
            _testOutputHelper.WriteLine(restResponse.Content!);

            Assert.Equal(HttpStatusCode.Created, restResponse.StatusCode);
            Assert.NotNull(restResponse.Content);
            var bodyWatchlistEpisode = JsonSerializer.Deserialize<WatchlistEpisodeSchema>(restResponse.Content!);
            Assert.NotNull(bodyWatchlistEpisode);
            Assert.Equal("tt0959621", bodyWatchlistEpisode.EpisodeId);

            //delete watchlist episode
            string urlDelete = $"https://localhost/api/user/{bodyUser.Id}/watchlist/episode/123123123123123123";
            RestResponse restResponseDelete = requestWatch.DeleteRestRequest(bodyUser.Token!, urlDelete, bodyUser.Id!);
            _testOutputHelper.WriteLine(restResponseDelete.Content!);

            Assert.Equal(HttpStatusCode.BadRequest, restResponseDelete.StatusCode);
            Assert.NotNull(restResponseDelete.Content);
            //delete user
            userApiTests.Delet_User();
        } 
}
