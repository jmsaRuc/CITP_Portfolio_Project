
using RestSharp;
using RestSharp.Authenticators;
using System.Text.Json;

namespace test.UserTest;

public class RequestClassUser
{

     


    public RestResponse GetFakeApiRequest(string token, string baseUrl, int? pageSize = null, int? pageNumber = null)
    {   

        var Url = baseUrl;
        if ((pageSize == null && pageNumber == null) || (pageSize == 0 && pageNumber == 0))
        {
            string pageParameterUrl = $"pageSize={pageSize}&pageNumber={pageNumber}";
            Url = $"{baseUrl}?{pageParameterUrl}"; 
        }
        
        var Authenticator = new JwtAuthenticator(token);
        var options = new RestClientOptions(Url) { Authenticator = Authenticator };
        RestClient client = new RestClient(options);

        RestRequest restRequest = new RestRequest(baseUrl, Method.Get);
        RestResponse restResponse = client.Execute(restRequest);

        return restResponse;
    }

        public RestResponse PostFakeApiRequest(string baseUrl)  
    {
        RestClient client = new RestClient(baseUrl);  
        var body = BuildBodyUser();  
        RestRequest restRequest = new RestRequest(baseUrl, Method.Post);  
        restRequest.AddBody(body, ContentType.Json);  

        RestResponse restResponse = client.Execute(restRequest);  

        return restResponse;  
    }


    public RestResponse PutFakeApiRequestUser(string id, string token)
    {   
        
        var user =(UserSchema)BuildBodyUser(id);
        string userNameUrl = Uri.EscapeDataString(user.Name!);
        string userEmailUrl = Uri.EscapeDataString(user.Email!);

        string StringUrl = $"name={userNameUrl}&email={userEmailUrl}";
        string baseUrl = $"https://localhost/api/user/{id}?{StringUrl}";

        var Authenticator = new JwtAuthenticator(token);
        var options = new RestClientOptions(baseUrl) {Authenticator = Authenticator};
        RestClient client = new RestClient(options);

        var restRequest = new RestRequest(baseUrl, Method.Put);
        RestResponse restResponse = client.Execute(restRequest);

        return restResponse;
    }

    public RestResponse DeleteFakeApiRequest(string token, string baseUrl)
    {   
        var Authenticator = new JwtAuthenticator(token);
        var options = new RestClientOptions(baseUrl) {Authenticator = Authenticator};
        RestClient client = new RestClient(options);

        RestRequest restRequest = new RestRequest(baseUrl, Method.Delete);
        RestResponse restResponse = client.Execute(restRequest);

        return restResponse;
    }

    public UserSchema GetBearerToken(UserSchema user)
    {   
        string userEmailUrl = Uri.EscapeDataString(user.Email!);
        string userPasswordUrl = Uri.EscapeDataString(user.Password!);

        string loginString = $"email={userEmailUrl}&loginPassword={userPasswordUrl}";
        string baseUrl = $"https://localhost/api/user/login?{loginString}";

        RestClient client = new RestClient(baseUrl);
        RestRequest restRequest = new RestRequest(baseUrl, Method.Put);
        RestResponse restResponse = client.Execute(restRequest);
        var body = JsonSerializer.Deserialize<UserSchema>(restResponse.Content!);
        return body!;
    }

    public static object BuildBodyUser(string? id = null)
    {     
        if (string.IsNullOrEmpty(id))
        {
            return new UserSchema
            {
                Name = "testuser",
                Email = "wupwup@gmail.com",
                Password = "Password123!"
            };
        }else return new UserSchema
        {   
            Id = id,
            Name = "testuser_new",
            Email = "wupwup@gmail.com"
        };
    }  


}
