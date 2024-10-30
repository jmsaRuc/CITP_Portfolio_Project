﻿using System;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.BlazorIdentity.Pages.Manage;

namespace OMGdbApi.Models
{
    [Table("person")]
    public class Person
    {
        [Column("person_id")]
        public string? Id { get; set; }

        [Column("name")]
        public string? Name { get; set; }

        [Column("birth_year")]
        public string? BirthYear { get; set; }

        [Column("death_year")]
        public string? DeathYear { get; set; }

        [Column("primary_profession")]
        public string? PrimaryProfession { get; set; }

    }
}
