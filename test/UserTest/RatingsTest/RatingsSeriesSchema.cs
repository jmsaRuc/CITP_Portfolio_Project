using System.Text.Json.Serialization;

namespace test.UserTest.RatingsTest;

public class RatingsSeriesSchema
{
    [JsonPropertyName("userId")]
    public string? UserId { get; set; }

    [JsonPropertyName("seriesId")]
    public string? SeriesId { get; set; }

    [JsonPropertyName("rating")]
    public short? Rating { get; set; }
}
