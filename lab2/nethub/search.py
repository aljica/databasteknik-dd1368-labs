from tkinter import *
from nethub_db import NethubDB
from tkinter import ttk
from history import History

class Search:

    def set_category_search(self):
        category = self.chosen_category.get() # Search by movies or series?
        self.db.set_category(category)

    def conduct_search(self):
        search_type = self.search_type.get() # Which search type has the user chosen?

        if search_type == "Genre":
            genre = self.genre_choice.get() # Search by THIS genre.
            self.db.genre_search(genre)

        elif search_type == "Actor":
            actor = self.actor_field.get()
            self.db.actor_search(actor)

        elif search_type == "Director":
            director = self.director_field.get()
            self.db.director_search(director)

        elif search_type == "Language":
            language = self.language_field.get()
            self.db.language_search(language)

        elif search_type == "Title":
            title = self.title_field.get()
            self.db.title_search(title)

        elif search_type == "Rating":
            rating = self.rating_choice.get()
            self.db.rating_search(rating)

        elif search_type == "Remaining":
            number = int(self.remaining_field.get())
            self.db.remaining_episodes_search(number)

        self.print_search_result()

    def print_search_result(self):
        result = self.db.get_result()
        self.text_prompt.delete(0.0, END)
        self.text_prompt.insert(0.0, result)

    def clear_text_prompt(self):
        self.text_prompt.delete(0.0, END)
        self.actor_field.delete(0, END)
        self.director_field.delete(0, END)
        self.language_field.delete(0, END)
        self.title_field.delete(0, END)
        #self.rating_field.delete(0, END)
        #self.db.query = "SELECT * FROM USERS"
        #self.db.execute_query() # Not sure if this is necessary to "reset", but we might as well have it.

    def view_history(self):
        window = Tk()
        history = History(window)
        window.mainloop()

    def __init__(self, root):

        root.title("Nethub Search")
        root.geometry("672x650")
        root.resizable(width=False, height=False)

        # Initialize NetHub database
        self.db = NethubDB()

        # ---------------- Customizing style for widgets -------------------

        style = ttk.Style()
        style.configure("Button", font="Serif 15", padding=0)

        # ------------------- Radio buttons ----------------------- #

        # --- Choose movies or series search --- #
        self.chosen_category = StringVar(value="Movies")

        self.movies = ttk.Radiobutton(root, text="Movies", variable=self.chosen_category,
            value="Movies", command=self.set_category_search)
        self.movies.place(x=0,y=0)

        self.series = ttk.Radiobutton(root, text="Series", variable=self.chosen_category,
            value="Series", command=self.set_category_search)
        self.series.place(x=100,y=0)

        # --- Choose search type (search by genre, actor or director etc...) --- #
        # Variables to keep track of (by user) chosen search type
        self.search_type = StringVar(value="")

        # --- HANDLE GENRE --- #
        # Button to activate genre search type:
        self.genre_btn = ttk.Radiobutton(root, text="Genre", variable=self.search_type,
            value="Genre")
        self.genre_btn.place(x=250,y=170)

        # Drop-down menu for genres
        self.genres = ["Crime", "Comedy", "Romance", "Action", "Thriller", "Horror", "Drama"]
        self.genre_choice = StringVar()
        self.genre_choice.set(self.genres[0])

        self.genre_menu = ttk.OptionMenu(root, self.genre_choice, self.genres[0], *self.genres)
        self.genre_menu.place(x=250,y=190)

        # --- HANDLE ACTOR --- #
        # Button
        self.actor_btn = ttk.Radiobutton(root, text="Actor", variable=self.search_type,
            value="Actor")
        self.actor_btn.place(x=0, y=50)

        # Entry field
        # self.actor_field.get() to fetch value from entry field (self.actor_field, see below)
        self.actor_field = ttk.Entry(root, width=15)
        self.actor_field.place(x=0, y=70)

        # --- HANDLE DIRECTOR --- #
        # Button
        self.director_btn = ttk.Radiobutton(root, text="Director", variable=self.search_type,
            value="Director")
        self.director_btn.place(x=0, y=110)

        # Entry field
        self.director_field = ttk.Entry(root, width=15)
        self.director_field.place(x=0, y=130)

        # --- HANDLE LANGUAGE --- #
        # Button
        self.language_btn = ttk.Radiobutton(root, text="Language", variable=self.search_type,
            value="Language")
        self.language_btn.place(x=150, y=110)

        # Entry field
        self.language_field = ttk.Entry(root, width=15)
        self.language_field.place(x=150, y=130)

        # --- HANDLE TITLE --- #
        # Button
        self.title_btn = ttk.Radiobutton(root, text="Title", variable=self.search_type,
            value="Title")
        self.title_btn.place(x=0, y=170)

        # Entry field
        self.title_field = ttk.Entry(root, width=15)
        self.title_field.place(x=0, y=190)

        # --- HANDLE RATING --- #
        # Drop-down menu
        self.ratings = [0, 1, 2, 3, 4, 5]

        self.rating_choice = IntVar()
        self.rating_choice.set(self.ratings[0])

        self.rating_btn = ttk.Radiobutton(root, text="Rating", variable=self.search_type,
            value="Rating")
        self.rating_btn.place(x=150, y=170)

        self.rating_menu = ttk.OptionMenu(root, self.rating_choice, *self.ratings)
        self.rating_menu.place(x=150, y=190)

        # --- HANDLE REMAINING EPISODES --- #
        # Button
        self.remaining_btn = ttk.Radiobutton(root, text="Remaining Episodes",
            variable=self.search_type, value="Remaining")
        self.remaining_btn.place(x=150, y=50)

        # Entry field
        self.remaining_field = ttk.Entry(root, width=15)
        self.remaining_field.place(x=150, y=70)

        # ---------------------------- Perform search -----------------------------#
        # Text prompt
        self.text_prompt = Text(root, width=83, height=18)
        self.text_prompt.place(x=0,y=300)
        #self.scroll_bar = Scrollbar(root, command=self.text_prompt.yview)
        #self.scroll_bar.place(x=500, y=200)

        # Search button
        self.search = ttk.Button(root, text="Search", command=self.conduct_search)
        self.search.place(x=0, y=270)

        # Clear button
        self.clear = ttk.Button(root, text="Clear", command=self.clear_text_prompt)
        self.clear.place(x=0, y=620)

        # History button
        self.history = ttk.Button(root, text="View History", command=self.view_history)
        self.history.place(x=575, y=620)
