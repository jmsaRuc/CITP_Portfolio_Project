using System.Net;
using System.Text.Json;
using Xunit.Abstractions;
namespace test.TitleTest.Person;

public class PersonApiTest
{
    private readonly ITestOutputHelper _testOutputHelper;

    public PersonApiTest(ITestOutputHelper testOutputHelper)
    {
        _testOutputHelper = testOutputHelper;
    }

    private readonly RequestClass request = new();

    ////////////////////////////////////////////////////////////////////person////////////////////////////////////////////////////

    [Fact]
    public void Test1_GetPersons(){

        var url = $"https://localhost/api/person?pageSize=3&pageNumber=4";
        var restResponse = request.GetRestRequest(url);
        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<List<PersonSchema>>(restResponse.Content);

        Assert.NotNull(body);
        Assert.Equal(3, body.Count);
        Assert.NotNull(body[0].PersonId);
        Assert.NotNull(body[0].Name);
        
    }

    [Fact]
    public void Test2_GetPersonId(){

        var url = $"https://localhost/api/person/nm0186505";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.OK, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        var body = JsonSerializer.Deserialize<PersonSchema>(restResponse.Content);

        Assert.NotNull(body);
        Assert.Equal("nm0186505", body.PersonId);
        Assert.NotNull(body.Name);
    
        
    }

    [Fact]
    public void Test3_GetPersonIdInvalid(){
        var invalID = "nm0and0>1";
        var url = $"https://localhost/api/person/{invalID}";

        var restResponse = request.GetRestRequest(url);

        _testOutputHelper.WriteLine(restResponse.Content);

        Assert.Equal(HttpStatusCode.BadRequest, restResponse.StatusCode);
        Assert.NotNull(restResponse.Content);
        Assert.Contains("Invalid person id", restResponse.Content);
    }
}