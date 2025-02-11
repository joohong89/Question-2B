#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 80
ENV RABBITMQ_HOST localhost
ENV RABBITMQ_PORT 5672 
ENV ASPNETCORE_URLS=http://*:5000
ENV ASPNETCORE_ENVIRONMENT=Development

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["api-producer.csproj", "."]
RUN dotnet restore "./api-producer.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "api-producer.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "api-producer.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "api-producer.dll"]