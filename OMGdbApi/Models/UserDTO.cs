using System;
using System.Text.Json.Serialization;
namespace OMGdbApi.Models;

public class UserDTO
{   
    [JsonPropertyName("id")]
    public string? Id { get; set; }
    
    [JsonPropertyName("name")]
    public string? Name { get; set; }

    [JsonPropertyName("email")]
    public string? Email { get; set; }
    
    [JsonPropertyName("created_at")]
    public DateTime Created_at { get; set; }
}
