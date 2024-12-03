using System.Text.Json.Serialization;

namespace test.UserTest.WatchlistTest;

public class WatchlistEpisodeSchema
{   
    [JsonPropertyName("userId")]
    public string? UserId { get; set; }

    [JsonPropertyName("episodeId")]
    public string? EpisodeId { get; set; }

    [JsonPropertyName("watchlist_order")]
    public long? Watchlist_order { get; set; }
}
