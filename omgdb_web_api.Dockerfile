FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY *.sln .
COPY OMGdbApi/*.csproj ./OMGdbApi/
RUN dotnet restore

# copy everything else and build app
COPY OMGdbApi/. ./OMGdbApi/
WORKDIR /source/OMGdbApi
RUN dotnet publish -c release -o /app

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app ./

ENTRYPOINT ["dotnet", "OMGdbApi.dll"]