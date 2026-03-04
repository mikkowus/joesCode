from hello_world import hello_world
import service_weather
import requests

hello_world()

ithaca_weather = service_weather.weather(42.4406, -76.4966)

forecast = requests.get(ithaca_weather.get_forecast())

periods = forecast.json()["properties"]["periods"]

for detailedForecast in periods:
    print(detailedForecast["name"])
    print(detailedForecast["detailedForecast"])
