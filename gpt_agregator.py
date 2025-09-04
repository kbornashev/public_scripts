import json
import re
import requests
from bs4 import BeautifulSoup
import feedparser
import tkinter as tk
from tkinter import ttk, messagebox
SOURCES_FILE = "sources.json"
def load_sources():
    try:
        with open(SOURCES_FILE, "r") as file:
            return json.load(file)
    except FileNotFoundError:
        return []
def save_sources(sources):
    with open(SOURCES_FILE, "w") as file:
        json.dump(sources, file, indent=4)
def fetch_rss(url, pattern):
    feed = feedparser.parse(url)
    matches = []
    for entry in feed.entries:
        if re.search(pattern, entry.title, re.IGNORECASE) or re.search(pattern, entry.summary, re.IGNORECASE):
            matches.append({"title": entry.title, "link": entry.link})
    return matches
def scrape_website(url, pattern):
    try:
        response = requests.get(url)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, "html.parser")
        matches = []
        for element in soup.find_all(text=re.compile(pattern, re.IGNORECASE)):
            matches.append({"text": element.strip(), "url": url})
        return matches
    except requests.RequestException as e:
        print(f"Error fetching {url}: {e}")
        return []
def process_sources():
    sources = load_sources()
    all_matches = []
    for source in sources:
        url = source["url"]
        pattern = source["pattern"]
        print(f"Checking {url} with pattern '{pattern}'...")
        if url.endswith(".xml") or "rss" in url.lower():
            matches = fetch_rss(url, pattern)
        else:
            matches = scrape_website(url, pattern)
        all_matches.extend(matches)
    return all_matches
class NewsAggregatorApp:
    def __init__(self, root):
        self.root = root
        self.root.title("News Aggregator")
        self.sources = load_sources()

        main_frame = ttk.Frame(root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        self.source_listbox = tk.Listbox(main_frame, height=10, width=50)
        self.source_listbox.grid(row=0, column=0, rowspan=4, padx=5, pady=5, sticky=(tk.W, tk.E))
        self.update_source_list()

        ttk.Label(main_frame, text="URL:").grid(row=0, column=1, sticky=tk.W)
        self.url_entry = ttk.Entry(main_frame, width=40)
        self.url_entry.grid(row=0, column=2, padx=5, pady=5, sticky=tk.W)
        ttk.Label(main_frame, text="Pattern:").grid(row=1, column=1, sticky=tk.W)
        self.pattern_entry = ttk.Entry(main_frame, width=40)
        self.pattern_entry.grid(row=1, column=2, padx=5, pady=5, sticky=tk.W)
        ttk.Button(main_frame, text="Add Source", command=self.add_source).grid(row=2, column=2, padx=5, pady=5, sticky=tk.W)

        ttk.Button(main_frame, text="Check Sources", command=self.check_sources).grid(row=3, column=2, padx=5, pady=5, sticky=tk.W)

        ttk.Label(main_frame, text="Results:").grid(row=4, column=0, sticky=tk.W)
        self.results_text = tk.Text(main_frame, height=10, width=70)
        self.results_text.grid(row=5, column=0, columnspan=3, padx=5, pady=5, sticky=(tk.W, tk.E))
    def update_source_list(self):
        self.source_listbox.delete(0, tk.END)
        for source in self.sources:
            self.source_listbox.insert(tk.END, f"{source['url']} ({source['pattern']})")
    def add_source(self):
        url = self.url_entry.get().strip()
        pattern = self.pattern_entry.get().strip()
        if url and pattern:
            self.sources.append({"url": url, "pattern": pattern})
            save_sources(self.sources)
            self.update_source_list()
            self.url_entry.delete(0, tk.END)
            self.pattern_entry.delete(0, tk.END)
            messagebox.showinfo("Success", "Source added successfully.")
        else:
            messagebox.showwarning("Input Error", "Please provide both URL and pattern.")
    def check_sources(self):
        self.results_text.delete(1.0, tk.END)
        matches = process_sources()
        if matches:
            for match in matches:
                if "title" in match:
                    self.results_text.insert(tk.END, f"Title: {match['title']}\nLink: {match['link']}\n\n")
                else:
                    self.results_text.insert(tk.END, f"Text: {match['text']}\nURL: {match['url']}\n\n")
        else:
            self.results_text.insert(tk.END, "No matches found.\n")
if __name__ == "__main__":
    root = tk.Tk()
    app = NewsAggregatorApp(root)
    root.mainloop()
