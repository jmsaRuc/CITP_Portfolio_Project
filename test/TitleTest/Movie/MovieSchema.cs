using System.Text.Json.Serialization;

namespace test.TitleTest.Movie;

public class MovieSchema
{
    [JsonPropertyName("id")]
    public string? MovieId { get; set; }

    [JsonPropertyName("title")]
    public string? Title { get; set; }

    [JsonPropertyName("releaseYear")]
    public string? ReleaseYear { get; set; }

    [JsonPropertyName("runTime")]
    public string? RunTime { get; set; }

    [JsonPropertyName("poster")]

    public string? Poster { get; set; }

    [JsonPropertyName("plot")]

    public string? Plot { get; set; }

    [JsonPropertyName("releaseDate")]

    public DateTime? ReleaseDate { get; set; }

    [JsonPropertyName("averageRating")]

    public decimal? AverageRating { get; set; }

    [JsonPropertyName("imdbRating")]

    public decimal? ImdbRating { get; set; }

    [JsonPropertyName("popularity")]

    public long? Popularity { get; set; }

}