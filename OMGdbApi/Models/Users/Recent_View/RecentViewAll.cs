
using System.ComponentModel.DataAnnotations.Schema;

namespace OMGdbApi.Models.Users.Recent_View;

public class RecentViewAll
{
    [Column("type_id_of")]
    public string? TypeId { get; set; }

    [Column("type")]
    public string? Type { get; set; }

    [Column("title_of")]
    public string? Title { get; set; }

    [Column("poster_of")]
    public string? Poster { get; set; }

    [Column("average_r")]
    public decimal? AverageRating { get; set; }
    
    [Column("imdb_r")]
    public decimal? ImdbRating { get; set; }

    [Column("view_order")]
    public long? ViewOrdering { get; set; }
}
