inotifywait -q -m -e CLOSE_WRITE --format="git add .; git commit -m 'autocommit on change' %w; git push" /home/aljica/Desktop/data-dbas/lab3/lab3.txt | sh
