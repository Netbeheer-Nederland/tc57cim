# TC57CIM — CIM LinkML

LinkML schema and documentation website for the CIM data model, generated based on the official Sparx EA UML project.

## Developers

A LinkML schema and documentation website is built for every branch matching the pattern `cim*`, e.g. `cim17`.

### Build and deploy in CI/CD

Run the GitHub Actions workflow `build_and_deploy_site.yml` from the `main` branch.

### Build locally

To generate the LinkML schema and documentation website locally, ensure your environment has all the necessary requirements installed.

Then, simply run Antora with the local playbook, e.g.:

```shell
$ npx antora antora-playbook.local.yml
```

When this has run successfully, a directory `output/docs/html` should be created with files in it. To serve this website locally, simply run a HTTP server, e.g.:

```shell
$ npx http-serve output/docs/html
```

Of course, other servers can be used as well, such as `python -m http.server`.