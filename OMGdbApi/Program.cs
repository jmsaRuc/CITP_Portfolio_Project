using Microsoft.EntityFrameworkCore;

using OMGdbApi;
using OMGdbApi.Models;
using OMGdbApi.Service;


var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
builder.Services.AddSingleton(new Hashing());
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var Configuration = builder.Configuration;
string connection = Environment.GetEnvironmentVariable("ASPNETCORE_ConnectionStrings_DefaultConnection") ?? string.Empty;
builder.Services.AddDbContext<OMGdbContext>(options =>
        options.UseNpgsql(connection));

var app = builder.Build();

// Configure the HTTP request pipeline.

app.UseSwagger();
app.UseSwaggerUI();


app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
