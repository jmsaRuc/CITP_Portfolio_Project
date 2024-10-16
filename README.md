# OMGdbApi

OMGdbApi is a .NET 8.0 web API project that uses PostgreSQL as its database. This project includes Docker support for easy deployment and development.

## Installation

### Prerequisites

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Docker](https://www.docker.com/get-started)

### Environment Variables

Create a `.env` file in the root directory with the following content:

./env_eksambel
```sh
OMGDB_POSTGRES_PASSWORD=**********
OMGDB_PGADMIN_DEFAULT_PASSWORD=fiskenfisksomvarenfisk123@
ASPNETCORE_ConnectionStrings_DefaultConnection='Host=host.docker.internal;Port=532;Database=OMGDB_db;Username=admin;Password=**********'
#for import script both in local, docker and external
OMGDB_POSTGRES_HOST=127.0.0.1
OMGDB_POSTGRES_PORT=5432
OMGDB_USERDATABASE=postgres
OMGDB_USER_PG=admin
PGPASSWORD=**************
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

- import the database backup files to the database
(works on the docker setup, as well as on remote postgres servers, just change the env variables in the .env file)

```sh
./import.sh
```
- test import (only works on this docker_compose setup, not on remote postgres  servers* needs pgtap to work)

```sh
./test.sh
```

- Delete import files
```sh
./delete_import.sh
```


## Project Structure

```sh
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
│   ├── script
│   │   ├── create-triggers
│   │   │   └── type-triggers.sql
│   │   ├── create_db
│   │   │   ├── create_db_draft1.sql
│   │   │   ├── create_db_draft2.sql
│   │   │   ├── create_db_final.sql
│   │   │   └── import_script.sql
│   │   └── user_functionality
│   │       └── user_function.sql
│   └── test
│       └── test_users.sql
├── docker-compose.yml
└── env_eksambel
```

## Project Configuration

- **Dockerfile:** Defines the Docker image for the project.
- **docker-compose.yml:** Defines the Docker services for the project.
- **appsettings.Development.json:** Configuration settings for the development environment.
- **OMGdbApi.csproj:** Project file for the .NET application.
- **OMGdbItemsController.cs:** Controller for the API endpoints.
- **OMGdbContext.cd.cs:** Database context class for Entity Framework.
- **OMGdbItem.cs:** Model class for the database table.
- **OMGdbApiMigration.cs:** Database migration file for Entity Framework.
- **OMGdbApiMigration.Designer.cs:** Database migration file for Entity Framework.
- **OMGdbContextModelSnapshot.cs:** Database migration file for Entity Framework.
- **launchSettings.json:** Configuration settings for launching the application.
- **import.sh:** Script for importing the database backup files.
- **test.sh:** Script for testing the database import.
- **delete_import.sh:** Script for deleting the import files.
- **create_db_draft1.sql:** SQL script for creating the database schema.
- **create_db_draft2.sql:** SQL script for creating the database schema.
- **create_db_final.sql:** SQL script for creating the database schema.
- **import_script.sql:** SQL script for importing the database backup files.
- **type-triggers.sql:** SQL script for creating triggers on the database tables.
- **user_function.sql:** SQL script for user functionality.
- **test_users.sql:** SQL script for testing the database import.

## API Endpoints

- **GET /api/OMGdbItems:** Get all items from the database.
- **GET /api/OMGdbItems/{id}:** Get an item by ID from the database.
- **POST /api/OMGdbItems:** Add an item to the database.
- **PUT /api/OMGdbItems/{id}:** Update an item by ID in the database.
- **DELETE /api/OMGdbItems/{id}:** Delete an item by ID from the database.

## Database Schema



## Technologies

- [.NET 8.0](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Entity Framework Core](https://docs.microsoft.com/en-us/ef/core/)
- [PostgreSQL](https://www.postgresql.org/)
- [Docker](https://www.docker.com/)
- [pgAdmin](https://www.pgadmin.org/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Docker Hub](https://hub.docker.com/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)


## License

This project is licensed under the MIT License.