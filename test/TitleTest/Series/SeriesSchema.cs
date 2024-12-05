
using System.Text.Json.Serialization;

namespace test.TitleTest.Series;

public class SeriesSchema
{
    [JsonPropertyName("id")]
    public string? SeriesId { get; set; }

    [JsonPropertyName("title")]
    public string? Title { get; set; }

    [JsonPropertyName("startYear")]
    public string? StartYear { get; set; }

    [JsonPropertyName("endYear")]
    public string? EndYear { get; set; }

    [JsonPropertyName("poster")]
    public string? Poster { get; set; }

    [JsonPropertyName("plot")]
    public string? Plot { get; set; }

    [JsonPropertyName("averageRating")]
    public decimal? AverageRating { get; set; }

    [JsonPropertyName("imdbRating")]
    public decimal? ImdbRating { get; set; }

    [JsonPropertyName("popularity")]
    public long? Popularity { get; set; }

}