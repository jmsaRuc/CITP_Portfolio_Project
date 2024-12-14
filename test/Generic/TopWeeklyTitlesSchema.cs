using System.Text.Json.Serialization;

namespace test.Generic;

public class TopWeeklyTitlesSchema
{
    [JsonPropertyName("titleId")]
    public string? TitleId { get; set; }

    [JsonPropertyName("titleType")]
    public string? TitleType { get; set; }

    [JsonPropertyName("title")]
    public string? Title { get; set; }

    [JsonPropertyName("poster")]
    public string? Poster { get; set; }

    [JsonPropertyName("averageRating")]
    public decimal AverageRating { get; set; }

    [JsonPropertyName("imdbRating")]
    public decimal ImdbRating { get; set; }

    [JsonPropertyName("popularity")]
    public long Popularity { get; set; }

    [JsonPropertyName("dailyTimeStampFromRecentV")]
    public DateTime DailyTimeStampFromRecentV { get; set; }
}
