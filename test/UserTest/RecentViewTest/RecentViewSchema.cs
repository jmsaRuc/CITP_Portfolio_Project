using System.Text.Json.Serialization;

namespace test.UserTest.RecentViewTest;

public class RecentViewSchema
{
    [JsonPropertyName("userId")]
    public string? UserId { get; set; }

    [JsonPropertyName("typeId")]
    public string? TypeId { get; set; }

    [JsonPropertyName("viewOrdering")]
    public long? ViewOrdering { get; private set; }

    [JsonPropertyName("createdAt")]
    public DateTime? CreatedAt { get; private set; }
}
