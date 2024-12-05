using System.Text.Json.Serialization;

namespace test.TitleTest.Person;

public class PersonSchema
{
    [JsonPropertyName("id")]
    public string? PersonId { get; set; }

    [JsonPropertyName("name")]
    public string? Name { get; set; }

    [JsonPropertyName("birthYear")]
    public string? BirthYear { get; set; }

    [JsonPropertyName("deathYear")]
    public string? DeathYear { get; set; }

    [JsonPropertyName("primaryProfession")]
    public string? PrimaryProfession { get; set; }

    [JsonPropertyName("popularity")]
    public long? Popularity { get; set; }

}

