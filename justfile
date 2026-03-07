set shell := ["bash", "-uc"]

_default:
    @just --list --unsorted --justfile {{justfile()}}

# Build the LinkML schema and documentation artifacts
build: _clean _generate-linkml-schema _generate-antora-docs _generate_site
    @echo "Building project…"
    @echo
    cp -r output/linkml output/docs/modules/schema/attachments/
    @echo "… OK."
    @echo
    @echo "All project artifacts have been generated and post-processed, and can found in: output/"
    @echo

# Clean up the output directory
_clean:
    @echo "Cleaning up generated artifacts…"
    @echo
    @if [ -d output ]; then \
        rm -rf output; \
    fi
    mkdir -p output
    @echo "… OK."
    @echo

# Generate LinkML schema from QEA file
_generate-linkml-schema:
    mkdir -p output/linkml
    cim2linkml data/*.qea --single-schema -o output/linkml

# Generate Antora documentation
_generate-antora-docs:
    @echo "Generating documentation…"
    @echo
    cp -r docs output/
    mkdir -p output/docs/modules/schema
    python -m linkml_asciidoc_generator.main \
        -o output/docs/modules/schema \
        -t ui/templates \
        output/linkml/*.yml
    echo "- modules/schema/nav.adoc" >> output/docs/antora.yml
    @echo "… OK."
    @echo
    @echo -e "Generated documentation files at: output/docs"
    @echo

# Generate HTML website
_generate_site:
    @echo "Generating HTML website…"
    @echo
    if [ "$CI" == true ]; then \
        antora antora-playbook.yml; \
    else \
        antora antora-playbook.local.yml; \
    fi
    @echo
    @echo "Success."