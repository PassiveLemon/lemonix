docker run --privileged --name npr-docker -v ./:/npr-work/ --cpus 6 --memory 12g --memory-swap 12g npr-docker

# Occasionally errors due to out-of-memory. Seriously, this can hit over 12 gigs of memory, insane.

