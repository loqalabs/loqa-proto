#!/bin/bash

# Enhanced Protocol Buffer Change Analysis Script
# Provides detailed semantic versioning based on protobuf change patterns

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

print_usage() {
    echo "Usage: $0 <base-ref> [head-ref]"
    echo ""
    echo "Analyze protobuf changes between two git references for semantic versioning"
    echo ""
    echo "Arguments:"
    echo "  base-ref    Base git reference (e.g., v0.0.19, HEAD~1)"
    echo "  head-ref    Head git reference (default: HEAD)"
    echo ""
    echo "Output: JSON with change analysis and recommended version bump"
}

analyze_proto_field_changes() {
    local file="$1"
    local base_ref="$2" 
    local head_ref="$3"
    
    echo "  Analyzing field changes in $file..." >&2
    
    # Get both versions of the file
    local base_content=$(git show "${base_ref}:${file}" 2>/dev/null || echo "")
    local head_content=$(git show "${head_ref}:${file}" 2>/dev/null || echo "")
    
    # Analyze field number changes (breaking)
    local field_removals=$(diff <(echo "$base_content" | grep -E '^\s*[a-zA-Z_][a-zA-Z0-9_]*\s+[a-zA-Z_][a-zA-Z0-9_]*\s*=\s*[0-9]+' || true) \
                               <(echo "$head_content" | grep -E '^\s*[a-zA-Z_][a-zA-Z0-9_]*\s+[a-zA-Z_][a-zA-Z0-9_]*\s*=\s*[0-9]+' || true) \
                               | grep '^<' | wc -l || echo "0")
    
    # Analyze field additions (non-breaking if optional)
    local field_additions=$(diff <(echo "$base_content" | grep -E '^\s*[a-zA-Z_][a-zA-Z0-9_]*\s+[a-zA-Z_][a-zA-Z0-9_]*\s*=\s*[0-9]+' || true) \
                                <(echo "$head_content" | grep -E '^\s*[a-zA-Z_][a-zA-Z0-9_]*\s+[a-zA-Z_][a-zA-Z0-9_]*\s*=\s*[0-9]+' || true) \
                                | grep '^>' | wc -l || echo "0")
    
    # Check for required field additions (breaking)
    local required_additions=$(echo "$head_content" | grep -E '^\s*[a-zA-Z_][a-zA-Z0-9_]*\s+[a-zA-Z_][a-zA-Z0-9_]*\s*=\s*[0-9]+' | grep -v 'optional\|repeated' | wc -l || echo "0")
    local base_required=$(echo "$base_content" | grep -E '^\s*[a-zA-Z_][a-zA-Z0-9_]*\s+[a-zA-Z_][a-zA-Z0-9_]*\s*=\s*[0-9]+' | grep -v 'optional\|repeated' | wc -l || echo "0")
    local new_required=$((required_additions - base_required))
    
    echo "{\"field_removals\": $field_removals, \"field_additions\": $field_additions, \"new_required_fields\": $new_required}"
}

analyze_service_changes() {
    local file="$1"
    local base_ref="$2"
    local head_ref="$3"
    
    echo "  Analyzing service changes in $file..." >&2
    
    local base_content=$(git show "${base_ref}:${file}" 2>/dev/null || echo "")
    local head_content=$(git show "${head_ref}:${file}" 2>/dev/null || echo "")
    
    # Count RPC method changes
    local rpc_removals=$(diff <(echo "$base_content" | grep -E '^\s*rpc\s+[a-zA-Z_][a-zA-Z0-9_]*' || true) \
                             <(echo "$head_content" | grep -E '^\s*rpc\s+[a-zA-Z_][a-zA-Z0-9_]*' || true) \
                             | grep '^<' | wc -l || echo "0")
    
    local rpc_additions=$(diff <(echo "$base_content" | grep -E '^\s*rpc\s+[a-zA-Z_][a-zA-Z0-9_]*' || true) \
                              <(echo "$head_content" | grep -E '^\s*rpc\s+[a-zA-Z_][a-zA-Z0-9_]*' || true) \
                              | grep '^>' | wc -l || echo "0")
    
    echo "{\"rpc_removals\": $rpc_removals, \"rpc_additions\": $rpc_additions}"
}

main() {
    if [[ $# -lt 1 ]]; then
        print_usage
        exit 1
    fi
    
    local base_ref="$1"
    local head_ref="${2:-HEAD}"
    
    echo "Analyzing protocol changes from $base_ref to $head_ref..." >&2
    
    # Get changed proto files
    local changed_protos=$(git diff --name-only "$base_ref..$head_ref" | grep '\.proto$' || true)
    
    if [[ -z "$changed_protos" ]]; then
        echo '{"version_bump": "none", "reason": "no_proto_changes", "details": {}}'
        exit 0
    fi
    
    # Initialize analysis
    local total_breaking=0
    local total_additions=0
    local file_details="{"
    
    # Analyze each proto file
    local first=true
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        if [[ "$first" == "true" ]]; then
            first=false
        else
            file_details+=","
        fi
        
        echo "Analyzing $file..." >&2
        
        local field_analysis=$(analyze_proto_field_changes "$file" "$base_ref" "$head_ref")
        local service_analysis=$(analyze_service_changes "$file" "$base_ref" "$head_ref")
        
        # Extract breaking change counts
        local field_removals=$(echo "$field_analysis" | jq -r '.field_removals')
        local new_required=$(echo "$field_analysis" | jq -r '.new_required_fields')
        local rpc_removals=$(echo "$service_analysis" | jq -r '.rpc_removals')
        
        local file_breaking=$((field_removals + new_required + rpc_removals))
        total_breaking=$((total_breaking + file_breaking))
        
        local field_additions=$(echo "$field_analysis" | jq -r '.field_additions')
        local rpc_additions=$(echo "$service_analysis" | jq -r '.rpc_additions')
        local file_additions=$((field_additions + rpc_additions))
        total_additions=$((total_additions + file_additions))
        
        file_details+="\"$file\": {\"fields\": $field_analysis, \"services\": $service_analysis}"
    done <<< "$changed_protos"
    
    file_details+="}"
    
    # Determine version bump
    local version_bump
    local reason
    
    if [[ $total_breaking -gt 0 ]]; then
        version_bump="major"
        reason="breaking_changes_detected"
    elif [[ $total_additions -gt 0 ]]; then
        version_bump="minor"
        reason="new_features_added"
    else
        version_bump="patch"
        reason="non_functional_changes"
    fi
    
    # Check for explicit breaking change markers in commits
    local explicit_breaking=$(git log "$base_ref..$head_ref" --oneline --grep="BREAKING CHANGE" --grep="breaking:" -i | wc -l)
    if [[ $explicit_breaking -gt 0 ]]; then
        version_bump="major"
        reason="explicit_breaking_change_marker"
    fi
    
    # Output JSON result
    echo "{"
    echo "  \"version_bump\": \"$version_bump\","
    echo "  \"reason\": \"$reason\","
    echo "  \"breaking_changes\": $total_breaking,"
    echo "  \"new_features\": $total_additions,"
    echo "  \"explicit_breaking_markers\": $explicit_breaking,"
    echo "  \"changed_files\": $(echo "$changed_protos" | wc -l),"
    echo "  \"details\": $file_details"
    echo "}"
}

# Check for required tools
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required for JSON processing" >&2
    exit 1
fi

main "$@"