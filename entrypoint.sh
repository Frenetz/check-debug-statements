#!/bin/bash
set -e

contains_dd1_statements() {
  echo "$1" | grep -q -E ' dd\('
}

contains_dd2_statements() {
  echo "$1" | grep -q -E ' @dd\('
}

contains_consolelog_statements() {
  echo "$1" | grep -q -E ' console\.log\('
}

git config --global credential.helper "store --file=.git/credentials"
echo "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com" > .git/credentials
git config --global --add safe.directory /github/workspace

if [[ "$GITHUB_EVENT_NAME" == "pull_request" ]]; then
	BASE_BRANCH="${GITHUB_BASE_REF}"
else
	BASE_BRANCH="test-branch"
fi

git fetch origin

changed_files=$(git diff --name-only "origin/$BASE_BRANCH" "$GITHUB_SHA")

IFS=',' read -r -a exclude_files <<< "$EXCLUDE_FILES"

need_throw_error=false
for filename in $changed_files; do
	if [[ " ${exclude_files[@]} " =~ " ${filename} " ]]; then
		continue
	fi
	if [[ -f "$filename" ]]; then
		if [[ "$filename" == *.blade.php || "$filename" == *.php || "$filename" == *.js ]]; then
			line_number=0
			while IFS= read -r line; do
				line_number=$((line_number + 1))
				if contains_dd1_statements "$line" || contains_dd2_statements "$line" || contains_consolelog_statements "$line"; then
					echo "File ${filename}:${line_number} Line \"$line\" contains debug statements (dd or @dd or console.log)"
					need_throw_error=true
				fi
			done < "$filename"
		fi
	fi
done

if $need_throw_error; then
	echo "Found files with debug statements."
	exit 1
fi
