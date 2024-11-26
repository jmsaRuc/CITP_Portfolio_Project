using System.Text.Json.Serialization;

namespace test.UserTest.RatingsTest;

public class RatingsMovieSchema
{
    [JsonPropertyName("userId")]
    public string? UserId { get; set; }

    [JsonPropertyName("movieId")]
    public string? MovieId { get; set; }

    [JsonPropertyName("rating")]
    public short? Rating { get; set; }
}
