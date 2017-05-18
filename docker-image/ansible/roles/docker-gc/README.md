# docker-gc

Installs docker-gc on the target and setups crontab to run it on a hourly basis.

## Variables

* `docker_gc_image = spotify/docker-gc`
* `docker_gc_image_update_time = weekly`
* `docker_gc_run_time = daily`
* `docker_gc_force_image_removal = 0`
* `docker_gc_minimum_images_to_save = 0`
* `docker_gc_force_container_removal = 0`
* `docker_gc_grace_period = 3600`