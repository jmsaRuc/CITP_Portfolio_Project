using System.Reflection;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using OMGdbApi.Models;
using OMGdbApi.Service;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
var AllowSpecificOrigins = Environment.GetEnvironmentVariable("OMGDB_AllOWED_ORIGENS") ?? "*";

var MyAllowSpecificOrigins = "_myAllowSpecificOrigins";

builder.Services.AddCors(options =>
{
    options.AddPolicy(
        name: MyAllowSpecificOrigins,
        policy =>
        {
            policy.WithOrigins(AllowSpecificOrigins).AllowAnyHeader().AllowAnyMethod();
            ;
        }
    );
});
builder.Services.AddControllers();
builder.Services.AddSingleton(new Hashing());
builder.Services.AddSingleton(new ValidateIDs());
var secret = Environment.GetEnvironmentVariable("JWT_SECRET");
if (string.IsNullOrEmpty(secret))
{
    var rng = new Random();
    var bytes = new byte[32];
    rng.NextBytes(bytes);
    secret = Convert.ToBase64String(bytes);
}
builder
    .Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = false,
            ValidateAudience = false,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret)),
        };
    });
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(opt =>
{
    opt.SwaggerDoc(
        "v1",
        new OpenApiInfo
        {
            Title = "OMGDB API",
            Version = "v0.1.0",
            Description =
                "The OMGDB API provides endpoints for interacting with the OMGDB database."
                + " It uses JWT authentication for securing the endpoints and supports CORS for specified origins.",
        }
    );
    opt.AddSecurityDefinition(
        "Bearer",
        new OpenApiSecurityScheme
        {
            In = ParameterLocation.Header,
            Description = "Please enter token",
            Name = "Authorization",
            Type = SecuritySchemeType.Http,
            BearerFormat = "JWT",
            Scheme = "bearer",
        }
    );

    opt.AddSecurityRequirement(
        new OpenApiSecurityRequirement
        {
            {
                new OpenApiSecurityScheme
                {
                    Reference = new OpenApiReference
                    {
                        Type = ReferenceType.SecurityScheme,
                        Id = "Bearer",
                    },
                },
                new string[] { }
            },
        }
    );

    var xmlFilename = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    opt.IncludeXmlComments(Path.Combine(AppContext.BaseDirectory, xmlFilename));
});

var Configuration = builder.Configuration;
string connection =
    Environment.GetEnvironmentVariable("ASPNETCORE_ConnectionStrings_DefaultConnection")
    ?? string.Empty;
if (string.IsNullOrEmpty(connection))
{
    throw new Exception("Connection string is not set");
}
builder.Services.AddDbContext<OMGdbContext>(options => options.UseNpgsql(connection));

var app = builder.Build();

// Configure the HTTP request pipeline.

app.UseSwagger(c =>
{
    c.RouteTemplate = "api/docs/{documentname}/swagger.json";
});

app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/api/docs/v1/swagger.json", "OMGDB API v0.1.0");
    c.RoutePrefix = "api/docs";
});

app.UseHttpsRedirection();

app.UseCors(MyAllowSpecificOrigins);

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();

public partial class Program { }
