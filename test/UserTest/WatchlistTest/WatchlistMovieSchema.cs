using System;
using System.Text.Json.Serialization;
namespace test.UserTest.WatchlistTest;

public class WatchlistMovieSchema
{
    [JsonPropertyName("userId")]
    public string? UserId { get; set; }

    [JsonPropertyName("movieId")]
    public string? MovieId { get; set; }

    [JsonPropertyName("watchlist_order")]
    public long? Watchlist_order { get; set; }

}
