import requests
def get_coordinates(address):
    url = "https://nominatim.openstreetmap.org/search"
    headers = {
        'User-Agent': 'address-to-coords-script/1.0 ()'
    }
    params = {
        'q': address,
        'format': 'json',
        'limit': 1
    }
    response = requests.get(url, params=params, headers=headers)
    response.raise_for_status()
    data = response.json()
    if not data:
        raise ValueError("Адрес не найден.")
    lat = data[0]['lat']
    lon = data[0]['lon']
    display_name = data[0]['display_name']
    return lat, lon, display_name
if __name__ == "__main__":
    try:
        user_input = input("Введите адрес: ").strip()
        lat, lon, full_name = get_coordinates(user_input)
        print(f"\n📍 Полный адрес: {full_name}")
        print(f"🧭 Координаты:\n  Широта: {lat}\n  Долгота: {lon}")
    except Exception as e:
        print(f"\n❌ Ошибка: {e}")
