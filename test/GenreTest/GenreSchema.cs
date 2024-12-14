using System.Text.Json.Serialization;

namespace test.GenreTest;

public class GenreSchema
{
    [JsonPropertyName("genreName")]
    public string? GenreName { get; set; }

    [JsonPropertyName("episodeAmount")]
    public int? EpisodeAmount { get; set; }

    [JsonPropertyName("movieAmount")]
    public int? MovieAmount { get; set; }

    [JsonPropertyName("seriesAmount")]
    public int? SeriesAmount { get; set; }

    [JsonPropertyName("totalAmount")]
    public int? TotalAmount { get; set; }
}
