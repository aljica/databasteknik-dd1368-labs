from string import Template

class SeriesQueries:

    def __init__(self):
        self.query = ""

    def set_genre_search(self, genre, user_id):
        self.query = Template("""
            SELECT e.id AS id, e.title AS episode_title, g.name AS genre
            FROM episodes e
            JOIN seasons se ON e.season_id=se.id
            JOIN series s ON se.series_id=s.id
            JOIN genres g ON s.genre=g.id
            WHERE g.name = '$which_genre' AND
            e.id NOT IN (
                SELECT media_id
                FROM watches
                WHERE user_id='$id' AND
                finished=true
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
        FROM episodes e
        WHERE e.id in (
          SELECT *
          FROM participating_in
        ) AND
        e.id NOT IN (
          SELECT media_id
          FROM watches
          WHERE user_id=%i AND
          finished=true
        )
        """ % (actor, user_id)

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
        FROM episodes e
        WHERE e.id in (
          SELECT * FROM directing_by
        ) AND
        e.id NOT IN (
          SELECT media_id
          FROM watches
          WHERE user_id=%i AND
          finished=true
        )
        """ % (director, user_id)

        return self.query

    def set_language_search(self, language):
        self.query = """
        SELECT e.id, l.name, e.title, e.release_year
        FROM languages l
        JOIN available_languages al ON
        l.id = al.language
        JOIN episodes e ON
        al.media_id=e.id
        WHERE l.name = '%s'
        """ % (language)

        return self.query

    def set_title_search(self, title):
        self.query = Template("""
        SELECT e.id, e.title, e.release_year
        FROM episodes e
        JOIN seasons se ON e.season_id=se.id
        JOIN series s ON se.series_id=s.id
        WHERE s.title LIKE '%$here%'
        """)
        self.query = self.query.substitute(here=title)

        return self.query

    def set_rating_search(self, rating, user_id):
        self.query = """
        SELECT e.id, e.title, e.release_year
        FROM episodes e
        JOIN watches w ON
        e.id = w.media_id
        WHERE rating = %i AND
        user_id = %i
        """ % (rating, self.user_id)

        return self.query

    def set_remaining_episodes_search(self, number, user_id):
        self.query = """
        WITH test AS (
            SELECT w.user_id, w.media_id, e.title, e.season_id, e.episode_number, s.episode_count, se.id AS series_id
            FROM watches w
            JOIN episodes e ON w.media_id=e.id
            JOIN seasons s ON e.season_id=s.id
            JOIN series se ON s.series_id=se.id
            WHERE user_id=%i
        ),

        seen_episodes AS (
            SELECT series_id, count(*) AS watched
            FROM test
            GROUP BY series_id
        ),

        total_episodes AS (
            SELECT s.id AS series_id, se.id, e.id, se.episode_count
            FROM series s
            JOIN seasons se ON s.id=se.series_id
            JOIN episodes e ON e.season_id=se.id
        ),

        total_episodes_final_result AS (
            SELECT series_id, count(*) AS total
            FROM total_episodes
            GROUP BY series_id
        ),

        find AS (
            SELECT seen.series_id
            FROM seen_episodes seen
            JOIN total_episodes_final_result final ON seen.series_id=final.series_id
            WHERE ABS(total - watched) = %i
        ),

        present AS (
            SELECT s.id, s.title
            FROM find f
            JOIN series s ON f.series_id=s.id
        )

        SELECT *
        FROM present;
        """ % (user_id, number)

        return self.query
