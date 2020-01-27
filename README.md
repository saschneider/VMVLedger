# Trusted and Transparent Voting Systems: Verify My Vote Demonstrator

This repository contains the Ruby on Rails application which runs the Trusted and Transparent Voting Systems: Verify My Vote Demonstrator VMV component. The
demonstrator is used to implement verifiable voting. A full description of the requirements and high-level design can be found in (Casey, 2018).

## Prerequisites

This application has the following key dependencies:

* Ruby version: 2.3.3 or newer
* Rails version: 5.2.2
* Production database: PostgreSQL

## Localisation

All strings are localised into a hierarchy of files in the config/locales folder.  The exception to this are any large bodies of text within templates where it is
impractical to localise text for each tag.  As a consequence, the following files are locale specific within the app/views hierarchy of files:

* `application/*`
* `contents/*`
* `devise/*`
* `home/*`
* `job_mailer/*`
* `user_mailer/*`
* `verify/*`

## Development
Sending emails in development mode can be intercepted using [mailcatcher](https://mailcatcher.me/ "mailcatcher"). On your development machine, `gem install mailcatcher`
and then execute `mailcatcher`.  Emails can then be seen by opening a browser window to [http://localhost:1080](http://localhost:1080).  To change this configuration,
modify the `config/environments/development.rb` environment file.

## Docker Deployment
The production app can be deployed to a series of docker images to allow the app to be run via Docker. Four images are used:
* Bespoke image for the Ruby-on-Rails app
* Bespoke image for NGINX
* Bespoke image for Quorum
* Off-the-shelf image for PostgreSQL

To build the bespoke images, do the following:
* Commit all changes to git
* Ensure Docker is running
* `docker-compose build --build-arg RAILS_MASTER_KEY=master_key`

The `master_key` must be replaced with the master key used to decrypt the Docker-specific credentials file. This key is deliberately not committed to the repository
and must be supplied separately.

To save the resulting images for deployment to a different machine:
* `docker save vmv_app | gzip > app.tar.gz`
* `docker save vmv_web | gzip > web.tar.gz`
* `docker save vmv_quorum | gzip > quorum.tar.gz`
* Move the images together with the `docker-compose.yml` to the target machine (or push the image to a repository)
* Ensure Docker is running
* `docker load < app.tar.gz`
* `docker load < web.tar.gz`
* `docker load < quorum.tar.gz`

To start and stop the deployment:
* Create the `.env` file in the current directory and place within it:
```
RAILS_MASTER_KEY=master_key
```
* `docker swarm init` if you have not previously initialised a Docker swarm
* `docker stack deploy -c docker-compose.yml vmv`
* ...
* `docker stack rm vmv`
* `docker swarm leave --force` if you want to shutdown the Docker swarm

If the PostgreSQL image does not exist on the target machine, then this will build the PostgreSQL image, then start containers for all four images to run the
application in the background. Note that when stopped, all data will be lost so ensure to backup the PostgreSQL and Quorum data if you wish to keep it. 

Once running, the service can be accessed via [http://localhost:3000](http://localhost:3000). Note that the app is not configured with a suitable SMTP server, so
emails sent by the app will not be surfaced. No SSL certificate will be installed for the app and Ruby-on-Rails is not configured to force all requests to use SSL.

The Quorum installation is limited to a single Quorum node because of the difficulty in automatically configuring isolated Quorum nodes to communicate with one another. For the app to be able to commit data to the single Quorum node, you must log in to the app, select `Configuration options` from the `Configuration` menu, enter `http://quorum_ip_address:22000` in the `Quorum Node URLs` box and select `Save`. The `quorum_ip_address` for the Quorum node can obtained by running `docker network inspect vmv_default`.

Within the app, an initial user will have been created with a default password. See `db/seeds.rb` for details.

Since the PostgreSQL and Quorum containers will contain data about elections, it is prudent to back them up at regular intervals. To backup a container, execute the following:
```shell
docker commit -p container_id backup
docker save backup | gzip > backup.tar.gz
```

where
* `container_id` is the id of the running PostgreSQL or Quorum container
* `backup` is a suitable name for the backup, such as a sequential number or date

This will commit the running container as an image and then save the image to a file which can be restored using load:
```shell
docker load < backup.tar.gz
```

## Production Deployment to AWS
Assuming AWS is used for a production deployment:
* Commit all changes to git
* `eb deploy`

### AWS Configuration

All configuration for the application, including secure content, is held within the config folder. The only content expected via an environment variables are the
following:

* `RAILS_DB_SEED`: set to "true" to perform database seeding during deployment.
* `RAILS_MASTER_KEY`: required for the staging and production environments.
* `JOB_WORKER`: set to "true" to enable job processing on the instance.
* `CERTBOT_DOMAIN`: set to the Certbot SSL domain.
* `CERTBOT_EMAIL`: set to the Certbot notification email.

## References

M. C. Casey, "Trusted and Transparent Voting Systems: Verify My Vote Demonstrator Requirements and Design," 2018.







