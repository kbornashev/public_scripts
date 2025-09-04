import tkinter as tk
from tkinter import simpledialog, messagebox
import os
output_path = "/home/bo/bookmarks/vocabular/eng-ru.md"
def get_text(prompt):
    root = tk.Tk()
    root.withdraw()  # Скрыть основное окно
    user_input = simpledialog.askstring("Ввод данных", prompt)
    if user_input is None:
        messagebox.showinfo("Отмена", "Ввод данных отменен.")
        exit()
    return user_input
english_words = get_text("Введите английские слова (каждое с новой строки):")
russian_words = get_text("Введите русские слова (каждое с новой строки):")
english_list = [word.strip() for word in english_words.splitlines()]
russian_list = [word.strip() for word in russian_words.splitlines()]
if len(english_list) != len(russian_list):
    messagebox.showerror("Ошибка", "Количество английских и русских слов не совпадает!")
    exit()
table = "| English Word        | Russian Translation          |\n"
table += "|---------------------|------------------------------|\n"
for eng, rus in zip(english_list, russian_list):
    table += f"| {eng:<20} | {rus:<30} |\n"
os.makedirs(os.path.dirname(output_path), exist_ok=True)
with open(output_path, "a", encoding="utf-8") as f:
    f.write("\n" + table)
messagebox.showinfo("Успех", f"Словарь успешно сохранен в {output_path}")
