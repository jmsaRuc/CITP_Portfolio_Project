using System.ComponentModel.DataAnnotations.Schema;

namespace OMGdbApi.Models;

public class Actor
{
    [Column("person_id_v")]
    public string? PersonId { get; set; }

    [Column("name_v")]
    public string? Name { get; set; }

    [Column("character_v")]
    public string? Character { get; set; }

    [Column("cast_order_v")]
    public long CastOrder { get; set; }
}
