using System;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.BlazorIdentity.Pages.Manage;

namespace OMGdbApi.Models;
[Table("user")]
public class User
{   

    [Column("user_id")]
    public string? Id { get; set; }

    [Column("username")]
    public string? Name { get; set; }

    [Column("password")]
    public byte[]? Password { get; set; }

    [Column("salt")]
    public byte[]? Salt { get; set; }

    [Column("email")]
    public string? Email { get; set; }

    [Column("created_at")]
    public DateTime? Created_at { get; set; }

}