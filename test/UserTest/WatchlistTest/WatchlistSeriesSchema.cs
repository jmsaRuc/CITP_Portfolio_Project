using System;
using System.Text.Json.Serialization;
namespace test.UserTest.WatchlistTest;

public class WatchlistSeriesSchema
{
    [JsonPropertyName("userId")]
    public string? UserId { get; set; }

    [JsonPropertyName("seriesId")]
    public string? SeriesId { get; set; }

    [JsonPropertyName("watchlist_order")]
    public long? Watchlist_order { get; set; }

}
