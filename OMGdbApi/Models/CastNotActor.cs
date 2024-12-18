using System.ComponentModel.DataAnnotations.Schema;

namespace OMGdbApi.Models;

public class CastNotActor
{
    [Column("person_id_v")]
    public string? PersonId { get; set; }

    [Column("name_v")]
    public string? Name { get; set; }

    [Column("role_v")]
    public string? Role { get; set; }

    [Column("job_v")]
    public string? Job { get; set; }

    [Column("cast_order_v")]
    public long CastOrder { get; set; }
}
