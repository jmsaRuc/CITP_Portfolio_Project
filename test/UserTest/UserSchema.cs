using System;
using System.Text.Json.Serialization;

namespace test.UserTest;

public class UserSchema 
{
    [JsonPropertyName("id")]
    public string? Id { get; set; }
    [JsonPropertyName("name")]
    public string? Name { get; set; }

    [JsonPropertyName("email")]
    public string? Email { get; set; }

    [JsonPropertyName("password")]
    public string? Password { get; set; }

    [JsonPropertyName("token")]
    public string? Token { get; set; }
    
    [JsonPropertyName("created_at")]
    public DateTime? Created_at { get; set; }

}
