
# OMGdbApi

OMGdbApi is a .NET 8.0 web API project that uses PostgreSQL as its database. This project includes Docker support for easy deployment and development.

## Project Structure

```
.
├── .gitignore
├── Dockerfile
├── OMGdbApi
│   ├── Controllers
│   │   └── OMGdbItemsController.cs
│   ├── Migrations
│   │   ├── 20240927142856_OMGdbApiMigration.Designer.cs
│   │   ├── 20240927142856_OMGdbApiMigration.cs
│   │   └── OMGdbContextModelSnapshot.cs
│   ├── Models
│   │   ├── OMGdbContext.cd.cs
│   │   └── OMGdbItem.cs
│   ├── OMGdbApi.csproj
│   ├── OMGdbApi.http
│   ├── Program.cs
│   ├── Properties
│   │   └── launchSettings.json
│   ├── appsettings.Development.json
│   └── appsettings.json
├── OMGdbApi.sln
├── README.md
├── blueprint
│   └── excalidraw
│       └── main_excali.excalidraw
├── db
│   ├── import_backup
│   └── script
│       └── create_db.sql
├── docker-compose.yml
└── env_eksambel
```

## Getting Started

### Prerequisites

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Docker](https://www.docker.com/get-started)

### Environment Variables

Create a `.env` file in the root directory with the following content:

```env
OMGDB_POSTGRES_PASSWORD=your_postgres_password 
OMGDB_PGADMIN_DEFAULT_PASSWORD=your_pgadmin_password 
ASPNETCORE_ConnectionStrings_DefaultConnection='Host=host.docker.internal;Port=5532;Database=OMGDB_db;Username=admin;Password=<your_postgres_password>'
```

### Building and Running the Project

1. **Build the Docker containers:**

    ```sh
    docker compose --env-file .env build
    ```

2. **Run the Docker containers:**

    ```sh
    docker compose --env-file .env up -d
    ```

3. **Access the API:**

    The API will be available at `http://localhost:8080`.

4. **Access pgAdmin:**

    pgAdmin will be available at `http://localhost:5550`. Use the email `admin@OMGDB.com` and the password specified in your `.env` file.

### Database Migrations

To apply the latest migrations, run the following command:

```sh
dotnet ef database update
```
### PSql backup import

```sh
psql -h 127.0.0.1 -p 5532 -d import_for_portf_1 -U admin -W -a -f db/import_backup/imdb.backup
```
## Project Configuration

- **Dockerfile:** Defines the Docker image for the project.
- **docker-compose.yml:** Defines the Docker services for the project.
- **appsettings.Development.json:** Configuration settings for the development environment.
- **OMGdbApi.csproj:** Project file for the .NET application.

## Code Structure

- **Controllers:** Contains the API controllers.
- **Migrations:** Contains the Entity Framework Core migrations.
- **Models:** Contains the data models and the database context.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License.