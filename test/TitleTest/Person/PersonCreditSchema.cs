using System.Text.Json.Serialization;

namespace test.TitleTest.Person;

public class PersonCreditSchema
{
    [JsonPropertyName("titleId")]
    public string? TitleId { get; set; }

    [JsonPropertyName("title")]
    public string? Title { get; set; }

    [JsonPropertyName("titleType")]
    public string? TitleType { get; set; }

    [JsonPropertyName("poster")]
    public string? Poster { get; set; }

    [JsonPropertyName("character")]
    public string? Character { get; set; }

    [JsonPropertyName("imdbRating")]
    public decimal ImdbRating { get; set; }

    [JsonPropertyName("releaseYear")]
    public string? ReleaseYear { get; set; }

    [JsonPropertyName("popularity")]
    public long Popularity { get; set; }
}
