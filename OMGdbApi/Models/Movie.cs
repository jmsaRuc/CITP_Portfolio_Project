﻿using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.BlazorIdentity.Pages.Manage;

namespace OMGdbApi.Models;

[Table("movie")]

    public class Movie
    {
        [Key]
        [Column("movie_id")]
        public string? Id { get; set; }

        [Column("title")]
        public string? Title { get; set; }

        [Column("re_year")]
        public string? ReleaseYear { get; set; }

        [Column("run_time")]
        public string? RunTime { get; set; }

        [Column("poster")]
        public string? Poster { get; set; }

        [Column("plot")]
        public string? Plot { get; set; }

        [Column("release_date")]
        public DateTime? ReleaseDate { get; set; }

        [Column("imdb_rating")]
        public decimal? ImdbRating { get; set; }

        [Column("popularity")]
        public int? Ordering { get; set; }
    }

