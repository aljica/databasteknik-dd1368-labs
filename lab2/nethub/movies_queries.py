from string import Template

class MoviesQueries:

    def __init__(self):
        self.query = ""

    def set_genre_search(self, genre, user_id):
        self.query = Template("""
            SELECT m.id AS id, m.title, m.release_year, g.name AS genre
            FROM movies m
            JOIN genres g ON
            m.genre=g.id
            WHERE g.name='$which_genre' AND
            m.id NOT IN (
                SELECT media_id
                FROM watches
                WHERE user_id='$id' AND
                finished = true
            )
            """)
        self.query = self.query.substitute(which_genre=genre, id=user_id)

        return self.query

    def set_actor_search(self, actor, user_id):
        self.query = """
        WITH participating_in AS (
          SELECT media_id
          FROM actors_in
          JOIN actors ON id=actor_id
          WHERE name='%s'
        )

        SELECT *
        FROM movies m
        WHERE m.id IN (
          SELECT *
          FROM participating_in
        ) AND
        m.id NOT IN (
          SELECT media_id
          FROM watches
          WHERE user_id=%i AND
          finished=true
        )""" % (actor, user_id)

        return self.query

    def set_director_search(self, director, user_id):
        self.query = """
        WITH directing_by AS (
          SELECT media_id
          FROM directed_by
          JOIN directors ON director_id=id
          WHERE name='%s'
        )

        SELECT *
        FROM movies m
        WHERE m.id in (
          SELECT * FROM directing_by
        ) AND
        m.id NOT IN (
          SELECT media_id
          FROM watches
          WHERE user_id=%i AND
          finished=true
        )
        """ % (director, user_id)

        return self.query

    def set_language_search(self, language):
        self.query = """
        SELECT m.id, l.name, m.title, m.release_year
        FROM languages l
        JOIN available_languages al ON
        l.id = al.language
        JOIN movies m ON
        al.media_id=m.id
        WHERE l.name = '%s'
        """ % (language)

        return self.query

    def set_title_search(self, title):
        self.query = Template("""
        SELECT m.id, m.title, m.release_year
        FROM movies m
        WHERE title LIKE '%$here%'
        """)
        self.query = self.query.substitute(here=title)

        return self.query

    def set_rating_search(self, rating, user_id):
        self.query = """
        SELECT m.id, m.title, m.release_year
        FROM movies m
        JOIN watches w ON
        m.id = w.media_id
        WHERE rating = %i AND
        user_id = %i
        """ % (rating, user_id)

        return self.query
