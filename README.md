# CIM LinkML Schemas

The CIM information model represented as LinkML schemas, generated from the official Sparx EA project.

## Schemas

### Full CIM
The entire CIM information model has been outputted in a single LinkML schema which can be found at `schemas/CIM.yml`.

### Package schemas
There's also a LinkML schema generated for every pacakge in the CIM UML model. Note however that classes depend on other classes (e.g. through ancestors and relations), sometimes from other packages. All such dependencies are added to the schemas, to ensure every schema file is standalone, avoiding complications with namespaces and importing. This keeps things simple. Each class and enumeration has a `from_schema` value which tells you the ID of the LinkML schema corresponding to the package where that class originates from.



