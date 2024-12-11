using System.Text.Json.Serialization;

namespace test.UserTest.RatingsTest;

public class RatingsEpisodeSchema
{
    [JsonPropertyName("userId")]
    public string? UserId { get; set; }

    [JsonPropertyName("episodeId")]
    public string? EpisodeId { get; set; }

    [JsonPropertyName("rating")]
    public short? Rating { get; set; }
}
