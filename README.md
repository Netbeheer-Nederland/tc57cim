# CIM LinkML Schemas

The CIM information model represented as LinkML schemas, generated from the official Sparx EA project.

## Schemas
All schemas can be found in the `information_models` directory.

### Full CIM (TC57CIM)
The entire CIM information model has been outputted in two forms:

* As a single LinkML schema (`information_models/im_tc57cim.schema.linkml.yml`)
* As a nested directory of LinkML schemas per package (`information_models/TC57CIM/`)

### Schemas per standard
Single file versions of schemas per Working Group have also been generated:

* IEC61968 (`information_models/TC57CIM.IEC61968.yml`)
* IEC61970 (`information_models/TC57CIM.IEC61970.yml`)
* IEC62325 (`information_models/TC57CIM.IEC62325.yml`)

### Notes
LinkML schema are generated in such a way to ensure they are standalone, i.e. don't depend on other files. Because classes depend on other classes (e.g. through ancestors and relations), sometimes from other packages, all such dependencies are added to the schemas. Although this redundancy vastly increases the total file size, this way we do get to avoid complications with namespaces and importing: it keeps things simple.

Each class and enumeration has a `from_schema` value which tells you the ID of the LinkML schema corresponding to the package where that element originates from.

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

### Notes of caution

This repository has been reorganised as part of a migration. However, it's been somewhat messy, so let me explain.

Each `cim*` branch contains source files to build LinkML schemas and Antora documentation sites for. The Antora component version descriptor (`antora.yml`) is configured to run `just build` through Antora Collector. Note that the `justfile` of each such branch is used, not the one in the `main` branch. This is unfortunate, but I've not yet had time to fix this.

Furthermore, the `cim*` branches and `main` branches are not properly independent, and have undergone pragmatic merges both ways to move me more quickly towards my goal of migrating.