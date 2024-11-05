using System.Text.Json.Serialization;

namespace test.UserTest;
class CreateUser
{
    [JsonPropertyName("name")]
    public string? Name { get; set; }

    [JsonPropertyName("password")]
    public string? Password { get; set; }
    [JsonPropertyName("email")]
    public string? Email { get; set; }
}