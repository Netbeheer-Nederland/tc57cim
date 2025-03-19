#set dotenv-required
#set dotenv-load
set shell := ["bash", "-uc"]
set windows-shell := ["bash", "-uc"]



ref_name := "git rev-parse --abbrev-ref HEAD"
major_branch_name := "git rev-parse --abbrev-ref HEAD | cut -d . -f 1"


_default:
    @just --list --unsorted --justfile {{justfile()}}

# Build the project
[group("project")]
build: clean _post-process-linkml-schema generate-json-schema generate-documentation generate-example-data validate-example-data
    @echo "Building project…"
    @echo
    cp -r "artifacts/information_models" "artifacts/documentation/modules/schema/attachments/"
    cp -r "artifacts/schemas" "artifacts/documentation/modules/schema/attachments/"
    cp -r "artifacts/examples" "artifacts/documentation/modules/schema/attachments/"
    @echo "… OK."
    @echo
    @echo "All project artifacts have been generated and post-processed, and can found in: artifacts/"
    @echo

# Clean up the output directory
[group("project")]
clean:
    @echo "Cleaning up generated artifacts…"
    @echo
    @if [ -d "artifacts" ]; then \
        rm -rf "artifacts"; \
    fi
    mkdir -p "artifacts"
    @echo "… OK."
    @echo

# Initialize project
[group("project")]
initialize:
    #!/bin/env bash
    echo "Initializing project…"
    echo

    poetry install

    echo
    echo "Creating and configuring repository on GitHub…"
    echo

    gh repo create Netbeheer-Nederland/im-tc57cim \
        --description "Information models for the TC57CIM standard." \
        --public \
        --disable-wiki

    git init -b main

    git remote add origin git@github.com:Netbeheer-Nederland/im-tc57cim.git
    git fetch

    git add .
    git commit -m "Initial commit"
    git push -u origin main

    echo
    echo 'Create `docs` and `docs-dev` branches for storing documentation artifacts…'
    echo
    git checkout --orphan docs
    git rm -rf .
    git add .
    git commit --allow-empty -m "Initial commit"
    git push -u origin docs

    git checkout main
    git checkout --orphan docs-dev
    git rm -rf .
    git add .
    git commit --allow-empty -m "Initial commit"
    git push -u origin docs-dev

    echo
    echo 'Creating `v0` major version branch…'
    echo
    git checkout main
    git checkout -b v0
    git push -u origin v0

    gh repo edit Netbeheer-Nederland/im-tc57cim --default-branch v0
    git branch -D main
    git push --delete origin main

    # TODO: Enable this only as soon as you've managed to make an exception
    # for the CI/CD, which obviously ought to be able to write.
    #
    #echo "Adding ruleset to protect documentation branches…"
    #echo -en "\t"
    #gh api \
    #    --method POST \
    #    -H "Accept: application/vnd.github+json" \
    #    -H "X-GitHub-Api-Version: 2022-11-28" \
    #    /repos/Netbeheer-Nederland/$(basename `git config --get remote.origin.url` | cut -d . -f -1)/rulesets \
    #    --input ".github/rulesets/protect-docs-branches.json"
    #@echo "… OK."
    #@echo

    echo
    echo "Adding ruleset to protect major branches…"
    echo
    gh api \
        --method POST \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        /repos/Netbeheer-Nederland/$(basename `git config --get remote.origin.url` | cut -d . -f -1)/rulesets \
        --input ".github/rulesets/protect-major-branches.json"

    # Set workflow permissions

    #gh api \
    #  --method PUT \
    #  -H "Accept: application/vnd.github+json" \
    #  -H "X-GitHub-Api-Version: 2022-11-28" \
    #  /repos/Netbeheer-Nederland/im-tc57cim/actions/permissions \
    #   -F "enabled=true" -f "allowed_actions=all"

    echo "… OK."
    echo
    echo "A GitHub repository has been created and configured at: https://github.com/Netbeheer-Nederland/im-tc57cim"
    echo


# Post-process LinkML schema for preview or releasing
_post-process-linkml-schema:
    @echo "Copying source files to artifacts directory…"
    @echo
    mkdir -p "artifacts/information_models"
    cp "information_models/im_tc57cim.schema.linkml.yml" "artifacts/information_models/"
    @echo
    @echo "Setting version in LinkML schema…"
    @echo
    sed -i '/^version: .*$/d' "artifacts/information_models/im_tc57cim.schema.linkml.yml"
    @if [ -z ${VERSION:-} ]; then \
        sed -i "/^name: .*$/a version: {{shell(ref_name)}}" "artifacts/information_models/im_tc57cim.schema.linkml.yml"; \
    else \
        sed -i "/^name: .*$/a version: ${VERSION}" "artifacts/information_models/im_tc57cim.schema.linkml.yml"; \
    fi
    @echo "… OK."
    @echo

# Edit the schema
[group("schema")]
edit-schema:
    @${VISUAL:-${EDITOR:-nano}} information_models/im_tc57cim.schema.linkml.yml

# Show definition of the class identified by the provided CURIE
[group("schema")]
get-definition curie:
    yq '.classes.* | select(.class_uri == "{{curie}}")' information_models/im_tc57cim.schema.linkml.yml

# List all classes in the schema
[group("schema")]
list-classes:
    yq '.classes.* | key' information_models/im_tc57cim.schema.linkml.yml

# Create new draft
[group("version-control")]
create-draft name:
    @echo "Creating new draft…"
    @echo
    @echo "Creating and tracking new draft branch…"
    @echo
    git checkout -b {{shell(major_branch_name) + "." + name}}
    git commit --allow-empty -m "Start working on draft"
    git push -u origin {{shell(major_branch_name) + "." + name}}
    @echo
    @echo "Creating new draft pull request…"
    @echo
    gh pr create --base {{shell(major_branch_name)}} --draft
    @echo "… OK."
    @echo

# Finish draft
[group("version-control")]
finish-draft:
    @echo "Finishing draft…"
    @echo
    @echo "Marking draft pull request as ready for review…"
    @echo
    gh pr ready
    @echo "… OK."
    @echo

# Preview version
[group("version-control")]
preview-version:
    @echo "Generating preview of version…"
    @echo
    gh workflow run preview_release.yml --ref {{shell(ref_name)}}
    @echo "… OK."
    @echo

# Check if currently checked out branch is a major version branch
_on-major-branch:
    @echo "Checking if currently checked out branch is a major version branch…"
    @echo
    @if [ ! {{shell(ref_name)}} == {{shell(major_branch_name)}}  ]; then \
        echo "Releases can only be done from major branches. Please check out the major branch you wish to release from."; \
        exit 1; \
    fi

# Release new major version
[group("version-control")]
release-major-version: _on-major-branch
    @echo "Releasing new major version…"
    @echo
    gh workflow run release_major_version.yml --ref {{shell(ref_name)}}
    @echo "… OK."
    @echo

# Release new minor version
[group("version-control")]
release-minor-version: _on-major-branch
    @echo "Releasing new minor version…"
    @echo
    gh workflow run release_minor_version.yml --ref {{shell(ref_name)}}
    @echo "… OK."
    @echo

# Release new patch version
[group("version-control")]
release-patch-version: _on-major-branch
    @echo "Releasing new patch version…"
    @echo
    gh workflow run release_patch_version.yml --ref {{shell(ref_name)}}
    @echo "… OK."
    @echo

# Generate documentation
[group("generators")]
generate-documentation: _post-process-linkml-schema
    @echo "Generating documentation…"
    @echo
    cp -r "documentation" "artifacts"
    mkdir -p "artifacts/documentation/modules/schema"
    poetry run python -m linkml_asciidoc_generator.main \
        "artifacts/information_models/im_tc57cim.schema.linkml.yml" \
        "artifacts/documentation/modules/schema"
    echo "- modules/schema/nav.adoc" >> artifacts/documentation/antora.yml
    @echo "… OK."
    @echo
    @echo -e "Generated documentation files at: artifacts/documentation"
    @echo

# Generate example data
[group("generators")]
generate-example-data: _post-process-linkml-schema
    @echo "Generating JSON example data…"
    @echo
    mkdir -p "artifacts/examples"
    for example_file in examples/*.yml; do \
        [ -f "$example_file" ] || continue; \
        poetry run gen-linkml-profile  \
            convert \
            "$example_file" \
            --out "artifacts/${example_file%.*}.json"; \
    done
    @echo "… OK."
    @echo
    @echo -e "Generated example JSON data at: artifacts/examples"
    @echo

# Generate JSON Schema
[group("generators")]
generate-json-schema: _post-process-linkml-schema
    @echo "Generating JSON Schema…"
    @echo
    mkdir -p "artifacts/schemas/json_schema"
    poetry run gen-json-schema \
        --not-closed \
        "artifacts/information_models/im_tc57cim.schema.linkml.yml" \
        > "artifacts/schemas/json_schema/im_tc57cim.json_schema.json"
    @echo "… OK."
    @echo
    @echo "Generated JSON Schema at: artifacts/schemas/json_schema/im_tc57cim.json_schema.json"
    @echo

# Validate example data
[group("validate")]
validate-example-data: generate-json-schema generate-example-data
    @echo "Validating example data against JSON schema…"
    @echo
    for example_file in artifacts/examples/*.json; do \
        [ -f "$example_file" ] || continue; \
        poetry run check-jsonschema --schemafile "artifacts/schemas/json_schema/im_tc57cim.json_schema.json" $example_file; \
    done
    @echo "… OK."
    @echo

