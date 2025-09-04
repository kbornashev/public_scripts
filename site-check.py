import tkinter as tk
import requests
from threading import Thread, Event
import os
import re
from urllib.parse import urlparse
import json
import time
SITES_FILE = "sites_list.txt"
TEMPLATES_FILE = "templates.json"
if os.path.exists(TEMPLATES_FILE):
    with open(TEMPLATES_FILE, "r") as file:
        TEMPLATES = json.load(file)
else:
    TEMPLATES = {}
stop_event = Event()
def load_sites():
    """Загрузить сайты из файла."""
    if os.path.exists(SITES_FILE):
        with open(SITES_FILE, "r") as file:
            return [line.strip() for line in file.readlines() if line.strip()]
    return []
def save_sites(sites):
    """Сохранить список сайтов в файл."""
    with open(SITES_FILE, "w") as file:
        file.write("\n".join(sites))
def save_templates():
    """Сохранить шаблоны в файл."""
    with open(TEMPLATES_FILE, "w") as file:
        json.dump(TEMPLATES, file, indent=4)
def is_valid_url(url):
    """Проверить, является ли URL валидным."""
    parsed = urlparse(url)
    return bool(parsed.netloc) and bool(parsed.scheme)
def monitor_sites():

    for widget in status_frame.winfo_children():
        widget.destroy()

    sites = load_sites()

    for site in sites:
        label = tk.Label(status_frame, text=f"{site}...", anchor="w")
        label.pack(fill="x")
        Thread(target=check_site_status, args=(site, label)).start()
def check_site_status(site, label):
    try:
        if not is_valid_url(site):
            label.config(text=f"{site} недействительный URL", bg="orange", fg="black")
            return
        response = requests.get(site, timeout=5)
        if response.status_code == 200:
            try:
                data = response.json()
                template = TEMPLATES.get(site, {"status": "ok", "message": "Сайт работает корректно"})
                if all(key in data for key in template.keys()):
                    label.config(text=f"{site} доступен", bg="green", fg="white")
                else:
                    label.config(text=f"{site} доступен, но отсутствуют ключи шаблона", bg="yellow", fg="black")
            except ValueError:
                label.config(text=f"{site} доступен, но не возвращает JSON", bg="yellow", fg="black")
        else:
            label.config(text=f"{site} недоступен (код: {response.status_code})", bg="red", fg="white")
    except requests.exceptions.RequestException:
        label.config(text=f"{site} недоступен", bg="red", fg="white")
def add_site():
    site = site_entry.get().strip()
    if site:
        if not is_valid_url(site):
            message_label.config(text="Введите корректный URL (например, https://example.com).", fg="red")
            return
        sites = load_sites()
        if site not in sites:
            sites.append(site)
            save_sites(sites)
            update_site_list()
            site_entry.delete(0, "end")
            message_label.config(text="Сайт добавлен.", fg="green")
        else:
            message_label.config(text="Сайт уже существует в списке.", fg="orange")
def configure_template():
    site = selected_site.get()
    if not site:
        message_label.config(text="Выберите сайт для настройки шаблона.", fg="red")
        return
    template_window = tk.Toplevel(root)
    template_window.title(f"Настройка шаблона для {site}")
    template_window.geometry("400x300")
    tk.Label(template_window, text=f"Введите JSON-шаблон для {site}:").pack(pady=10)
    template_entry = tk.Text(template_window, wrap="word", height=10)
    template_entry.insert("1.0", json.dumps(TEMPLATES.get(site, {"status": "ok", "message": "Сайт работает корректно"}), indent=4))
    template_entry.pack(fill="both", expand=True, padx=10, pady=10)
    def save_template():
        try:
            TEMPLATES[site] = json.loads(template_entry.get("1.0", "end").strip())
            save_templates()
            template_window.destroy()
            message_label.config(text="Шаблон успешно обновлён.", fg="green")
        except Exception as e:
            message_label.config(text=f"Ошибка в шаблоне: {e}", fg="red")
    save_button = tk.Button(template_window, text="Сохранить", command=save_template)
    save_button.pack(pady=10)
def periodic_check(interval=60):
    while not stop_event.is_set():
        monitor_sites()
        time.sleep(interval)
def start_periodic_check():
    stop_event.clear()
    Thread(target=periodic_check, daemon=True).start()
def stop_periodic_check():
    stop_event.set()
def search_sites():
    pattern = search_entry.get().strip()
    if not pattern:
        message_label.config(text="Введите регулярное выражение для поиска.", fg="red")
        return
    try:
        regex = re.compile(pattern)
    except re.error:
        message_label.config(text="Некорректное регулярное выражение.", fg="red")
        return
    matching_sites = [site for site in load_sites() if regex.search(site)]

    for widget in status_frame.winfo_children():
        widget.destroy()
    if matching_sites:
        for site in matching_sites:
            label = tk.Label(status_frame, text=f"{site}...", anchor="w")
            label.pack(fill="x")
            Thread(target=check_site_status, args=(site, label)).start()
        message_label.config(text=f"Найдено совпадений: {len(matching_sites)}", fg="green")
    else:
        message_label.config(text="Совпадений не найдено.", fg="red")
def reset_search():
    search_entry.delete(0, "end")
    message_label.config(text="")
    monitor_sites()
def update_site_list():
    site_list['menu'].delete(0, 'end')
    for site in load_sites():
        site_list['menu'].add_command(label=site, command=tk._setit(selected_site, site))
root = tk.Tk()
root.title("Мониторинг доступности сайтов")
root.geometry("600x500")
input_frame = tk.Frame(root)
input_frame.pack(fill="x", padx=10, pady=10)
tk.Label(input_frame, text="Добавить сайт для мониторинга:").pack(anchor="w")
site_entry = tk.Entry(input_frame)
site_entry.pack(fill="x", pady=5)
add_button = tk.Button(input_frame, text="Добавить сайт", command=add_site)
add_button.pack(side="left", padx=5)
selected_site = tk.StringVar()
selected_site.set("")
site_list = tk.OptionMenu(input_frame, selected_site, *load_sites())
site_list.pack(side="left", padx=5)
template_button = tk.Button(input_frame, text="Настроить шаблон", command=configure_template)
template_button.pack(side="left", padx=5)
start_button = tk.Button(input_frame, text="Начать проверку", command=start_periodic_check)
start_button.pack(side="left", padx=5)
stop_button = tk.Button(input_frame, text="Остановить проверку", command=stop_periodic_check)
stop_button.pack(side="left", padx=5)
search_frame = tk.Frame(root)
search_frame.pack(fill="x", padx=10, pady=10)
tk.Label(search_frame, text="Поиск сайтов (регулярное выражение):").pack(anchor="w")
search_entry = tk.Entry(search_frame)
search_entry.pack(fill="x", pady=5)
search_button = tk.Button(search_frame, text="Искать", command=search_sites)
search_button.pack(side="left", padx=5)
reset_button = tk.Button(search_frame, text="Сброс", command=reset_search)
reset_button.pack(side="left", padx=5)
message_label = tk.Label(search_frame, text="", anchor="w")
message_label.pack(fill="x")
status_frame = tk.Frame(root, bg="white", relief="sunken", bd=1)
status_frame.pack(fill="both", expand=True, padx=10, pady=10)
tk.Label(status_frame, text="Статус проверки будет отображён здесь", bg="white", anchor="w").pack(fill="x")
monitor_sites()
update_site_list()
root.mainloop()
