# CIM LinkML Schemas

The CIM information model represented as LinkML schemas, generated from the official Sparx EA project.

Every schema corresponds to a single UML package. Note however that classes depend on other classes (e.g. through ancestors and relations), sometimes from other packages. All such dependencies are added to the schemas, to ensure every schema file is standalone, avoiding complications with namespaces and importing. This keeps things simple.
