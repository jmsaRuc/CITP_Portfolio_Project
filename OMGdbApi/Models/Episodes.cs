using System;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.BlazorIdentity.Pages.Manage;

namespace OMGdbApi.Models
{
    [Table("episodes")]
    public class Episodes
    {
        [Column("episode_id")]
        public string? Id { get; set; }

        [Column("Title")]
        public string? Title { get; set; }

        [Column("re_year")]
        public string? ReleaseYear { get; set; }

        [Column("run_time")]

        public string? RunTime { get; set; }

        [Column("plot")]

        public string? Plot { get; set; }

        [Column("Language")]

        public string? Language { get; set; }

        [Column("relese_date")]

        public DateTime? ReleaseDate { get; set; }

        [Column("imdb_rating")]

        public decimal? ImdbRating { get; set; }

        [Column("ordering")]

        public int? Ordering { get; set; }

    }
}
