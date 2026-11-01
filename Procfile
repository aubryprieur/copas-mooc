web: bundle exec thrust bin/rails server -p $PORT -e $RAILS_ENV
worker: bundle exec bin/jobs
postdeploy: bundle exec rails db:migrate
