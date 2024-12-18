using System.Text.Json.Serialization;

namespace test.TitleTest.Series;

public class SeriesEpisodeSchema
{
    [JsonPropertyName("episodeId")]
    public string? EpisodeId { get; set; }

    [JsonPropertyName("title")]
    public string? Title { get; set; }

    [JsonPropertyName("poster")]
    public string? Poster { get; set; }

    [JsonPropertyName("plot")]
    public string? Plot { get; set; }

    [JsonPropertyName("releaseDate")]
    public DateTime? ReleaseDate { get; set; }

    [JsonPropertyName("seasonNumber")]
    public long SeasonNumber { get; set; }

    [JsonPropertyName("episodeNumber")]
    public long EpisodeNumber { get; set; }

    [JsonPropertyName("averageRating")]
    public decimal AverageRating { get; set; }

    [JsonPropertyName("imdbRating")]
    public decimal ImdbRating { get; set; }

    [JsonPropertyName("popularity")]
    public long Popularity { get; set; }
}
