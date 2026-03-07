set shell := ["bash", "-uc"]

ci := env("CI", "false")

_default:
    @just --list --unsorted --justfile {{justfile()}}

# Build the LinkML schema and documentation artifacts
build: _clean _generate-linkml-schema _generate-antora-docs _generate_site
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
    cim2linkml src/data/*.qea --single-schema -o output/linkml

# Generate Antora documentation
_generate-antora-docs:
    @echo "Generating documentation…"
    @echo
    mkdir -p output/docs/adoc
    cp -r src/docs/* output/docs/adoc
    cp -r src/data/*.qea output/docs/adoc/modules/ROOT/attachments/
    cp -r output/linkml/*.yml output/docs/adoc/modules/ROOT/attachments/
    mkdir -p output/docs/adoc/modules/schema
    python -m linkml_asciidoc_generator.main \
        -o output/docs/adoc/modules/schema \
        -t ui/templates \
        output/linkml/*.yml
    echo "- modules/schema/nav.adoc" >> output/docs/adoc/antora.yml
    @echo "… OK."
    @echo
    @echo -e "Generated documentation files at: output/docs/adoc"
    @echo

# Generate HTML website
_generate_site:
    @echo "Generating HTML website…"
    @echo
    if [ "{{ci}}" == true ]; then \
        antora antora-playbook.yml; \
    else \
        npx antora antora-playbook.local.yml; \
    fi
    @echo
    @echo "Success."
