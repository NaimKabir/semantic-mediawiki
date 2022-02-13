# Semantic Mediawiki Docker Images

[![deploy](https://github.com/NaimKabir/semantic-mediawiki/actions/workflows/deploy.yaml/badge.svg)](https://github.com/NaimKabir/semantic-mediawiki/actions/workflows/deploy.yaml)

A project to continuously release Docker images that are pre-installed with MediaWiki and the Semantic MediaWiki extension. Basic checks are run to verify we're using the latest stable versions of dependencies and that the extension is working correctly.

Releases are on [**DockerHub**](https://hub.docker.com/repository/docker/naimkabir/semantic-mediawiki).

Reach out for support [@kabircreates](https://twitter.com/KabirCreates), or post issues directly to the [**Github repo**](https://github.com/NaimKabir/semantic-mediawiki/issues).
  
  
## Docker Usage

A lot of the installation mess is abstracted away in released Docker images, but unfortunately there's still a lot to do after pulling one.

If you want to just play around with a pre-configured, SQLite-based *minimal* install and skip these steps, you can pull a [demo image](https://hub.docker.com/repository/docker/naimkabir/semantic-mediawiki/tags?page=1&ordering=last_updated&name=demo). It's not recommended that you deploy it anywhere without properly load testing it. 


1. **Pull an image** from the repository. e.g with: `docker pull naimkabir/semantic-mediawiki:3.2.3`
2. **Run the image** in order to stand up the MediaWiki instance. e.g with: `docker run --name smw -d -p 8080:80 naimkabir/semantic-mediawiki:3.2.3`. By default, the port MediaWiki talks on is port 80, and we map a host port to it.
3. **Configure MediaWiki** by either going through the [MediaWiki installer process](https://www.mediawiki.org/wiki/Manual:Config_script), or by `docker cp`ing in a `LocalSettings.php` that you already have available. You can also `docker exec` into a running container to run a manual install.
4. **Enable semantics!** You must add a line to `LocalSettings.php` that looks like: `wfLoadExtension('SemanticMediaWiki'); enableSemantics('{YOUR_WIKI_SERVER}');`. Note: pre-SMW 4.0.0 you should only add `enableSemantics('{YOUR_WIKI_SERVER}')`.
5. **Run maintenance.** As with all MediaWiki upgrades, you must run maintenance with `php maintenance/update.php` in the root directory of the MediaWiki project.
6. **Verify the install.** You should be good to go, but you can follow [these steps](https://www.semantic-mediawiki.org/wiki/Help:Verify_the_installation) to verify a correct install.

## Updating Versions

<details>
  
  
The primary purpose of this repo is to release containers with stable installations of Semantic Media Wiki for each release. We also want to use the latest acceptable versions of all dependencies.

This is currently done via a janky-but-functional method of software version-tracking and rebuilding Docker containers. If you see that one of these dependencies is out-of-date, you can follow these steps to release a new container to [**DockerHub**](https://hub.docker.com/repository/docker/naimkabir/semantic-mediawiki):

1. Clone this repo: `git clone https://github.com/NaimKabir/semantic-mediawiki.git`.
2. Checkout a new branch. 
3. In your branch, update versions in `versions.jinja` in the directory root.
4. In your branch, run `./update_versions.py` in the directory root. When you `git diff` you should see relevant changes. This step will require you to install python dependencies, e.g with `pip install -r requirements.txt`.
5. Push your branch with this repo as the upstream source, and open a Pull Request (PR). This will trigger tests. If they pass and the PR is approved, it will be merged to master. Upon merge, a new container will be built and released.
</details>

## Tests

<details>
  
  
To ensure a correct install I run `phpunit` tests that come packaged with the Semantic MediaWiki install.

The test suites I run are:
1. `semantic-mediawiki-unit`
2. `semantic-mediawiki-integration`
3. `semantic-mediawiki-check`
4. `semantic-mediawiki-structure`
  
I exclude some tests that are failing on Semantic MediaWiki master, but my testing should at the very least help protect against regressions. For details on what tests are run (and which are hackily excluded), you can check out the `container/tests` directory.
  
You can run them with: `bazel test //...`. This will require Bazel, which I like installing with [Bazelisk](https://github.com/bazelbuild/bazelisk).
  
In addition I also do some basic checks for loaded extensions and proper dependency versions.
</details>

## Note

* with bazel 6.3.2 when running the below is errors out

```bash
bazel test //...
ERROR: /home/brody/.cache/bazel/_bazel_brody/2318e702975a887bc84c4d382ff0c38a/external/bazel_tools/platforms/BUILD:59:6: in alias rule @bazel_tools//platforms:osx: Constraints from @bazel_tools//platforms have been removed. Please use constraints from @platforms repository embedded in Bazel, or preferably declare dependency on https://github.com/bazelbuild/platforms. See https://github.com/bazelbuild/bazel/issues/8622 for details.
ERROR: /home/brody/.cache/bazel/_bazel_brody/2318e702975a887bc84c4d382ff0c38a/external/bazel_tools/platforms/BUILD:59:6: Analysis of target '@bazel_tools//platforms:osx' failed
ERROR: /home/brody/workspace/github/semantic-mediawiki/container/BUILD.bazel:96:15: While resolving toolchains for target //container:demo: invalid registered toolchain '@io_bazel_rules_docker//toolchains/docker:default_osx_toolchain': 
ERROR: Analysis of target '//container:demo' failed; build aborted: 
INFO: Elapsed time: 0.634s
INFO: 0 processes.
FAILED: Build did NOT complete successfully (2 packages loaded, 21 targets configured)
    currently loading: @bazel_tools//tools/cpp ... (2 packages)
ERROR: Couldn't start the build. Unable to run tests
 ```

