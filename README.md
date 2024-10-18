# GitHub Action Template

Go to entrypoint.sh and write your functions

## Usage

Use with [GitHub Actions](https://github.com/features/actions)

_.github/workflows/template.yml_

```
name: check-debug-statements
on: pull_request
jobs:
  check-debug-statements:
    runs-on: ubuntu-latest
    steps:
        - uses: actions/checkout@v1
	- name: Run template check
          uses: Frenetz/check-debug-statements@main
          env:
            GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

