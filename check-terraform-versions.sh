#!/bin/bash

# Script to check Terraform module versions in Terragrunt configurations
# Usage: ./check-terraform-versions.sh [--outdated] <environment>
# Generates a YAML file with current and latest available versions in the environment directory

set -euo pipefail

print_status() {
    echo "[INFO] $1"
}

print_error() {
    echo "[ERROR] $1"
}

print_success() {
    echo "[SUCCESS] $1"
}

ENVIRONMENT=""
OUTDATED_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --outdated)
            OUTDATED_ONLY=true
            shift
            ;;
        -*)
            print_error "Unknown option $1"
            print_error "Usage: $0 [--outdated] <environment>"
            print_error "Examples:"
            print_error "  $0 dev                    # Generate full report for dev environment"
            print_error "  $0 --outdated dev         # Generate outdated-only report for dev environment"
            exit 1
            ;;
        *)
            if [[ -z "$ENVIRONMENT" ]]; then
                ENVIRONMENT="$1"
            else
                print_error "Too many arguments. Only one environment should be specified."
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ -z "$ENVIRONMENT" ]]; then
    print_error "Usage: $0 [--outdated] <environment>"
    print_error "Examples:"
    print_error "  $0 dev                    # Generate full report for selected environment"
    print_error "  $0 --outdated dev         # Generate outdated-only report for selected environment"
    exit 1
fi

ENV_DIR="$ENVIRONMENT"
if [[ "$OUTDATED_ONLY" == true ]]; then
    OUTPUT_FILE="$ENV_DIR/terraform-versions-$ENVIRONMENT-outdated.yml"
else
    OUTPUT_FILE="$ENV_DIR/terraform-versions-$ENVIRONMENT.yml"
fi
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

extract_source() {
    local file="$1"
    
    local source
    source=$(grep -E '^\s*source\s*=' "$file" | grep -o '"[^"]*"' | tr -d '"' | head -1)
    
    echo "$source"
}

parse_git_source() {
    local source="$1"
    local repo_url=""
    local current_version=""
    local subpath=""
    
    if [[ "$source" =~ ^git::([^?]+)(\?ref=(.+))?$ ]]; then
        repo_url="${BASH_REMATCH[1]}"
        current_version="${BASH_REMATCH[3]:-main}"
        
        if [[ "$repo_url" =~ ^(.+)//(.+)$ ]]; then
            repo_url="${BASH_REMATCH[1]}"
            subpath="${BASH_REMATCH[2]}"
        fi
        
        echo "$repo_url|$current_version|$subpath"
    else
        echo "||"
    fi
}

get_github_repo_info() {
    local url="$1"
    
    if [[ "$url" =~ git::https://github\.com/([^/]+)/([^/\.]+)(\.git)?$ ]]; then
        local owner="${BASH_REMATCH[1]}"
        local repo="${BASH_REMATCH[2]}"
        echo "$owner/$repo"
        return
    fi
    
    if [[ "$url" =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
        local owner="${BASH_REMATCH[1]}"
        local repo="${BASH_REMATCH[2]}"
        repo="${repo%.git}"
        echo "$owner/$repo"
        return
    fi
    
    if [[ "$url" =~ ^([^/]+/[^/]+) ]]; then
        echo "${BASH_REMATCH[1]}"
        return
    fi
    
    echo ""
}

get_latest_version() {
    local repo="$1"
    local current_version="$2"
    
    local latest_release
    latest_release=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | \
                    jq -r '.tag_name // empty' 2>/dev/null || echo "")
    
    if [[ -n "$latest_release" && "$latest_release" != "null" ]]; then
        echo "$latest_release"
        return
    fi
    
    local latest_tag
    latest_tag=$(curl -s "https://api.github.com/repos/$repo/tags?per_page=1" | \
                jq -r '.[0].name // empty' 2>/dev/null || echo "")
    
    if [[ -n "$latest_tag" && "$latest_tag" != "null" ]]; then
        echo "$latest_tag"
        return
    fi
    
    echo "$current_version"
}

compare_versions() {
    local current="$1"
    local latest="$2"
    
    if [[ "$current" == "$latest" ]]; then
        echo "up-to-date"
    else
        echo "outdated"
    fi
}

get_module_type() {
    local source="$1"
    if [[ "$source" =~ ^git:: ]]; then
        echo "git"
    elif [[ "$source" =~ ^\.\./ ]]; then
        echo "local"
    else
        echo "unknown"
    fi
}

generate_yaml_output() {
    local results=("$@")
    
    if [[ "$OUTDATED_ONLY" == true ]]; then
        local filtered_results=()
        for result in "${results[@]}"; do
            IFS='|' read -r unit_name module_name current_version latest_version status module_type <<< "$result"
            if [[ "$status" == "outdated" ]]; then
                filtered_results+=("$result")
            fi
        done
        
        if [[ ${#filtered_results[@]} -eq 0 ]]; then
            print_success "No outdated modules found! All modules are up-to-date."
            return
        fi
        
        results=("${filtered_results[@]}")
        print_status "Found ${#filtered_results[@]} outdated modules"
    fi
    
    print_status "Generating YAML output to $OUTPUT_FILE..."
    
    local report_type="Full Report"
    if [[ "$OUTDATED_ONLY" == true ]]; then
        report_type="Outdated Modules Only"
    fi
    
    cat > "$OUTPUT_FILE" << EOF
# Generated: $(date -u '+%Y-%m-%d %H:%M:%S CET')
# Repository: unit-versions
# Environment: $ENVIRONMENT
# Report Type: $report_type

terraform_modules:
EOF
    
    for result in "${results[@]}"; do
        IFS='|' read -r unit_name module_name current_version latest_version status module_type <<< "$result"
        
        cat >> "$OUTPUT_FILE" << EOF

  - unit_name: "$unit_name"
    module_name: "$module_name"
    module_type: "$module_type"
    current_version: "$current_version"
    latest_version: "$latest_version"
    status: "$status"
    needs_update: $([ "$status" == "outdated" ] && echo "true" || echo "false")
EOF
    done
    
    print_success "YAML report generated: $OUTPUT_FILE"
}

scan_terragrunt_files() {
    local results=()
    
    print_status "Scanning Terragrunt files in $ENV_DIR directory..."
    
    while IFS= read -r -d '' file; do
        local unit_name
        unit_name=$(basename "$(dirname "$file")")
        
        print_status "Processing $unit_name..."
        
        local source
        source=$(extract_source "$file")
        
        if [[ -z "$source" ]]; then
            print_status "No source found in $file - skipping"
            continue
        fi
        
        print_status "Found source: $source"
        
        local module_type
        module_type=$(get_module_type "$source")
        
        case "$module_type" in
            "git")
                local git_info
                git_info=$(parse_git_source "$source")
                IFS='|' read -r repo_url current_version subpath <<< "$git_info"
                
                local github_repo
                github_repo=$(get_github_repo_info "$repo_url")
                
                if [[ -n "$github_repo" ]]; then
                    local latest_version
                    latest_version=$(get_latest_version "$github_repo" "$current_version")
                    
                    local status
                    status=$(compare_versions "$current_version" "$latest_version")
                    
                    local module_name
                    if [[ -n "$subpath" ]]; then
                        module_name="$github_repo//$subpath"
                    else
                        module_name="$github_repo"
                    fi
                    
                    results+=("$unit_name|$module_name|$current_version|$latest_version|$status|git")
                else
                    local clean_source
                    clean_source=$(echo "$source" | sed 's/^git:://' | sed 's/?ref=.*//')
                    results+=("$unit_name|$clean_source|$current_version|$current_version|up-to-date|git")
                fi
                ;;
            "local")
                local module_name
                module_name=$(basename "$source")
                results+=("$unit_name|$module_name|local|local|up-to-date|local")
                ;;
            *)
                results+=("$unit_name|$source|unknown|unknown|unknown|unknown")
                ;;
        esac
        
    done < <(find "$ENV_DIR" -name "terragrunt.hcl" -print0)
    
    if [[ ${#results[@]} -gt 0 ]]; then
        generate_yaml_output "${results[@]}"
    else
        print_error "No modules found or processed successfully."
        print_error "Please check that your terragrunt.hcl files contain valid 'source' declarations."
        exit 1
    fi
}

check_dependencies() {
    local missing_deps=()
    
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_error "Please install them and try again."
        exit 1
    fi
}

main() {
    echo "Terraform Module Version Checker"
    echo "================================"
    echo "Environment: $ENVIRONMENT"
    if [[ "$OUTDATED_ONLY" == true ]]; then
        echo "Mode: Outdated modules only"
    else
        echo "Mode: Full report"
    fi
    echo
    
    if [[ ! -d "$ENV_DIR" ]]; then
        print_error "Directory '$ENV_DIR' not found. Please run this script from the repository root."
        print_error "Available directories:"
        ls -la | grep "^d" | awk '{print $NF}' | grep -v "^\."
        exit 1
    fi
    
    check_dependencies
    
    scan_terragrunt_files
    
    print_success "Done! Check $OUTPUT_FILE for results."
}

main "$@"