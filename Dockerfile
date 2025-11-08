# ===========================================
# 1️⃣ BUILD STAGE
# ===========================================
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Cài Node.js (Render cần build React bên trong .NET publish)
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Copy toàn bộ source
COPY . .

# Restore dependencies
RUN dotnet restore "./src/Web/Web.csproj"

# Publish dự án ở chế độ Release
RUN dotnet publish "./src/Web/Web.csproj" -c Release -o /app/publish

# ===========================================
# 2️⃣ RUNTIME STAGE
# ===========================================
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Copy output từ build stage
COPY --from=build /app/publish .

# Render sẽ tự ánh xạ port 8080
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# Entry point
ENTRYPOINT ["dotnet", "backend.Web.dll"]
