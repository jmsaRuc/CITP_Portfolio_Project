using System.Net;
using System.Text.Json;
using NuGet.Protocol;
using RestSharp;
using RestSharp.Authenticators;
using Xunit;
using Xunit.Abstractions;
using ServicePointManager = System.Net.ServicePointManager;

[assembly: CollectionBehavior(DisableTestParallelization = true)]

namespace test.UserTest
{
    public class UserApiTests
    {
        private readonly ITestOutputHelper _testOutputHelper;

        public UserApiTests(ITestOutputHelper testOutputHelper)
        {
            _testOutputHelper = testOutputHelper;
        }

        readonly RequestClassUser request = new();

        private UserSchema user = new UserSchema();

        internal UserSchema Login()
        {
            var user = (UserSchema)RequestClassUser.BuildBodyUser();
            var body = request.GetBearerToken(user);
            return body;
        }
        internal void Create_User()
        {
            string url = "https://localhost/api/user/create";
            RestResponse response = request.PostFakeApiRequest(url);
        }

        internal void Delet_User()
        {
            var body = Login();

            RestResponse response = request.DeleteFakeApiRequest(
                body.Token!,
                $"https://localhost/api/user/{body.Id}"
            );
        }

        [Fact]
        public void Test1_CreateUser()
        {
            //create user
            string url = "https://localhost/api/user/create";
            RestResponse response = request.PostFakeApiRequest(url);

            Assert.Equal(HttpStatusCode.Created, response.StatusCode);

            var body = JsonSerializer.Deserialize<UserSchema>(response.Content!);
            Assert.NotNull(body);

            var user = (UserSchema)RequestClassUser.BuildBodyUser();
            Assert.Equal(user.Name, body.Name);
            Assert.Equal(user.Email, body.Email);
            Assert.NotNull(body.Id);

            //test


            //delet user
            user = (UserSchema)RequestClassUser.BuildBodyUser();
            user.Name = "testuser_new";
            body = request.GetBearerToken(user);
            Assert.NotNull(body.Token);

            response = request.DeleteFakeApiRequest(
                body.Token,
                $"https://localhost/api/user/{body.Id}"
            );
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
            Assert.NotNull(response.Content);
        }

        [Fact]
        public void Test2_CreateUserInvalid()
        {
            //create user
            Create_User();

            //test
            string url = "https://localhost/api/user/create";
            RestResponse response = request.PostFakeApiRequest(url);
            Assert.Equal(HttpStatusCode.Conflict, response.StatusCode);

            //delet user
            Delet_User();
        }

        [Fact]
        public void Test3_GetTokenValid()
        {
            //create user
            Create_User();

            //test

            var body = Login();
            Assert.NotNull(body.Token);

            Assert.False(string.IsNullOrEmpty(body.Token));
            Assert.Matches(@"^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+$", body.Token);

            //delet user
            Delet_User();
        }

        [Fact]
        public void Test4_GetTokenInValid()
        {
            //create user
            Create_User();

            //test
            var user = (UserSchema)RequestClassUser.BuildBodyUser();

            user.Password = "alskjdfnbaslkjdfnsalkjn";

            var body = request.GetBearerToken(user);

            Assert.True(string.IsNullOrEmpty(body.Token));

            //delet user
            Delet_User();
        }

        [Fact]
        public void Test5_GetUser()
        {
            //create user
            Create_User();

            //test
            var body = Login();
            Assert.NotNull(body.Token);
            RestResponse response = request.GetFakeApiRequest(
                body.Token,
                "https://localhost/api/user", 10, 1
            );
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
            Assert.NotNull(response.Content);

            //delet user
            Delet_User();
        }

        [Fact]
        public void Test6_GetUserIdValid()
        {   
            //create user
            Create_User();

            //test
            var tokenBody = Login();
            Assert.NotNull(tokenBody.Token);
            RestResponse response = request.GetFakeApiRequest(
                tokenBody.Token,
                $"https://localhost/api/user/{tokenBody.Id}"
            );
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            var body = JsonSerializer.Deserialize<UserSchema>(response.Content!);
            Assert.NotNull(body);
            Assert.Equal(tokenBody.Id, body.Id);

            //delet user
            Delet_User();
        }

        [Fact]
        public void Test7_GetUserIdInvalid()
        {   
            //create user
            Create_User();

            //test
            var tokenBody = Login();
            Assert.NotNull(tokenBody.Token);
            RestResponse response = request.GetFakeApiRequest(
                tokenBody.Token,
                "https://localhost/api/user/invalid-id"
            );
            Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);

            //delet user
            Delet_User();
        }

        [Fact]
        public void Test8_PutUserValid()
        {   
            //create user
            Create_User();

            //test
            var user = (UserSchema)RequestClassUser.BuildBodyUser();
            var tokenBody = request.GetBearerToken(user);
            Assert.NotNull(tokenBody.Token);
            Assert.NotNull(tokenBody.Id);

            RestResponse response = request.PutFakeApiRequestUser(tokenBody.Id, tokenBody.Token);
            Assert.Equal(HttpStatusCode.Created, response.StatusCode);
            var body = JsonSerializer.Deserialize<UserSchema>(response.Content!);

            Assert.NotNull(body);
            Assert.Equal(tokenBody.Id, body.Id);
            Assert.NotEqual(user.Name, body.Name);
            Assert.Equal(user.Email, body.Email);

            //delet user
            user = (UserSchema)RequestClassUser.BuildBodyUser();
            user.Name = "testuser";
            body = request.GetBearerToken(user);

            response = request.DeleteFakeApiRequest(
                body.Token,
                $"https://localhost/api/user/{body.Id}"
            );
        }

        [Fact]
        public void Test9_PutUserInvalid()
        {   
            //create user
            Create_User();

            //test
            var tokenBody = Login();
            Assert.NotNull(tokenBody.Token);
            RestResponse response = request.PutFakeApiRequestUser("invalid-id", tokenBody.Token);
            Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);

            //delet user
            Delet_User();
        }

        [Fact]
        public void Test10_DeletUserValid()
        {   
            //create user
            Create_User();

            //test
            var user = (UserSchema)RequestClassUser.BuildBodyUser();
            user.Name = "testuser_new";
            var body = request.GetBearerToken(user);
            Assert.NotNull(body.Token);

            RestResponse response = request.DeleteFakeApiRequest(
                body.Token,
                $"https://localhost/api/user/{body.Id}"
            );
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
            Assert.NotNull(response.Content);
        }

        [Fact]
        public void Test11_DeletUserInValid()
        {   
            //create user
            Create_User();

            //test
            var user = (UserSchema)RequestClassUser.BuildBodyUser();
            user.Name = "testuser_new";
            var body = request.GetBearerToken(user);
            Assert.NotNull(body.Token);

            RestResponse response = request.DeleteFakeApiRequest(
                "invalid-token",
                $"https://localhost/api/user/{body.Id}"
            );
            Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);

            //delet user
            Delet_User();
        }
    }
}
