# PODMAN Man
<pre>
  Container images are compatible between Podman and other runtimes
Despite the new locations for the local repositories, the images created by Docker or Podman are compatible with the OCI standard. Podman can push to and pull from popular container registries like Quay.io and Docker hub, as well as private registries. For example, you can pull the latest Fedora image from the Docker hub and run it using Podman. Not specifying a registry means Podman will default to searching through registries listed in the registries.conf file, in the order in which they are listed. An unmodified registries.conf file means it will look in the Docker hub first.

$ podman pull fedora:latest
$ podman run -it fedora bash
Images pushed to an image registry by Docker can be pulled down and run by Podman. For example, an image (myfedora) I created using Docker and pushed to my Quay.io repository (ipbabble) using Docker can be pulled and run with Podman  as follows:

$ podman pull quay.io/ipbabble/myfedora:latest
$ podman run -it myfedora bash
Podman provides capabilities in its command-line push and pull commands to gracefully move images from /var/lib/docker to /var/lib/containers and vice versa.  For example:

$ podman push myfedora docker-daemon:myfedora:latest
Obviously, leaving out the docker-daemon above will default to pushing to the Docker hub.  Using quay.io/myquayid/myfedora will push the image to the Quay.io registry (where myquayid below is your personal Quay.io account):

$ podman push myfedora quay.io/myquayid/myfedora:latest
If you are ready to remove Docker, you should shut down the daemon and then remove the Docker package using your package manager. But first, if you have images you created with Docker that you wish to keep, you should make sure those images are pushed to a registry so that you can pull them down later. Or you can use Podman to pull each image (for example, fedora) from the host’s Docker repository into Podman’s OCI-based repository. With RHEL you can run the following:

# systemctl stop docker
# podman pull docker-daemon:fedora:latest
# yum -y remove docker  # optional
</pre>
