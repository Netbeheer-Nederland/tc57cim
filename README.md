# CIM LinkML Schemas

The CIM information model represented as LinkML schemas, generated from the official Sparx EA project.

## Schemas
All schemas can be found in the `Schemas` directory.

### Full CIM (TC57CIM)
The entire CIM information model has been outputted in two forms:

* As a single LinkML schema (`Schemas/TC57CIM.yml`)
* As a nested directory of LinkML schemas per package (`Schemas/TC57CIM/`)

### Packages per Work Group
Single file versions of schemas per Working Group have also been generated:

* IEC61968 (`Schemas/TC57CIM.IEC61968.yml`)
* IEC61970 (`Schemas/TC57CIM.IEC61970.yml`)
* IEC62325 (`Schemas/TC57CIM.IEC62325.yml`)

### Notes
LinkML schema are generated in such a way to ensure they are standalone, i.e. don't depend on other files. Because classes depend on other classes (e.g. through ancestors and relations), sometimes from other packages, all such dependencies are added to the schemas. Although this redundancy vastly increases the total file size, this way we do get to avoid complications with namespaces and importing: it keeps things simple.

Each class and enumeration has a `from_schema` value which tells you the ID of the LinkML schema corresponding to the package where that class originates from.
