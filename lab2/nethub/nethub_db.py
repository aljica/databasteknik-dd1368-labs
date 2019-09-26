import pgdb
from sys import argv
from string import Template
from movies_queries import MoviesQueries
from series_queries import SeriesQueries

class NethubDB:

    def __init__(self):
        # Open connection & cursor to local database.
        params = {'host':'localhost', 'user':'lulu', 'database':'nethub', 'password':'lulu'}
        self.conn = pgdb.connect(**params)
        self.cur = self.conn.cursor()

        self.chosen_category = "Movies" # Searching by movies or series? 0 for movies, 1 for series.
        self.user_id = 50005 # Which user is currently logged in?
        self.query = "" # Only one query may be processed at a time.

        # This is from where we get our queries.
        self.movie_query = MoviesQueries()
        self.series_query = SeriesQueries()

        # Check if user is a child. 0 for not child, 1 for is child.
        self.is_child = 0
        parents = self.cur.execute("select * from parents")
        all_parents = self.cur.fetchall()
        for i in range(len(all_parents)):
            child = all_parents[i][1]
            if self.user_id == child:
                self.is_child = 1

    def set_category(self, category):
        self.chosen_category = category

    def genre_search(self, genre):
        if self.chosen_category == "Movies":
            self.query = self.movie_query.set_genre_search(genre, self.user_id)
        elif self.chosen_category == "Series":
            self.query = self.series_query.set_genre_search(genre, self.user_id)
        self.execute_query()

    def actor_search(self, actor):
        if self.chosen_category == "Movies":
            self.query = self.movie_query.set_actor_search(actor, self.user_id)
        elif self.chosen_category == "Series":
            self.query = self.series_query.set_actor_search(actor, self.user_id)
        self.execute_query()

    def director_search(self, director):
        if self.chosen_category == "Movies":
            self.query = self.movie_query.set_director_search(director, self.user_id)
        elif self.chosen_category == "Series":
            self.query = self.series_query.set_director_search(director, self.user_id)
        self.execute_query()

    def language_search(self, language):
        if self.chosen_category == "Movies":
            self.query = self.movie_query.set_language_search(language)
        elif self.chosen_category == "Series":
            self.query = self.series_query.set_language_search(language)
        self.execute_query()

    def title_search(self, title):
        if self.chosen_category == "Movies":
            self.query = self.movie_query.set_title_search(title)
        elif self.chosen_category == "Series":
            self.query = self.series_query.set_title_search(title)
        self.execute_query()

    def rating_search(self, rating):
        if self.chosen_category == "Movies":
            self.query = self.movie_query.set_rating_search(rating, self.user_id)
        elif self.chosen_category == "Series":
            self.query = self.series_query.set_rating_search(rating, self.user_id)
        self.execute_query()

    def remaining_episodes_search(self, number):
        self.query = self.series_query.set_remaining_episodes_search(number, self.user_id)
        self.execute_query()

    def execute_query(self):
        self.cur.execute(self.query)

    # THIS IS FOR FETCHING TUPLES AFTER A QUERY HAS BEEN EXECUTED.
    def get_result(self):
        result = self.cur.fetchall()
        final_result = ""
        if self.is_child == 0:
            for i in range(len(result)):
                row = result[i]
                for j in range(len(result[i])):
                    line = row[j]
                    final_result += str(line)
                    final_result += "\t\t"
                final_result += "\n"
        else:
            remove_these_medias = self.find_media_id_to_remove() # media id's to remove from above result
            for i in range(len(result)):
                row = result[i]
                if row[0] in remove_these_medias:
                    continue
                else:
                    for j in range(len(result[i])):
                        line = row[j]
                        final_result += str(line)
                        final_result += "\t\t"
                final_result += "\n"

        if not final_result: # i.e. empty result set
            return "No results found"
        else:
            return final_result

    # Handle child filters, remove tuples from search result accordingly.
    # ONLY used in conjunction with get_result()-method above.
    def find_media_id_to_remove(self):

        self.query = "select type, name from user_filters where user_id=%i" % (self.user_id)
        self.execute_query()
        filter_type = self.cur.fetchall()

        remove_these_medias = []

        for i in range(len(filter_type)):
            row = filter_type[i]
            if row[0] == "Genre":
                self.genre_search(genre = row[1])
                genre_search = self.cur.fetchall()
                for q in range(len(genre_search)):
                    remove_these_medias.append(genre_search[q][0])
            elif row[0] == "Actor":
                self.actor_search(actor=row[1])
                actor_search = self.cur.fetchall()
                for k in range(len(actor_search)):
                    remove_these_medias.append(actor_search[k][0])
            elif row[0] == "Director":
                self.director_search(director=row[1])
                director_search = self.cur.fetchall()
                for l in range(len(director_search)):
                    remove_these_medias.append(director_search[l][0])
            elif row[0] == "Title":
                self.title_search(title=row[1])
                title_search = self.cur.fetchall()
                for j in range(len(title_search)):
                    remove_these_medias.append(title_search[j][0])

        return remove_these_medias

############ BEGIN SECOND_GUI HISTORY-RELATED METHODS ###############

    def view_history(self):
        query = """
        SELECT m.title, w.rating
        FROM movies m
        JOIN watches w ON m.id=w.media_id
        WHERE w.user_id=%i
        """ % (self.user_id)
        self.cur.execute(query)
        movie_result = "\n".join([", ".join([str(a) for a in x]) for x in self.cur.fetchall()])

        query = """
        SELECT e.title, w.rating
        FROM episodes e
        JOIN watches w ON e.id = w.media_id
        WHERE w.user_id=%i
        """ % (self.user_id)
        self.cur.execute(query)
        episodes_result = "\n".join([", ".join([str(a) for a in x]) for x in self.cur.fetchall()])

        result = movie_result + "\n" + episodes_result
        return result

    def perform_update(self, media_id, new_rating):
        self.query = """
        UPDATE watches SET rating = %i
        WHERE media_id=%i AND
        user_id=%i
        """ % (new_rating, media_id, self.user_id)
        self.execute_query()
        self.conn.commit()

    def get_rated_media(self):
        movies_query = """
            SELECT m.id, m.title, w.rating
            FROM movies m
            JOIN watches w ON m.id=w.media_id
            WHERE w.user_id = %i
            """ % (self.user_id)
        episodes_query = """
            SELECT e.id, e.title, w.rating
            FROM episodes e
            JOIN watches w ON e.id = w.media_id
            WHERE w.user_id = %i
            """ % (self.user_id)
        return self.fetch_rated_media_result(movies_query, episodes_query)

    def fetch_rated_media_result(self, movies_query, episodes_query):
        m_data = []
        sub_data = []
        self.query = movies_query
        self.execute_query()
        movie_data = self.handle_query_result()
        self.query = episodes_query
        self.execute_query()
        episodes_data = self.handle_query_result()
        return movie_data, episodes_data

    def handle_query_result(self):
        data = []
        sub_data = []
        tuples = self.cur.fetchall()
        for i in range(len(tuples)):
            row = tuples[i]
            for j in range(len(row)):
                sub_data.append(row[j])
            data.append(sub_data)
            sub_data = []
        return data

############ END SECOND_GUI HISTORY-RELATED METHODS #################
