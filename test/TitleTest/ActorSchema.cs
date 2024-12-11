using System.Text.Json.Serialization;

namespace test.TitleTest;

public class ActorSchema
{
    [JsonPropertyName("personId")]
    public string? PersonId { get; set; }

    [JsonPropertyName("name")]
    public string? Name { get; set; }

    [JsonPropertyName("character")]
    public string? Character { get; set; }

    [JsonPropertyName("castOrder")]
    public long? CastOrder { get; set; }
}
