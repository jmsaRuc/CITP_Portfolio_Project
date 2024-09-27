using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CITP_Portfolio_Project.Models;

public class CITP_Portfolio_ProjectItem
{
    public long Id { get; set; }
    public string? Name { get; set; }
    public bool IsComplete { get; set; }


};