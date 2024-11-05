FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY *.sln .
COPY OMGdbApi/*.csproj ./OMGdbApi/
COPY test/*.csproj ./test/
RUN dotnet restore

# copy everything else and build app
COPY OMGdbApi/. ./OMGdbApi/
COPY test/. ./test/
WORKDIR /source/OMGdbApi
RUN dotnet publish -c release -o /app 

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app ./
COPY --from=build /source/test ./test

ENTRYPOINT ["dotnet", "OMGdbApi.dll"]