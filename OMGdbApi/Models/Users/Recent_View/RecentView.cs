
using System.ComponentModel.DataAnnotations.Schema;
namespace OMGdbApi.Models.Users.Recent_View;

[Table("recent_view")]
public class RecentView
{
    [Column("user_id")]
    public required string UserId { get; set; }

    [Column("type_id")]
    public required string TypeId { get; set; }

    [Column("view_ordering")]
    public long? ViewOrdering { get; private set; }

}
