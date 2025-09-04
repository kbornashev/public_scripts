def add_to_past_sprints(self, widget):
    start = self.start_time_entry.get_text()
    stop = self.stop_time_entry.get_text()
    task = self.task_entry.get_text()
    if not (start and stop and task):
        self.show_message("Все поля должны быть заполнены.")
        return

    try:
        start_time = datetime.strptime(start, "%H:%M")
        stop_time = datetime.strptime(stop, "%H:%M")
    except ValueError:
        self.show_message("Введите время в формате ЧЧ:ММ.")
        return

    current_date = datetime.now().strftime("%d.%m.%Y")

    entries = []
    if stop_time < start_time:  # Если задача пересекает полночь

        end_of_day = datetime.strptime("23:45", "%H:%M")
        entries.append(f"- {end_of_day.strftime('%H:%M')} - {task}")

        next_day = (datetime.now() + timedelta(days=1)).strftime("%d.%m.%Y")
        next_start_time = datetime.strptime("00:00", "%H:%M")
        stop_time += timedelta(minutes=15)  # Добавляем 15 минут

        entries.append(f"{next_day}\n{next_start_time.strftime('%H:%M')} - {stop_time.strftime('%H:%M')} - {task}")
    else:

        entries.append(f"- {stop_time.strftime('%H:%M')} - {task}")

    if not os.path.exists(PAST_SPRINT_FILE):
        entries.insert(0, f"{current_date}\n")  # Добавляем дату, если файла ещё нет
    try:
        with open(PAST_SPRINT_FILE, "a") as file:
            file.write("\n".join(entries) + "\n")
        self.show_message("Запись добавлена в архив.")
        self.start_time_entry.set_text("")
        self.stop_time_entry.set_text("")
        self.task_entry.set_text("")
    except Exception as e:
        self.show_message(f"Ошибка: {str(e)}")
