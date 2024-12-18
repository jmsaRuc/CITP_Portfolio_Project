using System.Text.Json.Serialization;

namespace test.TitleTest;

public class CastNotActorSchema
{
    [JsonPropertyName("personId")]
    public string? PersonId { get; set; }

    [JsonPropertyName("name")]
    public string? Name { get; set; }

    [JsonPropertyName("role")]
    public string? Role { get; set; }

    [JsonPropertyName("job")]
    public string? Job { get; set; }

    [JsonPropertyName("castOrder")]
    public long? CastOrder { get; set; }
}
