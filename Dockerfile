FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build-env
WORKDIR /app


# https://andrewlock.net/optimising-asp-net-core-apps-in-docker-avoiding-manually-copying-csproj-files-part-2/
COPY *.sln ./
#COPY Client/Client.csproj ./Client/Client.csproj
#COPY Api/Api.csproj ./Api/Api.csproj
#COPY Shared/Shared.csproj ./Shared/Shared.csproj
COPY */*.csproj ./
RUN for file in $(ls *.csproj); do mkdir -p ${file%.*}/ && mv $file ${file%.*}/; done
RUN dotnet restore

COPY . .

WORKDIR /app/Client/
RUN dotnet publish -c Release -o output


FROM nginx:alpine AS final
WORKDIR /usr/share/nginx/index/
# matches up with the root i nginx.conf
WORKDIR /var/www/web
COPY --from=build-env /app/Client/output/wwwroot .
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80