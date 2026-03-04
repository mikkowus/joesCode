import requests

class weather:
    """
    Weather returns the weather report of any lat,long

    https://api.weather.gov/points/{latitude},{longitude}
    """
    def __init__(self, latitude, longitude):
        self.grid_url = f"https://api.weather.gov/points/{latitude},{longitude}"

    def get_forecast(self):
        response = requests.get(self.grid_url)
        return response.json()['properties']['forecast']
