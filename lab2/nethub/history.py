from tkinter import *
from nethub_db import NethubDB
from tkinter import ttk

class History:

    def view_history(self):
        result = self.db.view_history()
        self.print_search_result(result)

    def print_search_result(self, result):
        self.text_prompt.delete(0.0, END)
        self.text_prompt.insert(0.0, result)

    def clear_text_prompt(self):
        self.text_prompt.delete(0.0, END)

    def execute_update(self):
        title = self.media_choice.get()
        rating = self.rating_choice.get()
        for i in range(len(self.media_choices)):
            if title == self.media_choices[i]:
                idx = self.media_choices.index(title)
        id = self.media_ids[idx]
        self.db.perform_update(id, rating)

    def __init__(self, root):

        root.title("Nethub History")
        root.geometry("452x422")
        root.resizable(width=False, height=False)

        self.db = NethubDB()

        style = ttk.Style()
        style.configure("Button", font="Serif 15", padding=0)

        #####----- Drop-down menu to choose already rated media to re-rate -----#####
        self.movie_data, self.episodes_data = self.db.get_rated_media()

        # Fixing the data...
        self.media_ids = []
        self.media_choices = []
        for i in range(len(self.movie_data)):
            element = self.movie_data[i]
            self.media_ids.append(element[0])
            self.media_choices.append(element[1])
        for j in range(len(self.episodes_data)):
            element = self.episodes_data[j]
            self.media_ids.append(element[0])
            self.media_choices.append(element[1])

        self.media_choice = StringVar()
        #self.media_choices.append("None") # Need this because otherwise the drop-down messes up
        #idx = self.media_choices.index("None")
        self.media_choice.set(self.media_choices[0])

        self.media_menu = ttk.OptionMenu(root, self.media_choice, self.media_choices[0], *self.media_choices)
        self.media_menu.place(x=105, y=0)

        self.media_label = ttk.Label(root, text="Choose media:")
        self.media_label.place(x=0, y=5)

        ########----- Drop-down menu to choose new rating ------#########
        self.ratings = [0, 1, 2, 3, 4, 5]

        self.rating_choice = IntVar()
        self.rating_choice.set(self.ratings[0])

        self.rating_menu = ttk.OptionMenu(root, self.rating_choice, *self.ratings)
        self.rating_menu.place(x=105, y=40)

        self.rating_label = ttk.Label(root, text="Choose rating:")
        self.rating_label.place(x=0, y=45)

        #####----- Update button -----######
        self.update_btn = ttk.Button(root, text="Update", command=self.execute_update)
        self.update_btn.place(x=0, y=148)

        #######--------- View history button ---------###############
        self.history_btn = ttk.Button(root, text="View history", command=self.view_history)
        self.history_btn.place(x=0, y=390)

        ######------ Text prompt -------########
        self.text_prompt = Text(root, width=53, height=12)
        self.text_prompt.place(x=0, y=175)

        # Clear button
        self.clear = ttk.Button(root, text="Clear", command=self.clear_text_prompt)
        self.clear.place(x=346, y=390)
