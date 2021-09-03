# Semantic Mediawiki Docker Images

A project to continuously release Docker images that are pre-installed with MediaWiki and the Semantic MediaWiki extension. Basic checks are run to verify we're using the latest stable versions of dependencies and that the extension is working correctly.

Releases are on [**DockerHub**](https://hub.docker.com/repository/docker/naimkabir/semantic-mediawiki).

Reach out for support [@kabircreates](https://twitter.com/KabirCreates), or post issues directly to the [**Github repo**](https://github.com/NaimKabir/semantic-mediawiki/issues).  
  
  
## Docker Usage

A lot of the installation mess is abstracted away in released Docker images, but unfortunately there's still a lot to do after pulling one.


1. **Pull an image** from the repository. e.g with: `docker pull naimkabir/semantic-mediawiki:3.2.3`
2. **Run the image** in order to stand up the MediaWiki instance. e.g with: `docker run --name smw -d -p 8080:80 naimkabir/semantic-mediawiki:3.2.3`. By default, the port MediaWiki talks on is port 80, and we map a host port to it.
3. **Configure MediaWiki** by either going through the MediaWiki installer process, or by `docker cp`ing in a `LocalSettings.php` that you already have available. You can also `docker exec` into a running container to run a manual install.
4. **Enable semantics!** You must add a line to `LocalSettings.php` that looks like: `enableSemantics('{YOUR_WIKI_SERVER}'}`.
5. **Run maintenance.** As with all MediaWiki upgrades, you must run maintenance with `php maintenance/update.php` in the root directory of the MediaWiki project.
6. **Verify the install.** You should be good to go, but you can follow [these steps](https://www.semantic-mediawiki.org/wiki/Help:Verify_the_installation) to verify a correct install.


